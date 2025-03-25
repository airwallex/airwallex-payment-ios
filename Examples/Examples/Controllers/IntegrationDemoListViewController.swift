//
//  IntegrationDemoListViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex
import Combine

class IntegrationDemoListViewController: UIViewController {
    
    enum IntegrationType {
        case UI
        case API
    }
    
    struct ActionViewModel {
        let title: String
        let action: () -> Void
    }
    
    private lazy var viewModelsForUIIntegration: [ActionViewModel] = [
        ActionViewModel(
            title: NSLocalizedString("Launch default payments list", comment: DemoDataSource.commentForLocalization),
            action: { [weak self] in
                self?.launchDefaultPaymentsList()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Launch custom payments list", comment: DemoDataSource.commentForLocalization),
            action: { [weak self] in
                self?.launchCustomPaymentsList()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Launch card payment", comment: DemoDataSource.commentForLocalization),
            action: { [weak self] in
                self?.launchCardPayment(style: .push)
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Launch card payment (dialog)", comment: DemoDataSource.commentForLocalization),
            action: { [weak self] in
                self?.launchCardPayment(style: .present)
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Launch shipping address (dialog)", comment: DemoDataSource.commentForLocalization),
            action: { [weak self] in
                self?.launchShippingAddressDialog()
            }
        ),
    ]
    
    private lazy var viewModelsForAPIIntegration: [ActionViewModel] = [
        ActionViewModel(
            title: NSLocalizedString("Pay with card", comment: DemoDataSource.commentForLocalization),
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
            title: NSLocalizedString("Pay with Apple Pay", comment: DemoDataSource.commentForLocalization),
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
            title: NSLocalizedString("Get payment methods", comment: DemoDataSource.commentForLocalization),
            action: { [weak self] in
                self?.getPaymentMethods()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Get saved card methods", comment: DemoDataSource.commentForLocalization),
            action: { [weak self] in
                self?.getSavedCardMethods()
            }
        ),
    ]
    
    private lazy var listView: DemoListView = {
        let view = DemoListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var shippingAddress = DemoDataSource.shippingAddress
    
    private let integrationType: IntegrationType
    
    private var paymentSessionHandler: PaymentSessionHandler?
    
    init(_ integrationStyle: IntegrationType) {
        self.integrationType = integrationStyle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customizeNavigationBackButton()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCheckoutMode()
    }
}

private extension IntegrationDemoListViewController {
    
    func setupViews() {
        view.backgroundColor = .awxColor(.backgroundPrimary)
        view.addSubview(listView)
        
        setupTitle()
        // setup actions
        for action in (integrationType == .UI ? viewModelsForUIIntegration : viewModelsForAPIIntegration) {
            let view = AWXButton(style: .secondary, title: action.title)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.addTarget(self, action: #selector(onActionButtonTapped(_:)), for: .touchUpInside)
            listView.bottomStack.addArrangedSubview(view)
        }
        
        let constraints = [
            listView.topAnchor.constraint(equalTo: view.topAnchor),
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupTitle() {
        let title = integrationType == .UI ? NSLocalizedString("Integrate with Airwallex UI", comment: DemoDataSource.commentForLocalization)
        : NSLocalizedString("Integrate with low-level API", comment: "UI integration demo")
        
        let viewModel = TopViewModel(
            title: title,
            actionIcon: UIImage(named: "gear")?.withTintColor(.awxColor(.iconLink), renderingMode: .alwaysOriginal),
            actionHandler: { [weak self] in
                self?.onSettingButtonTapped()
            }
        )
        listView.topView.setup(viewModel)
    }
    
    func setupCheckoutMode() {
        let viewModel = ConfigActionViewModel(
            configName: NSLocalizedString("Payment type", comment: "mobile SDK demo"),
            configValue: ExamplesKeys.checkoutMode.localizedDescription,
            primaryAction: { [weak self] _ in
                self?.handleUserTapOptionSelectView()
            }
        )
        
        listView.optionView.setup(viewModel)
        
        if integrationType == .API {
            // show save card and redirect payment method for one-off payment only
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1) {
                for view in self.listView.bottomStack.arrangedSubviews {
                    guard let view = view as? UIButton,
                          let title = view.currentTitle else {
                        continue
                    }
                    switch ExamplesKeys.checkoutMode {
                    case .oneOff:
                        view.isHidden = false
                    case .recurring, .recurringWithIntent:
                        view.isHidden = (
                            title == DemoDataSource.titleForPayAndSaveCard ||
                            title == DemoDataSource.titleForPayByRedirect
                        )
                    }
                    
                    // 3DS in production is not controlled by api parameters or card numbers
                    if title == DemoDataSource.titleForForceCard3DS {
                        view.isHidden = ExamplesKeys.environment == .productionMode
                    }
                    view.alpha = view.isHidden ? 0 : 1
                }
            }
        }
    }
    
    func onSettingButtonTapped() {
        let optionsViewController = SettingsViewController()
        navigationController?.pushViewController(optionsViewController, animated: true)
    }

    func handleUserTapOptionSelectView() {
        showOptions(CheckoutMode.allCases.map({ $0.localizedDescription }), sender: listView.optionView) { index, _ in
            guard let checkoutMode = CheckoutMode(rawValue: index) else { return }
            ExamplesKeys.checkoutMode = checkoutMode
            self.setupCheckoutMode()
        }
    }
    
    @objc func onActionButtonTapped(_ sender: UIButton) {
        switch integrationType {
        case .UI:
            guard let title = sender.currentTitle,
                  let viewModel = viewModelsForUIIntegration.first(where: { $0.title == title }) else {
                return
            }
            viewModel.action()
        case .API:
            guard let title = sender.currentTitle,
                  let viewModel = viewModelsForAPIIntegration.first(where: { $0.title == title }) else {
                return
            }
            viewModel.action()
        }
    }
}

//  MARK:  UI Integration actions
private extension IntegrationDemoListViewController {
    
    func launchDefaultPaymentsList() {
        Task {
            startLoading()
            do {
                let session = try await createPaymentSession()
                try AWXUIContext.launchPayment(from: self, session: session)
            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopLoading()
        }
    }
    
    func launchCustomPaymentsList() {
        Task {
            startLoading()
            do {
                let session = try await createPaymentSession()
                //  custom payment methods by an array of payment method name
                try AWXUIContext.launchPayment(
                    from: self,
                    session: session,
                    filterBy: [ AWXApplePayKey, AWXCardKey, "alipaycn", "alipayhk" ]
                )
            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopLoading()
        }
    }
    
    func launchCardPayment(style: AWXUIContext.LaunchStyle) {
        Task {
            startLoading()
            do {
                let session = try await createPaymentSession()
                try AWXUIContext.launchCardPayment(
                    from: self,
                    session: session,
                    supportedBrands: AWXCardBrand.all,
                    style: style
                )
            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopLoading()
        }
    }
    
    func launchShippingAddressDialog() {
        let controller = AWXShippingViewController(nibName: nil, bundle: nil)
        controller.delegate = self
        controller.shipping = shippingAddress
        let nav = UINavigationController(rootViewController: controller)
        navigationController?.present(nav, animated: true)
    }
}

// MARK: low level API integration actions
private extension IntegrationDemoListViewController {
    
    func payWithCard(saveCard: Bool = false, force3DS: Bool = false) {
        // replace this testCard info
        let testCard = force3DS ? DemoDataSource.testCard3DS : DemoDataSource.testCard
        
        Task {
            startLoading()
            do {
                let card = try await confirmCardInfo(testCard)
                let session = try await createPaymentSession(force3DS: force3DS)
                paymentSessionHandler = PaymentSessionHandler(session: session, viewController: self)
                try paymentSessionHandler?.startCardPayment(
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
                try paymentSessionHandler?.startApplePay()
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
                try paymentSessionHandler?.startRedirectPayment(
                    with: "paypal",
                    additionalInfo: ["shopper_name": "Hector", "country_code": "CN"]
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
    
    func update(textField: UITextField,
                text: String?,
                placeholder: String?,
                fieldName: String?,
                keyboardType: UIKeyboardType = .asciiCapableNumberPad) {
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
}

// MARK: Session & Requests
private extension IntegrationDemoListViewController {
    
    func createPaymentIntent(force3DS: Bool = false) async throws -> AWXPaymentIntent {
        let request = PaymentIntentRequest(
            amount: Decimal(string: ExamplesKeys.amount)!,
            currency: ExamplesKeys.currency,
            order: DemoDataSource.createOrder(shipping: shippingAddress),
            metadata: ["id": 1],
            returnUrl: ExamplesKeys.returnUrl,
            customerID: ExamplesKeys.customerId,
            paymentMethodOptions: force3DS ? ["card": ["three_ds_action": "FORCE_3DS"]] : nil,
            apiKey: ExamplesKeys.apiKey,
            clientID: ExamplesKeys.clientId
        )
        
        let paymentIntent = try await withCheckedThrowingContinuation { continuation in
            Airwallex.apiClient.createPaymentIntent(request: request) { continuation.resume(with: $0) }
        }
        return paymentIntent
    }
    
    func generateClientSecretForRecurringPayment() async throws -> String {
        guard let customerId = ExamplesKeys.customerId else {
            throw NSError.airwallexError(localizedMessage: "Customer ID is not set")
        }
        let secret = try await withCheckedThrowingContinuation { continuation in
            Airwallex.apiClient.generateClientSecret(
                customerID: customerId,
                apiKey: ExamplesKeys.apiKey,
                clientID: ExamplesKeys.clientId) { result in
                    continuation.resume(with: result)
                }
        }
        return secret
    }
    
    func createPaymentSession(force3DS: Bool = false) async throws -> AWXSession {
        // create payment session
        var paymentSession: AWXSession
        switch ExamplesKeys.checkoutMode {
        case .oneOff:
            // create payment intent
            let paymentIntent = try await createPaymentIntent(force3DS: force3DS)
            // update client secret
            AWXAPIClientConfiguration.shared().clientSecret = paymentIntent.clientSecret
            // create AWXOneOffSession
            let session = AWXOneOffSession()
            session.paymentIntent = paymentIntent
            session.autoCapture = ExamplesKeys.autoCapture
            paymentSession = session
        case .recurring:
            // generate client secret
            let clientSecret = try await generateClientSecretForRecurringPayment()
            // update client secret
            AWXAPIClientConfiguration.shared().clientSecret = clientSecret
            // create AWXRecurringSession
            let session = AWXRecurringSession()
            session.setCurrency(ExamplesKeys.currency)
            session.setAmount(NSDecimalNumber(string: ExamplesKeys.amount))
            session.setCustomerId(ExamplesKeys.customerId)
            session.nextTriggerByType = ExamplesKeys.nextTriggerByType
            session.merchantTriggerReason = .unscheduled
            paymentSession = session
        case .recurringWithIntent:
            // create payment intent
            let paymentIntent = try await createPaymentIntent(force3DS: force3DS)
            // update client secret
            AWXAPIClientConfiguration.shared().clientSecret = paymentIntent.clientSecret
            // create AWXRecurringWithIntentSession
            let session = AWXRecurringWithIntentSession()
            session.paymentIntent = paymentIntent
            session.nextTriggerByType = ExamplesKeys.nextTriggerByType
            session.autoCapture = ExamplesKeys.autoCapture
            session.merchantTriggerReason = .scheduled
            paymentSession = session
        }
        // update `paymentSession.billing` if you want to reuse shipping address for billing address
        paymentSession.billing = shippingAddress
        paymentSession.countryCode = ExamplesKeys.countryCode
        // setup options for applepay
        paymentSession.applePayOptions = DemoDataSource.applePayOptions
        // setup returnURL (schema or universalLink of your app) which is required for payments like wechat pay
        paymentSession.returnURL = ExamplesKeys.returnUrl
        // update required billing contact fields
        updateRequiredBillingContactFields(paymentSession)
        return paymentSession
    }
    
    func updateRequiredBillingContactFields(_ session: AWXSession) {
        var requiredBillingContactFields: RequiredBillingContactFields = []
        if ExamplesKeys.requiresName {
            requiredBillingContactFields.insert(.name)
        }
        if ExamplesKeys.requiresEmail {
            requiredBillingContactFields.insert(.email)
        }
        if ExamplesKeys.requiresPhone {
            requiredBillingContactFields.insert(.phone)
        }
        if ExamplesKeys.requiresAddress {
            requiredBillingContactFields.insert(.address)
        }
        if ExamplesKeys.requiresCountryCode {
            requiredBillingContactFields.insert(.countryCode)
        }
        session.requiredBillingContactFields = requiredBillingContactFields
    }
}

extension IntegrationDemoListViewController: AWXShippingViewControllerDelegate {
    func shippingViewController(_ controller: AWXShippingViewController, didEditShipping shipping: AWXPlaceDetails) {
        shippingAddress = shipping
        controller.dismiss(animated: true)
    }
}

extension IntegrationDemoListViewController: AWXPaymentResultDelegate {
    func paymentViewController(_ controller: UIViewController?, didCompleteWith status: AirwallexPaymentStatus, error: Error?) {
        switch status {
        case .success:
            showAlert(message: "Your payment has been charged", title: "Payment successful")
        case .inProgress:
            print("Payment in progress, you should check payment status from time to time from backend and show result to the payer")
        case .failure:
            showAlert(message: error?.localizedDescription ?? "There was an error while processing your payment. Please try again.", title: "Payment failed")
        case .cancel:
            showAlert(message: "Your payment has been cancelled", title: "Payment cancelled")
        case .notStarted:
            break
        }
    }
    
    func paymentViewController(_ controller: UIViewController?, didCompleteWithPaymentConsentId paymentConsentId: String) {
        print("paymentViewController(_:didCompleteWithPaymentConsentId:) - \(paymentConsentId)")
    }
}
