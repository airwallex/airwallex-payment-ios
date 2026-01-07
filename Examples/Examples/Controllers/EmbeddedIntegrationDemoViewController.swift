//
//  EmbeddedIntegrationDemoViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Airwallex
import UIKit

class EmbeddedIntegrationDemoViewController: IntegrationDemoListViewController {

    // MARK: - Properties

    private var paymentElement: AWXPaymentElement?
    private var isInEmbeddedMode = false

    // MARK: - Abstract Property Overrides

    override var pageTitle: String {
        "Integrate with Embedded Element"
    }

    override var actionViewModels: [ActionViewModel] {
        if isInEmbeddedMode {
            return [
                ActionViewModel(
                    title: "Cancel",
                    action: { [weak self] in
                        self?.exitEmbeddedMode()
                    }
                )
            ]
        } else {
            return [
                ActionViewModel(
                    title: "Display embedded element",
                    action: { [weak self] in
                        self?.enterEmbeddedMode()
                    }
                )
            ]
        }
    }
}

// MARK: - Embedded Mode Management

private extension EmbeddedIntegrationDemoViewController {

    func enterEmbeddedMode() {
        guard !isInEmbeddedMode else { return }

        Task {
            startLoading()
            do {
                // Create payment session
                let session = try await createPaymentSession()

                // Create AWXPaymentElement
                let element = try await AWXPaymentElement.create(
                    hostViewController: self,
                    session: session,
                    delegate: self
                )
                self.paymentElement = element

                // Update mode and UI
                isInEmbeddedMode = true
                updateUIForEmbeddedMode()

            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopLoading()
        }
    }

    func exitEmbeddedMode() {
        guard isInEmbeddedMode else { return }

        // Update mode and UI
        isInEmbeddedMode = false
        updateUIForEmbeddedMode()

        // Clear references
        paymentElement = nil
    }

    func updateUIForEmbeddedMode() {
        // Hide/show optionView
        listView.optionView.isHidden = isInEmbeddedMode

        // Hide/show settings gear
        listView.topView.setActionButtonHidden(isInEmbeddedMode)

        // Add/remove embedded element view
        if isInEmbeddedMode, let elementView = paymentElement?.view {
            elementView.translatesAutoresizingMaskIntoConstraints = false
            listView.addViewToTopStack(elementView)
        } else if let elementView = paymentElement?.view {
            listView.removeViewFromTopStack(elementView)
        }

        // Reload action buttons based on current mode
        reloadActionButtons()
    }
}

// MARK: - AWXPaymentElementDelegate

extension EmbeddedIntegrationDemoViewController: AWXPaymentElementDelegate {

    func paymentElement(
        _ element: AWXPaymentElement,
        didCompleteWith status: AirwallexPaymentStatus,
        error: Error?
    ) {
        // Show result alert
        switch status {
        case .success:
            showAlert(message: "Your payment has been charged", title: "Payment successful")
        case .inProgress:
            print("Payment in progress")
            showAlert(message: "Payment is being processed", title: "Payment in progress")
        case .failure:
            showAlert(
                message: error?.localizedDescription ?? "There was an error while processing your payment.",
                title: "Payment failed"
            )
        case .cancel:
            showAlert(message: "Your payment has been cancelled", title: "Payment cancelled")
        }

        // Exit embedded mode
        exitEmbeddedMode()

        // Clear session
        session = nil
    }

    func paymentElement(
        _ element: AWXPaymentElement,
        didCompleteWithPaymentConsentId consentId: String
    ) {
        print("paymentElement(_:didCompleteWithPaymentConsentId:) - \(consentId)")
    }
}
