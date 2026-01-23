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
    private lazy var keyboardHandler = KeyboardHandler()

    // MARK: - Abstract Property Overrides

    override var pageTitle: String {
        "Shopping Cart"
    }

    override var actionViewModels: [ActionViewModel] {
        []
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupShoppingCartUI()
        loadPaymentElement()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardHandler.startObserving(listView.scrollView)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardHandler.stopObserving()
    }
}

// MARK: - UI Setup

private extension EmbeddedIntegrationDemoViewController {

    func setupShoppingCartUI() {
        // Hide optionView and gear button
        listView.optionView.isHidden = true
        listView.topView.setActionButtonHidden(true)

        // Add order info to top stack
        let orderInfoView = OrderInfoView(
            products: DemoDataSource.products,
            shipping: DemoDataSource.shippingAddress
        )
        orderInfoView.translatesAutoresizingMaskIntoConstraints = false
        listView.addViewToTopStack(orderInfoView)
    }
}

// MARK: - Payment Element

private extension EmbeddedIntegrationDemoViewController {

    func loadPaymentElement() {
        Task {
            startLoading()
            do {
                let session = try await createPaymentSession()
                AWXTheme.shared().tintColor = .red
                let config = AWXPaymentElement.Configuration()
                config.colors.textPrimary = .blue
                config.colors.borderDecorative = .black
                config.colors.backgroundPrimary = .lightGray
                let element = try await AWXPaymentElement.create(
                    hostViewController: self,
                    session: session,
                    delegate: self,
                    configuration: config
                )
                self.paymentElement = element

                let elementView = element.view
                elementView.translatesAutoresizingMaskIntoConstraints = false
                listView.addViewToBottomStack(elementView)
            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopLoading()
        }
    }
}

// MARK: - AWXPaymentResultDelegate override

extension EmbeddedIntegrationDemoViewController {

    override func paymentViewController(
        _ controller: UIViewController?,
        didCompleteWith status: AirwallexPaymentStatus,
        error: Error?
    ) {
        let action: () -> Void = {
            self.navigationController?.popViewController(animated: true)
        }
        switch status {
        case .success:
            showAlert(
                message: "Your payment has been charged",
                title: "Payment successful",
                action: action
            )
        case .inProgress:
            print("Payment in progress, you should check payment status from time to time from backend and show result to the payer")
            showAlert(
                message: "Payment in progress",
                action: action
            )
        case .failure:
            showAlert(
                message: error?.localizedDescription ?? "There was an error while processing your payment. Please try again.",
                title: "Payment failed",
                action: action
            )
        case .cancel:
            showAlert(
                message: "Your payment has been cancelled",
                title: "Payment cancelled",
                action: action
            )
        }
    }
}
