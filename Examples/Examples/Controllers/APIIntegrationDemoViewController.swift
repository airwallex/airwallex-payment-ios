//
//  APIIntegrationDemoViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Airwallex
import UIKit

class APIIntegrationDemoViewController: IntegrationDemoListViewController {

    // MARK: - Properties

    private lazy var hppHandler: HPPDemoController = {
        let handler = HPPDemoController()
        handler.webView.translatesAutoresizingMaskIntoConstraints = false
        handler.viewController = self
        return handler
    }()

    private var paymentSessionHandler: PaymentSessionHandler?

    // MARK: - Abstract Property Overrides

    override var pageTitle: String {
        "Integrate with low-level API"
    }

    override var actionViewModels: [ActionViewModel] {
        [
            ActionViewModel(
                title: "Pay with card",
                action: { [weak self] in
                    self?.payWithCard()
                }
            ),
            ActionViewModel(
                title: DemoDataSource.titleForPayAndSaveCard,
                action: { [weak self] in
                    self?.payWithCard(saveCard: true)
                }
            ),
            ActionViewModel(
                title: DemoDataSource.titleForForceCard3DS,
                action: { [weak self] in
                    self?.payWithCard(force3DS: true)
                }
            ),
            ActionViewModel(
                title: DemoDataSource.titleForPayWithApplePay,
                action: { [weak self] in
                    self?.payWithApplePay()
                }
            ),
            ActionViewModel(
                title: DemoDataSource.titleForPayByRedirect,
                action: { [weak self] in
                    self?.payWithRedirect()
                }
            ),
            ActionViewModel(
                title: "Get payment methods",
                action: { [weak self] in
                    self?.getPaymentMethods()
                }
            ),
            ActionViewModel(
                title: "Get saved card methods",
                action: { [weak self] in
                    self?.getSavedCardMethods()
                }
            ),
            ActionViewModel(
                title: "Open HPP (Hosted Payment Page)",
                action: { [weak self] in
                    self?.nativeHPPButtonTapped()
                }
            )
        ]
    }

    // MARK: - Checkout Mode Override

    override func setupCheckoutMode() {
        super.setupCheckoutMode()

        // show save card and redirect payment method for one-off payment only
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1) {
            for view in self.listView.bottomStack.arrangedSubviews {
                guard let button = view as? UIButton,
                      let title = button.currentTitle else {
                    continue
                }
                switch ExamplesKeys.checkoutMode {
                case .oneOff:
                    button.isHidden = false
                case .recurring, .recurringWithIntent:
                    button.isHidden = (
                        title == DemoDataSource.titleForPayAndSaveCard
                    )
                    if title == DemoDataSource.titleForPayWithApplePay {
                        button.isHidden = (ExamplesKeys.nextTriggerByType == .customerType)
                    }
                }

                // 3DS in production is not controlled by api parameters or card numbers
                if title == DemoDataSource.titleForForceCard3DS {
                    button.isHidden = ExamplesKeys.environment == .productionMode
                }
                button.alpha = button.isHidden ? 0 : 1
            }
        }
    }
}

// MARK: - API Integration Actions

private extension APIIntegrationDemoViewController {

    func payWithCard(saveCard: Bool = false, force3DS: Bool = false) {
        // replace this testCard info
        let testCard = force3DS ? DemoDataSource.testCard3DS : DemoDataSource.testCard

        Task {
            startLoading()
            do {
                let card = try await confirmCardInfo(testCard)
                let session = try await createPaymentSession(force3DS: force3DS)
                paymentSessionHandler = PaymentSessionHandler(session: session, viewController: self)
                paymentSessionHandler?.startCardPayment(
                    with: card,
                    billing: DemoDataSource.shippingAddress,
                    saveCard: saveCard
                )
            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopLoading()
        }
    }

    func payWithApplePay() {
        Task {
            startLoading()
            do {
                let session = try await createPaymentSession()
                paymentSessionHandler = PaymentSessionHandler(session: session, viewController: self)
                paymentSessionHandler?.startApplePay()
            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopLoading()
        }
    }

    func payWithRedirect() {
        Task {
            startLoading()
            do {
                let session = try await createPaymentSession()
                paymentSessionHandler = PaymentSessionHandler(session: session, viewController: self)
                paymentSessionHandler?.startRedirectPayment(
                    with: "alipayhk",
                    additionalInfo: nil
                )
            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopLoading()
        }
    }

    func getPaymentMethods() {
        let viewController = GetPaymentMethodsViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    func getSavedCardMethods() {
        let viewController = GetPaymentConsentsViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    func update(
        textField: UITextField,
        text: String?,
        placeholder: String?,
        fieldName: String?,
        keyboardType: UIKeyboardType = .asciiCapableNumberPad
    ) {
        textField.placeholder = placeholder
        textField.text = text
        textField.keyboardType = keyboardType
        textField.clearButtonMode = .whileEditing

        // left view
        let label = UILabel()
        label.text = fieldName
        label.textColor = .awxColor(.textPlaceholder)
        label.font = .awxFont(.caption3)
        label.sizeToFit()

        textField.leftView = label
        textField.leftViewMode = .always
    }

    func confirmCardInfo(_ testCard: AWXCard?) async throws -> AWXCard {
        let alertController = UIAlertController(
            title: "Card Info",
            message: "Environment: \(ExamplesKeys.environment.displayName.capitalized)",
            preferredStyle: .alert
        )
        alertController.addTextField { textField in
            self.update(
                textField: textField,
                text: testCard?.number,
                placeholder: "1234 1234 1234",
                fieldName: "No: "
            )
        }
        alertController.addTextField { textField in
            self.update(
                textField: textField,
                text: testCard?.name,
                placeholder: "host name",
                fieldName: "Name: ",
                keyboardType: .default
            )
        }
        alertController.addTextField { textField in
            self.update(
                textField: textField,
                text: testCard?.expiryYear,
                placeholder: "2025",
                fieldName: "Exp year: "
            )
        }
        alertController.addTextField { textField in
            self.update(
                textField: textField,
                text: testCard?.expiryMonth,
                placeholder: "12",
                fieldName: "Exp month: "
            )
        }
        alertController.addTextField { textField in
            self.update(
                textField: textField,
                text: testCard?.cvc,
                placeholder: "333",
                fieldName: "CVC/CVV: "
            )
        }

        return try await withCheckedThrowingContinuation { continuation in
            let payAction = UIAlertAction(title: "Pay", style: .cancel) { _ in
                let card = AWXCard()
                card.number = alertController.textFields![0].text ?? ""
                card.name = alertController.textFields![1].text ?? ""
                card.expiryYear = alertController.textFields![2].text ?? ""
                card.expiryMonth = alertController.textFields![3].text ?? ""
                card.cvc = alertController.textFields![4].text ?? ""

                if let message = card.validate() {
                    // TODO: more validation
                    continuation.resume(throwing: NSError.airwallexError(localizedMessage: message))
                } else {
                    continuation.resume(returning: card)
                }
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
                continuation.resume(throwing: NSError.airwallexError(localizedMessage: "Payment cancelled."))
            }

            // Add actions to the alert
            alertController.addAction(cancelAction)
            alertController.addAction(payAction)

            self.present(alertController, animated: true)
        }
    }

    @objc func nativeHPPButtonTapped() {
        startLoading()
        Task {
            do {
                let intent = try await Airwallex.apiClient.createPaymentIntent()
                let url = try await hppHandler.getURLForHPP(
                    intentId: intent.id,
                    clientSecret: intent.clientSecret,
                    currency: intent.currency,
                    countryCode: ExamplesKeys.countryCode,
                    returnURL: ExamplesKeys.returnUrl
                )
                print("URL for hpp: \(url)")
                await UIApplication.shared.open(url)
            } catch {
                print(error.localizedDescription)
            }
            stopLoading()
        }
    }
}
