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
            title: "Launch default payments list",
            action: { [weak self] in
                self?.launchDefaultPaymentsList(launchStyle: .push)
            }
        ),
        ActionViewModel(
            title: "Launch default payments list (dialog)",
            action: { [weak self] in
                self?.launchDefaultPaymentsList(launchStyle: .present)
            }
        ),
        ActionViewModel(
            title: "Launch custom payments list",
            action: { [weak self] in
                self?.launchCustomPaymentsList()
            }
        ),
        ActionViewModel(
            title: "Launch card payment",
            action: { [weak self] in
                self?.launchCardPayment(launchStyle: .push)
            }
        ),
        ActionViewModel(
            title: "Launch card payment (dialog)",
            action: { [weak self] in
                self?.launchCardPayment(launchStyle: .present)
            }
        ),
        ActionViewModel(
            title: "Launch shipping address (dialog)",
            action: { [weak self] in
                self?.launchShippingAddressDialog()
            }
        ),
    ]
    
    private lazy var viewModelsForAPIIntegration: [ActionViewModel] = [
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
        ),
    ]
    
    private lazy var hppHandler: HPPDemoController = {
        let handler = HPPDemoController()
        handler.webView.translatesAutoresizingMaskIntoConstraints = false
        handler.viewController = self
        return handler
    }()
    
    private lazy var listView: DemoListView = {
        let view = DemoListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.optionView.accessibilityIdentifier = AccessibilityIdentifiers.SettingsScreen.optionButtonForPaymentType
        return view
    }()
    
    private lazy var shippingAddress = DemoDataSource.shippingAddress
    
    private let integrationType: IntegrationType

    private var paymentSessionHandler: PaymentSessionHandler?
    
    private var paymentStatusPoller: PaymentStatusPoller?
    
    private var session: AWXSession?
    
    init(_ integrationStyle: IntegrationType) {
        self.integrationType = integrationStyle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        paymentStatusPoller?.stop()
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
        let title = integrationType == .UI ? "Integrate with Airwallex UI"
        : "Integrate with low-level API"
        
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
            configName: "Payment type",
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
                            title == DemoDataSource.titleForPayAndSaveCard
                        )
                        if title == DemoDataSource.titleForPayWithApplePay {
                            view.isHidden = (ExamplesKeys.nextTriggerByType == .customerType)
                        }
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

extension IntegrationDemoListViewController: PaymentIntentProvider {
    func createPaymentIntent() async throws -> AWXPaymentIntent {
        try await Airwallex.apiClient.createPaymentIntent(
            amount: amount.decimalValue
        )
    }
    
    var currency: String {
        ExamplesKeys.currency
    }
    
    var amount: NSDecimalNumber {
        let amount = ExamplesKeys.checkoutMode == .recurring ? 0 : (Decimal(string: ExamplesKeys.amount) ?? 0)
        return NSDecimalNumber(decimal: amount)
    }
    
    var customerId: String? {
        ExamplesKeys.customerId
    }
}

//  MARK:  UI Integration actions
private extension IntegrationDemoListViewController {
    
    func launchDefaultPaymentsList(launchStyle: AWXUIContext.LaunchStyle) {
        Task {
            startLoading()
            do {
                let session = try await createPaymentSession()
                AWXUIContext.launchPayment(
                    from: self,
                    session: session,
                    launchStyle: launchStyle,
                    layout: ExamplesKeys.paymentLayout
                )
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
                AWXUIContext.launchPayment(
                    from: self,
                    session: session,
                    filterBy: [ AWXApplePayKey, AWXCardKey],
                    layout: ExamplesKeys.paymentLayout
                )
            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopLoading()
        }
    }
    
    func launchCardPayment(launchStyle: AWXUIContext.LaunchStyle) {
        Task {
            startLoading()
            do {
                let session = try await createPaymentSession()
                AWXUIContext.launchCardPayment(
                    from: self,
                    session: session,
                    supportedBrands: AWXCardBrand.allAvailable,
                    launchStyle: launchStyle
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

// MARK: Session & Requests
private extension IntegrationDemoListViewController {
    
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
    
    func createPaymentSession(force3DS: Bool = ExamplesKeys.force3DS) async throws -> AWXSession {
        var session: AWXSession
        if ExamplesKeys.preferUnifiedSession {
            if ExamplesKeys.expressCheckout {
                session = try await createUnifiedSessionWithProvider(force3DS: force3DS)
            } else {
                session = try await createUnifiedSessionWithIntent(force3DS: force3DS)
            }
        } else {
            session = try await createLegacySession(force3DS: force3DS)
        }
        self.session = session
        return session
    }
    
    func createUnifiedSessionWithIntent(force3DS: Bool = ExamplesKeys.force3DS) async throws -> AWXSession {
        // Create payment intent
        let paymentIntent = try await Airwallex.apiClient.createPaymentIntent(
            amount: amount.decimalValue,
            force3DS: force3DS
        )
        let session = Session(
            paymentIntent: paymentIntent,
            countryCode: ExamplesKeys.countryCode,
            applePayOptions: DemoDataSource.applePayOptions,
            autoCapture: ExamplesKeys.autoCapture,
            billing: shippingAddress,
            paymentConsentOptions: consentOptions,
            requiredBillingContactFields: getRequiredBillingContactFields(),
            returnURL: ExamplesKeys.returnUrl
        )
        return session
    }
    
    func createUnifiedSessionWithProvider(force3DS: Bool = ExamplesKeys.force3DS) async throws -> AWXSession {
        // Merchant trigger reason
        let session = Session(
            paymentIntentProvider: self,
            countryCode: ExamplesKeys.countryCode,
            applePayOptions: DemoDataSource.applePayOptions,
            autoCapture: ExamplesKeys.autoCapture,
            billing: shippingAddress,
            paymentConsentOptions: consentOptions,
            requiredBillingContactFields: getRequiredBillingContactFields(),
            returnURL: ExamplesKeys.returnUrl
        )
        return session
    }
    
    private var consentOptions: PaymentConsentOptions? {
        guard ExamplesKeys.checkoutMode != .oneOff else { return nil }
        
        let type = ExamplesKeys.nextTriggerByType
        let reason: AirwallexMerchantTriggerReason = (type == .customerType) ? .undefined : .unscheduled
        
        return PaymentConsentOptions(
            nextTriggeredBy: type,
            merchantTriggerReason: reason
        )
    }
    
    func createLegacySession(force3DS: Bool = ExamplesKeys.force3DS) async throws -> AWXSession {
        // create payment session
        var paymentSession: AWXSession
        switch ExamplesKeys.checkoutMode {
        case .oneOff:
            // create payment intent
            let paymentIntent = try await Airwallex.apiClient.createPaymentIntent(force3DS: force3DS)
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
            let paymentIntent = try await Airwallex.apiClient.createPaymentIntent(force3DS: force3DS)
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
        paymentSession.requiredBillingContactFields = getRequiredBillingContactFields()
        return paymentSession
    }
    
    func getRequiredBillingContactFields() -> RequiredBillingContactFields {
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
        return requiredBillingContactFields
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
            // Extract intent ID and start polling using paymentIntentId()
            if let intentId = session?.paymentIntentId() {
                startPollingForPaymentIntent(intentId)
            }
        case .failure:
            showAlert(message: error?.localizedDescription ?? "There was an error while processing your payment. Please try again.", title: "Payment failed")
        case .cancel:
            showAlert(message: "Your payment has been cancelled", title: "Payment cancelled")
        }
        // clear session on payment complete
        session = nil
    }
    
    func paymentViewController(_ controller: UIViewController?, didCompleteWithPaymentConsentId paymentConsentId: String) {
        print("paymentViewController(_:didCompleteWithPaymentConsentId:) - \(paymentConsentId)")
    }
}

// MARK: - Payment Status Polling
private extension IntegrationDemoListViewController {
    func startPollingForPaymentIntent(_ intentId: String) {
        paymentStatusPoller?.stop()

        let poller = PaymentStatusPoller(
            intentId: intentId,
            apiClient: Airwallex.apiClient
        )
        poller.delegate = self
        paymentStatusPoller = poller
        poller.start()
    }
}

// MARK: - PaymentStatusPollerDelegate
extension IntegrationDemoListViewController: PaymentStatusPollerDelegate {
    
    func paymentStatusPoller(_ poller: PaymentStatusPoller, didStartPolling status: PaymentIntentStatus) {
        startLoading(text: status.rawValue)
    }
    
    func paymentStatusPoller(_ poller: PaymentStatusPoller, didUpdateStatus status: PaymentIntentStatus) {
        if status.isTerminal {
            stopLoading()
            showAlert(
                message: status.rawValue,
                title: session?.paymentIntentId() ?? ""
            )
        } else {
            startLoading(text: status.rawValue)
        }
    }

    func paymentStatusPoller(_ poller: PaymentStatusPoller, didFailWithError error: Error) {
        showAlert(
            message: "Error checking payment status: \(error.localizedDescription)",
            title: "Error"
        )
    }

    func paymentStatusPoller(_ poller: PaymentStatusPoller, didTimeoutWithStatus status: PaymentIntentStatus) {
        showAlert(
            message: "Payment status \(status.rawValue)",
            title: "Polling timeout"
        )
    }
}
