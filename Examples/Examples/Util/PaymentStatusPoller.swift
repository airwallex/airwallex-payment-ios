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
protocol PaymentStatusPollerDelegate: AnyObject {
    func paymentStatusPollerDidStartPolling(_ poller: PaymentStatusPoller)
    func paymentStatusPoller(_ poller: PaymentStatusPoller, didUpdateStatus attempt: PaymentAttempt)
    func paymentStatusPoller(_ poller: PaymentStatusPoller, didFailWithError error: Error)
    func paymentStatusPoller(_ poller: PaymentStatusPoller, didTimeoutWithStatus attempt: PaymentAttempt)
}

@MainActor
class PaymentStatusPoller {
    // MARK: - Properties

    weak var delegate: PaymentStatusPollerDelegate?

    private let intentId: String
    private(set) var paymentAttempt: PaymentAttempt?

    private let apiClient: APIClient
    private let maxPollingDuration: TimeInterval
    private let baseInterval: TimeInterval
    private let maxInterval: TimeInterval

    private var pollingTimer: Timer?
    private var pollingAttempts: Int = 0
    private var pollingStartTime: Date?
    private var isPolling: Bool = false

    // MARK: - Initialization

    init(
        intentId: String,
        apiClient: APIClient,
        maxPollingDuration: TimeInterval = 300, // 5 minutes
        baseInterval: TimeInterval = 2.0,
        maxInterval: TimeInterval = 16.0
    ) {
        self.intentId = intentId
        self.apiClient = apiClient
        self.maxPollingDuration = maxPollingDuration
        self.baseInterval = baseInterval
        self.maxInterval = maxInterval

        // Handle app lifecycle notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    // MARK: - Public Methods

    func start() {
        guard !isPolling else { return }

        // Check if latest payment attempt status is terminal
        guard paymentAttempt?.isTerminal != true else {
            return
        }

        isPolling = true
        pollingAttempts = 0
        pollingStartTime = Date()
        pollPaymentStatus()

        delegate?.paymentStatusPollerDidStartPolling(self)
    }

    func stop() {
        pollingTimer?.invalidate()
        pollingTimer = nil
        isPolling = false
        pollingAttempts = 0
        pollingStartTime = nil
    }

    // MARK: - Private Methods

    @objc private func handleAppDidBecomeActive() {
        start()
    }

    @objc private func handleAppWillResignActive() {
        stop()
    }

    private func pollPaymentStatus() {
        guard UIApplication.shared.applicationState == .active else {
            stop()
            return
        }
        guard pollingStartTime != nil else {
            stop()
            return
        }

        // Fetch status
        Task { @MainActor in
            do {
                let intent = try await apiClient.retrievePaymentIntent(intentId)
                handlePaymentIntnet(intent)
            } catch {
                delegate?.paymentStatusPoller(self, didFailWithError: error)
                stop()
            }
        }
    }

    private func handlePaymentIntnet(_ intent: PaymentIntent) {
        guard let pollingStartTime else {
            // polling is stopped
            stop()
            return
        }

        // Check if latest payment attempt exists
        guard let paymentAttempt = intent.latestPaymentAttempt else {
            let error = NSError.airwallexError(localizedMessage: "Payment attempt not found")
            delegate?.paymentStatusPoller(self, didFailWithError: error)
            stop()
            return
        }

        // Only notify delegate if status has changed
        // Use latest_payment_attempt.status for comparison

        let previousAttemp = self.paymentAttempt
        // Update status property
        self.paymentAttempt = paymentAttempt
        if paymentAttempt.status != previousAttemp?.status {
            delegate?.paymentStatusPoller(self, didUpdateStatus: paymentAttempt)
        }
        
        // Check if status is terminal using latest_payment_attempt.status
        if paymentAttempt.isTerminal {
            // Terminal states - stop polling
            stop()
        } else {
            // Continue polling
            if Date().timeIntervalSince(pollingStartTime) < maxPollingDuration {
                scheduleNextPoll()
            } else {
                delegate?.paymentStatusPoller(self, didTimeoutWithStatus: paymentAttempt)
                stop()
            }
        }
    }

    private func scheduleNextPoll() {
        let interval = calculateNextPollingInterval()
        pollingAttempts += 1

        pollingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.pollPaymentStatus()
            }
        }
    }

    private func calculateNextPollingInterval() -> TimeInterval {
        let exponentialInterval = baseInterval * pow(2, Double(pollingAttempts))
        return min(exponentialInterval, maxInterval)
    }
}
