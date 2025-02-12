//
//  IntegrationDemoListViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex

class IntegrationDemoListViewController: UIViewController {
    
    enum IntegrationType {
        case UI
        case API
    }
    
    struct ActionViewModel {
        let title: String
        let action: () -> Void
    }
    
    private let commentForLocalization = "UI integration demo"
    
    private lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let title = integrationType == .UI ? NSLocalizedString("Integrate with Airwallex UI", comment: "UI integration demo")
        : NSLocalizedString("Integrate with low-level API", comment: "UI integration demo")
        
        let viewModel = TopViewModel(
            title: title,
            actionIcon: UIImage(named: "gear")?.withTintColor(.awxIconLink, renderingMode: .alwaysOriginal),
            actionHandler: { [weak self] in
                self?.onSettingButtonTapped()
            }
        )
        view.setup(viewModel)
        return view
    }()
    
    private lazy var optionView: ConfigActionView = {
        let view = ConfigActionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.keyboardDismissMode = .interactive
        return view
    }()
    
    private lazy var topStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 16
        view.axis = .vertical
        return view
    }()
    
    private lazy var bottomStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 16
        view.axis = .vertical
        return view
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .awxBorderDecorative
        return view
    }()
    
    private lazy var viewModelsForUIIntegration: [ActionViewModel] = [
        ActionViewModel(
            title: NSLocalizedString("Launch default payments list", comment: commentForLocalization),
            action: { [weak self] in
                self?.launchDefaultPaymentsList()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Launch custom payments list", comment: commentForLocalization),
            action: { [weak self] in
                self?.launchCustomPaymentsList()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Launch card payment", comment: commentForLocalization),
            action: { [weak self] in
                self?.launchCardPayment()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Launch card payment (dialog)", comment: commentForLocalization),
            action: { [weak self] in
                self?.launchCardPaymentDialog()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Launch shipping address (dialog)", comment: commentForLocalization),
            action: { [weak self] in
                self?.launchShippingAddressDialog()
            }
        ),
    ]
    
    private lazy var viewModelsForAPIIntegration: [ActionViewModel] = [
        ActionViewModel(
            title: NSLocalizedString("Pay with card", comment: commentForLocalization),
            action: { [weak self] in
                self?.payWithCard()
            }
        ),
        ActionViewModel(
            title: titleForPayAndSaveCard,
            action: { [weak self] in
                self?.payWithCard(saveCard: true)
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Pay with card and trigger 3DS", comment: commentForLocalization),
            action: { [weak self] in
                self?.payWithCard(force3DS: true)
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Pay with Apple Pay", comment: commentForLocalization),
            action: { [weak self] in
                self?.payWithApplePay()
            }
        ),
        ActionViewModel(
            title: titleForPayByRedirection,
            action: { [weak self] in
                self?.payWithRedirect()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Get payment methods", comment: commentForLocalization),
            action: { [weak self] in
                self?.getPaymentMethods()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Get saved card methods", comment: commentForLocalization),
            action: { [weak self] in
                self?.getSavedCardMethods()
            }
        ),
    ]
    
    private lazy var shippingAddress: AWXPlaceDetails = {
        let shipping: [String : Any] = [
            "first_name": "Jason",
            "last_name": "Wang",
            "phone_number": "13800000000",
            "address": [
                "country_code": "CN",
                "state": "Shanghai",
                "city": "Shanghai",
                "street": "Pudong District",
                "postcode": "100000"
            ]
        ]
        return AWXPlaceDetails.decode(fromJSON: shipping) as! AWXPlaceDetails
    }()
    
    let integrationType: IntegrationType
    
    private lazy var apiClient = Airwallex.apiClient
    
    private lazy var applePayOptions: AWXApplePayOptions = {
        let options = AWXApplePayOptions(merchantIdentifier: applePayMerchantId)
        options.additionalPaymentSummaryItems = [.init(label: "goods", amount: 2), .init(label: "tax", amount: 1)]
        options.totalPriceLabel = "COMPANY, INC."
        options.requiredBillingContactFields = [.postalAddress]
        return options
    }()
    
    private var applePayMerchantId: String {
        switch AirwallexExamplesKeys.shared().environment {
        case .stagingMode:
            ""
        case .demoMode:
            "merchant.demo.com.airwallex.paymentacceptance"
        case .productionMode:
            "merchant.com.airwallex.paymentacceptance"
        }
    }
    
    private var paymentUISessionHandler: PaymentUISessionHandler?
    
    init(_ integrationStyle: IntegrationType) {
        self.integrationType = integrationStyle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleForPayAndSaveCard = NSLocalizedString("Pay with card and save card", comment: commentForLocalization)
    private lazy var titleForPayByRedirection = NSLocalizedString("Pay with Redirect", comment: commentForLocalization)
    
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
        view.backgroundColor = .awxBackgroundPrimary
        view.addSubview(scrollView)
        scrollView.addSubview(topStack)
        do {
            topStack.addArrangedSubview(topView)
            topStack.setCustomSpacing(24, after: topView)
            topStack.addArrangedSubview(optionView)
        }
        
        scrollView.addSubview(separator)
        scrollView.addSubview(bottomStack)
        do {
            let actions = integrationType == .UI ? viewModelsForUIIntegration : viewModelsForAPIIntegration
            for action in actions {
                let view = UIButton(style: .secondary, title: action.title)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.addTarget(self, action: #selector(onActionButtonTapped(_:)), for: .touchUpInside)
                bottomStack.addArrangedSubview(view)
            }
        }
        let heightRef = UIView()
        heightRef.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(heightRef)
        
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            topStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 6),
            topStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            topStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            topStack.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor, constant: -32),
            
            separator.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            bottomStack.topAnchor.constraint(greaterThanOrEqualTo: topStack.bottomAnchor, constant: 64),
            bottomStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            bottomStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            bottomStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            bottomStack.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor, constant: -32),
            
            heightRef.widthAnchor.constraint(equalToConstant: 10),
            heightRef.topAnchor.constraint(equalTo: scrollView.topAnchor),
            heightRef.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            heightRef.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            heightRef.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.safeAreaLayoutGuide.heightAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupCheckoutMode() {
        let viewModel = ConfigActionViewModel(
            configName: NSLocalizedString("Payment type", comment: "mobile SDK demo"),
            configValue: AirwallexExamplesKeys.shared().checkoutMode.localizedDescription,
            primaryAction: { [weak self] _ in
                self?.handleUserTapOptionSelectView()
            }
        )
        
        optionView.setup(viewModel)
        
        if integrationType == .API {
            // show save card and redirect payment method for one-off payment only
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1) {
                for view in self.bottomStack.arrangedSubviews {
                    guard let view = view as? UIButton,
                          let title = view.currentTitle else {
                        continue
                    }
                    if AirwallexExamplesKeys.shared().checkoutMode == .oneOffMode {
                        view.isHidden = false
                    } else {
                        view.isHidden = title == self.titleForPayByRedirection || title == self.titleForPayByRedirection
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
        showOptions(AirwallexCheckoutMode.allCases.map({ $0.localizedDescription }), sender: optionView) { index, _ in
            guard let checkoutMode = AirwallexCheckoutMode(rawValue: index) else { return }
            AirwallexExamplesKeys.shared().checkoutMode = checkoutMode
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

//  UI Integration actions
private extension IntegrationDemoListViewController {
    
    func launchDefaultPaymentsList() {
        Task {
            startLoading()
            do {
                let session = try await createPaymentSession()
                AWXUIContext.shared().delegate = self
                AWXUIContext.shared().session = session
                AWXUIContext.shared().launchPayment(from: self, style: .push)
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
                session.paymentMethods = [ AWXApplePayKey, AWXCardKey, "alipaycn" ]
                AWXUIContext.shared().delegate = self
                AWXUIContext.shared().session = session
                AWXUIContext.shared().launchPayment(from: self, style: .push)
            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopLoading()
        }
    }
    
    func launchCardPayment() {
        Task {
            startLoading()
            do {
                let session = try await createPaymentSession()
                session.paymentMethods = [ AWXCardKey ]
                if let session = session as? AWXOneOffSession {
                    session.hidePaymentConsents = true
                }

                AWXUIContext.shared().delegate = self
                AWXUIContext.shared().session = session
                AWXUIContext.shared().launchPayment(from: self, style: .push)
            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopLoading()
        }
    }
    
    func launchCardPaymentDialog() {
        Task {
            startLoading()
            do {
                let session = try await createPaymentSession()
                session.paymentMethods = [ AWXCardKey ]
                AWXUIContext.shared().delegate = self
                AWXUIContext.shared().session = session
                AWXUIContext.shared().launchPayment(from: self, style: .present)
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

// low level API integration actions
private extension IntegrationDemoListViewController {
    func payWithCard(saveCard: Bool = false, force3DS: Bool = false) {
        
        // replace this testCard info
        let testCard = AWXCard()
        testCard.number = "4111111111111111"
        testCard.expiryYear = "2050"
        testCard.expiryMonth = "11"
        testCard.cvc = "333"
        
        Task {
            AirwallexExamplesKeys.shared().force3DS = force3DS
            do {
                let session = try await createPaymentSession()
                
                AWXUIContext.shared().delegate = self
                AWXUIContext.shared().session = session
                
                paymentUISessionHandler = PaymentUISessionHandler(session: session, viewController: self) { handler in
                    let provider = AWXCardProvider(delegate: handler, session: session)
                    provider.confirmPaymentIntent(with: testCard, billing: nil, saveCard: saveCard)
                    return provider
                }
            } catch {
                showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func payWithApplePay() {
        Task {
            do {
                let session = try await createPaymentSession()
                
                AWXUIContext.shared().delegate = self
                AWXUIContext.shared().session = session
                
                paymentUISessionHandler = PaymentUISessionHandler(session: session, viewController: self) { handler in
                    let provider = AWXApplePayProvider(delegate: handler, session: session)
                    provider.startPayment()
                    return provider as AWXDefaultProvider
                }
            } catch {
                showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func payWithRedirect() {
        Task {
            do {
                let session = try await createPaymentSession()
                
                AWXUIContext.shared().delegate = self
                AWXUIContext.shared().session = session
                
                paymentUISessionHandler = PaymentUISessionHandler(session: session, viewController: self) { handler in
                    let provider = AWXRedirectActionProvider(delegate: handler, session: session)
                    provider.confirmPaymentIntent(with: "paypal", additionalInfo: ["shopper_name": "Hector", "country_code": "CN"])
                    return provider as AWXDefaultProvider
                }
            } catch {
                showAlert(message: error.localizedDescription)
            }
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
}

private extension IntegrationDemoListViewController {
    
    func createPaymentIntent() async throws -> AWXPaymentIntent {
        let request = PaymentIntentRequest(
            amount: Decimal(string: AirwallexExamplesKeys.shared().amount)!,
            currency: AirwallexExamplesKeys.shared().currency,
            order: .init(products: [
                .init(
                    type: "Free engraving",
                    code: "123",
                    name: "AirPods Pro",
                    sku: "piece",
                    quantity: 1,
                    unitPrice: 399,
                    desc: "Buy AirPods Pro, per month with trade-in",
                    url: "www.aircross.com"
                ),
                .init(
                    type: "White",
                    code: "123",
                    name: "HomePod",
                    sku: "piece",
                    quantity: 1,
                    unitPrice: 469,
                    desc: "Buy HomePod, per month with trade-in",
                    url: "www.aircross.com"
                )
            ], shipping: .init(
                firstName: "Jason",
                lastName: "Wang",
                phoneNumber: "13800000000",
                address: .init(countryCode: "CN", state: "Shanghai", city: "Shanghai", street: "Pudong District", postcode: "100000")
            ), type: "physical_goods"),
            metadata: ["id": 1],
            returnUrl: AirwallexExamplesKeys.shared().returnUrl,
            customerID: AirwallexExamplesKeys.shared().customerId,
            paymentMethodOptions: AirwallexExamplesKeys.shared().force3DS ? ["card": ["three_ds_action": "FORCE_3DS"]] : nil,
            apiKey: AirwallexExamplesKeys.shared().apiKey,
            clientID: AirwallexExamplesKeys.shared().clientId
        )
        
        let paymentIntent = try await withCheckedThrowingContinuation { continuation in
            apiClient.createPaymentIntent(request: request) { continuation.resume(with: $0) }
        }
        return paymentIntent
    }
    
    func generateClientSecretForRecurringPayment() async throws -> String {
        guard let customerId = AirwallexExamplesKeys.shared().customerId else {
            throw "Customer ID is not set"
        }
        let secret = try await withCheckedThrowingContinuation { continuation in
            apiClient.generateClientSecret(
                customerID: customerId,
                apiKey: AirwallexExamplesKeys.shared().apiKey,
                clientID: AirwallexExamplesKeys.shared().clientId) { result in
                    continuation.resume(with: result)
                }
        }
        return secret
    }
    
    func createPaymentSession() async throws -> AWXSession {
        var paymentSession: AWXSession
        switch AirwallexExamplesKeys.shared().checkoutMode {
        case .oneOffMode:
            let paymentIntent = try await createPaymentIntent()
            AWXAPIClientConfiguration.shared().clientSecret = paymentIntent.clientSecret
            let session = AWXOneOffSession()
            session.paymentIntent = paymentIntent
            session.autoCapture = AirwallexExamplesKeys.shared().autoCapture
            paymentSession = session
        case .recurringMode:
            AWXAPIClientConfiguration.shared().clientSecret = try await generateClientSecretForRecurringPayment()
            let session = AWXRecurringSession()
            session.setCurrency(AirwallexExamplesKeys.shared().currency)
            session.setAmount(NSDecimalNumber(string: AirwallexExamplesKeys.shared().amount))
            session.setCustomerId(AirwallexExamplesKeys.shared().customerId)
            session.nextTriggerByType = AirwallexExamplesKeys.shared().nextTriggerByType
            session.setRequiresCVC(AirwallexExamplesKeys.shared().requireCVC)
            session.merchantTriggerReason = .unscheduled
            paymentSession = session
        case .recurringWithIntentMode:
            let paymentIntent = try await createPaymentIntent()
            AWXAPIClientConfiguration.shared().clientSecret = paymentIntent.clientSecret
            let session = AWXRecurringWithIntentSession()
            session.paymentIntent = paymentIntent
            session.nextTriggerByType = AirwallexExamplesKeys.shared().nextTriggerByType
            session.setRequiresCVC(AirwallexExamplesKeys.shared().requireCVC)
            session.autoCapture = AirwallexExamplesKeys.shared().autoCapture
            session.merchantTriggerReason = .scheduled
            paymentSession = session
        }
        paymentSession.billing = shippingAddress
        paymentSession.countryCode = AirwallexExamplesKeys.shared().countryCode
        paymentSession.applePayOptions = applePayOptions
        paymentSession.returnURL = AirwallexExamplesKeys.shared().returnUrl
        return paymentSession
    }
}

extension IntegrationDemoListViewController: AWXShippingViewControllerDelegate {
    func shippingViewController(_ controller: AWXShippingViewController, didEditShipping shipping: AWXPlaceDetails) {
        navigationController?.popToViewController(self, animated: true)
        shippingAddress = shipping
    }
}

extension IntegrationDemoListViewController: AWXPaymentResultDelegate {
    func paymentViewController(_ controller: UIViewController, didCompleteWith status: AirwallexPaymentStatus, error: Error?) {
        switch status {
        case .success:
            showAlert(message: "Your payment has been charged", title: "Payment successful")
        case .inProgress:
            print("Payment in progress, you should check payment status from time to time from backend and show result to the payer")
        case .failure:
            showAlert(message: error?.localizedDescription ?? "There was an error while processing your payment. Please try again.", title: "Payment failed")
        case .cancel:
            showAlert(message: "Your payment has been cancelled", title: "Payment cancelled")
        }
    }
    
    func paymentViewController(_ controller: UIViewController, didCompleteWithPaymentConsentId paymentConsentId: String) {
        print("paymentViewController(_:didCompleteWithPaymentConsentId:) - \(paymentConsentId)")
    }
}
