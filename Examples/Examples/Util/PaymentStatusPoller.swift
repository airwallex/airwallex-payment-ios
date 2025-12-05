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

enum PaymentIntentStatus: Equatable, RawRepresentable {
    case succeeded
    case cancelled
    case pending
    case requiresPaymentMethod
    case requiresCustomerAction
    case pendingReview
    case requiresCapture
    case unknown(String)

    typealias RawValue = String

    init(rawValue: String) {
        switch rawValue.uppercased() {
        case "SUCCEEDED":
            self = .succeeded
        case "CANCELLED":
            self = .cancelled
        case "PENDING":
            self = .pending
        case "REQUIRES_PAYMENT_METHOD":
            self = .requiresPaymentMethod
        case "REQUIRES_CUSTOMER_ACTION":
            self = .requiresCustomerAction
        case "PENDING_REVIEW":
            self = .pendingReview
        case "REQUIRES_CAPTURE":
            self = .requiresCapture
        default:
            self = .unknown(rawValue)
        }
    }

    var rawValue: String {
        switch self {
        case .succeeded:
            return "SUCCEEDED"
        case .cancelled:
            return "CANCELLED"
        case .pending:
            return "PENDING"
        case .requiresPaymentMethod:
            return "REQUIRES_PAYMENT_METHOD"
        case .requiresCustomerAction:
            return "REQUIRES_CUSTOMER_ACTION"
        case .pendingReview:
            return "PENDING_REVIEW"
        case .requiresCapture:
            return "REQUIRES_CAPTURE"
        case .unknown(let value):
            return value
        }
    }

    var isTerminal: Bool {
        switch self {
        case .succeeded, .cancelled:
            return true
        default:
            return false
        }
    }

    var shouldContinuePolling: Bool {
        switch self {
        case .pending, .requiresPaymentMethod, .requiresCustomerAction, .pendingReview, .requiresCapture, .unknown:
            return true
        default:
            return false
        }
    }
}

@MainActor
protocol PaymentStatusPollerDelegate: AnyObject {
    func paymentStatusPoller(_ poller: PaymentStatusPoller, didStartPolling status: PaymentIntentStatus)
    func paymentStatusPoller(_ poller: PaymentStatusPoller, didUpdateStatus status: PaymentIntentStatus)
    func paymentStatusPoller(_ poller: PaymentStatusPoller, didFailWithError error: Error)
    func paymentStatusPoller(_ poller: PaymentStatusPoller, didTimeoutWithStatus status: PaymentIntentStatus)
}

@MainActor
class PaymentStatusPoller {
    // MARK: - Properties

    weak var delegate: PaymentStatusPollerDelegate?

    internal let intentId: String
    internal private(set) var status: PaymentIntentStatus

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
        status: PaymentIntentStatus = .pending,
        apiClient: APIClient,
        maxPollingDuration: TimeInterval = 300, // 5 minutes
        baseInterval: TimeInterval = 2.0,
        maxInterval: TimeInterval = 30.0
    ) {
        self.intentId = intentId
        self.status = status
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
        guard !status.isTerminal else { return }

        isPolling = true
        pollingAttempts = 0
        pollingStartTime = Date()
        pollPaymentStatus()
        delegate?.paymentStatusPoller(self, didStartPolling: status)
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
                let intent = try await apiClient.retrievePaymentIntent(intentId: intentId)
                handlePaymentIntent(intent)
            } catch {
                delegate?.paymentStatusPoller(self, didFailWithError: error)
                stop()
            }
        }
    }

    private func handlePaymentIntent(_ intent: AWXPaymentIntent) {
        guard let pollingStartTime else {
            // polling is stopped
            stop()
            return
        }
        let newStatus = PaymentIntentStatus(rawValue: intent.status)
        let previousStatus = status

        // Update status property
        status = newStatus

        // Only notify delegate if status has changed
        if previousStatus != newStatus {
            delegate?.paymentStatusPoller(self, didUpdateStatus: newStatus)
        }

        // Check if status is terminal or requires continued polling
        if newStatus.isTerminal {
            // Terminal states - stop polling
            stop()
        } else if newStatus.shouldContinuePolling {
            // Continue polling
            if case .unknown(let rawValue) = newStatus {
                print("PaymentStatusPoller: Unknown status '\(rawValue)', continuing to poll")
            }
            if Date().timeIntervalSince(pollingStartTime) < maxPollingDuration {
                scheduleNextPoll()
            } else {
                delegate?.paymentStatusPoller(self, didTimeoutWithStatus: newStatus)
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
