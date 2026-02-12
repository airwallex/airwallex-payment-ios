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

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

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

        //  Custom loading indicator
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

// MARK: - Payment Element

private extension EmbeddedIntegrationDemoViewController {

    func loadPaymentElement() {
        Task {
            loadingIndicator.startAnimating()
            do {
                let session = try await createPaymentSession()
                let configuration = AWXPaymentElement.Configuration()
                configuration.layout = ExamplesKeys.paymentLayout
                configuration.showsApplePayAsPrimaryButton = false
                configuration.showsPaymentProcessingIndicator = false
                let element = try await AWXPaymentElement.create(
                    session: session,
                    delegate: self,
                    configuration: configuration
                )
                self.paymentElement = element

                let elementView = element.view
                elementView.translatesAutoresizingMaskIntoConstraints = false
                listView.addViewToBottomStack(elementView)
            } catch {
                showAlert(message: error.localizedDescription)
            }
            loadingIndicator.stopAnimating()
        }
    }
}

// MARK: - AWXPaymentElementDelegate

extension EmbeddedIntegrationDemoViewController: AWXPaymentElementDelegate {

    func paymentElement(
        _ element: AWXPaymentElement,
        didStartPaymentFor paymentMethod: String
    ) {
        print("Payment started for method: \(paymentMethod)")
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }

    func paymentElement(
        _ element: AWXPaymentElement,
        didCompleteFor paymentMethod: String,
        with status: AirwallexPaymentStatus,
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
            print("Payment in progress for \(paymentMethod), you should check payment status from time to time from backend and show result to the payer")
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
                title: "Payment cancelled"
            )
        }
        loadingIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }

    func paymentElement(
        _ element: AWXPaymentElement,
        didCompleteFor paymentMethod: String,
        withPaymentConsentId paymentConsentId: String
    ) {
        print("Payment consent created for \(paymentMethod) with ID: \(paymentConsentId)")
    }
}
