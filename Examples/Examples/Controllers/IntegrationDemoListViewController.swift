//
//  IntegrationDemoListViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Airwallex
import Combine
import UIKit

class IntegrationDemoListViewController: UIViewController {

    struct ActionViewModel {
        let title: String
        let action: () -> Void
    }

    // MARK: - Abstract Properties (subclasses must override)

    var pageTitle: String {
        fatalError("Subclasses must override pageTitle")
    }

    var actionViewModels: [ActionViewModel] {
        fatalError("Subclasses must override actionViewModels")
    }

    // MARK: - Properties

    lazy var listView: DemoListView = {
        let view = DemoListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.optionView.accessibilityIdentifier = AccessibilityIdentifiers.SettingsScreen.optionButtonForPaymentType
        return view
    }()

    lazy var shippingAddress = DemoDataSource.shippingAddress

    var paymentStatusPoller: PaymentStatusPoller?

    var session: AWXSession?

    override func viewDidLoad() {
        super.viewDidLoad()

        customizeNavigationBackButton()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCheckoutMode()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Stop polling when view disappears to prevent retain cycles
        if isMovingFromParent || isBeingDismissed {
            paymentStatusPoller?.stop()
            paymentStatusPoller = nil
        }
    }

    deinit {
        print("\(type(of: self)):- " + #function)
    }
}

// MARK: - View Setup

extension IntegrationDemoListViewController {

    func setupViews() {
        view.backgroundColor = .awxColor(.backgroundPrimary)
        view.addSubview(listView)

        setupTitle()
        reloadActionButtons()

        let constraints = [
            listView.topAnchor.constraint(equalTo: view.topAnchor),
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    /// Reloads action buttons in bottomStack based on current actionViewModels.
    /// Subclasses can call this to refresh buttons when actionViewModels changes.
    func reloadActionButtons() {
        // Remove existing buttons
        for view in listView.bottomStack.arrangedSubviews {
            listView.bottomStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // Add buttons based on current actionViewModels
        for action in actionViewModels {
            let button = AWXButton(style: .secondary, title: action.title)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(onActionButtonTapped(_:)), for: .touchUpInside)
            listView.bottomStack.addArrangedSubview(button)
        }
    }

    func setupTitle() {
        let viewModel = TopViewModel(
            title: pageTitle,
            actionIcon: UIImage(named: "gear")?.withTintColor(.awxColor(.iconLink), renderingMode: .alwaysOriginal),
            actionHandler: { [weak self] in
                self?.onSettingButtonTapped()
            }
        )
        listView.topView.setup(viewModel)
    }

    /// Override in subclasses to customize checkout mode behavior
    @objc func setupCheckoutMode() {
        let viewModel = ConfigActionViewModel(
            configName: "Payment type",
            configValue: ExamplesKeys.checkoutMode.localizedDescription,
            primaryAction: { [weak self] _ in
                self?.handleUserTapOptionSelectView()
            }
        )
        listView.optionView.setup(viewModel)
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
        guard let title = sender.currentTitle,
              let viewModel = actionViewModels.first(where: { $0.title == title }) else {
            return
        }
        viewModel.action()
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

// MARK: - Session & Requests

extension IntegrationDemoListViewController {
    
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
                session = try createUnifiedSessionWithProvider(force3DS: force3DS)
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
    
    func createUnifiedSessionWithProvider(force3DS: Bool = ExamplesKeys.force3DS) throws -> AWXSession {
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
extension IntegrationDemoListViewController {
    func startPollingForPaymentIntent(_ intentId: String) {
        paymentStatusPoller?.stop()

        let poller = PaymentStatusPoller(
            intentId: intentId,
            apiClient: Airwallex.apiClient
        )
        paymentStatusPoller = poller

        startLoading()

        Task {
            do {
                let attempt = try await poller.getPaymentAttempt()
                stopLoading()
                showAlert(
                    message: attempt.description,
                    title: session?.paymentIntentId() ?? ""
                )
            } catch let error as PaymentStatusPoller.PollingError {
                stopLoading()
                switch error {
                case .timeout(let lastAttempt):
                    showAlert(
                        message: "Payment status \(lastAttempt?.status.rawValue ?? "unknown")",
                        title: "Polling timeout"
                    )
                case .apiError(let underlyingError):
                    showAlert(
                        message: "Error checking payment status: \(underlyingError.localizedDescription)",
                        title: "Error"
                    )
                case .paymentAttemptNotFound:
                    // Ignore payment attempt not found error
                    // usually this is caused by LPM recurring transaction
                    // which use legacy create/verify payemnt consent instead of confirm payment intent
                    break
                }
            } catch {
                stopLoading()
                showAlert(
                    message: "Error checking payment status: \(error.localizedDescription)",
                    title: "Error"
                )
            }
        }
    }
}
