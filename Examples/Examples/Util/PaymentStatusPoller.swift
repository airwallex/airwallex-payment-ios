//
//  PaymentStatusPoller.swift
//  Examples
//
//  Created by Claude on 2025/12/04.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import UIKit
import Airwallex

@MainActor
class PaymentStatusPoller {

    enum PollingError: Error {
        case apiError(Error)
        
        case timeout(lastAttempt: PaymentAttempt?)
        case paymentAttemptNotFound
    }

    private let intentId: String
    private let apiClient: APIClient
    private let maxPollingDuration: TimeInterval
    private let baseInterval: TimeInterval
    private let maxInterval: TimeInterval

    private var pollingTask: Task<PaymentAttempt, Error>?
    private var wentToBackgroundDuringRequest = false

    init(
        intentId: String,
        apiClient: APIClient,
        maxPollingDuration: TimeInterval = 300,
        baseInterval: TimeInterval = 2.0,
        maxInterval: TimeInterval = 16.0
    ) {
        self.intentId = intentId
        self.apiClient = apiClient
        self.maxPollingDuration = maxPollingDuration
        self.baseInterval = baseInterval
        self.maxInterval = maxInterval

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    @objc private func appWillResignActive() {
        wentToBackgroundDuringRequest = true
    }

    func getPaymentAttempt() async throws -> PaymentAttempt {
        let task = Task {
            let startTime = Date()
            var attempts = 0

            debugLog("Starting polling for intent: \(intentId)")

            while true {
                try Task.checkCancellation()

                // Wait for app to be active
                while UIApplication.shared.applicationState != .active {
                    debugLog("App not active, waiting...")
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    try Task.checkCancellation()
                }

                // Fetch status
                debugLog("Poll attempt #\(attempts + 1)")
                wentToBackgroundDuringRequest = false
                let intent: PaymentIntent
                do {
                    intent = try await apiClient.retrievePaymentIntent(intentId)
                } catch {
                    // If app went to background during request, retry instead of failing
                    if wentToBackgroundDuringRequest {
                        debugLog("Request failed due to background, retrying...")
                        continue
                    }
                    debugLog("API error: \(error.localizedDescription)")
                    throw PollingError.apiError(error)
                }

                guard let paymentAttempt = intent.latestPaymentAttempt else {
                    debugLog("Payment attempt not found")
                    throw PollingError.paymentAttemptNotFound
                }

                debugLog("Payment attempt status: \(paymentAttempt.status.rawValue)")

                if paymentAttempt.isFinal {
                    debugLog("Final status reached: \(paymentAttempt.status.rawValue)")
                    return paymentAttempt
                }

                // Check timeout
                let elapsed = Date().timeIntervalSince(startTime)
                if elapsed >= maxPollingDuration {
                    debugLog("Timeout after \(elapsed)s, last status: \(paymentAttempt.status.rawValue)")
                    throw PollingError.timeout(lastAttempt: paymentAttempt)
                }

                // Wait before next poll (exponential backoff)
                let interval = min(baseInterval * pow(2, Double(attempts)), maxInterval)
                attempts += 1
                debugLog("Waiting \(interval)s before next poll...")
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }

        pollingTask = task

        do {
            return try await task.value
        } catch {
            pollingTask = nil
            if error is CancellationError {
                throw PollingError.apiError(error)
            }
            throw error
        }
    }

    func stop() {
        debugLog("Polling stopped")
        pollingTask?.cancel()
        pollingTask = nil
    }

    private func debugLog(_ message: String) {
        #if DEBUG
        print("[PaymentStatusPoller] \(message)")
        #endif
    }
}
