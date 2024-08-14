//
//  FlowWithoutUIViewController.swift
//  SwiftExamples
//
//  Created by Tony He (CTR) on 2024/8/12.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Airwallex
import UIKit

class FlowWithoutUIViewController: UIViewController {
    enum AirwallexFlowMode {
        case cardWithoutUI
        case cardAndSaveWithoutUI
        case cardWith3DS
        case applepay
        case savedCard
        case paymentMethods
    }

    private lazy var paymentModeTable: UITableView = {
        let tb = UITableView()
        tb.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "PaymentModeTableCell")
        tb.dataSource = self
        tb.delegate = self
        tb.bounces = false
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()

    private var checkoutMode: AirwallexCheckoutMode = .oneOff
    private let dataArray = ["One-off", "Recurring", "Recurring and Payment"]
    private var selectedIndex = 0

    private lazy var scroll: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.bounces = false
        return sv
    }()

    private lazy var payWithCardDetailButton: UIButton = createButton(title: "pay with card detail")
    private lazy var payWithCardDetailAndSaveButton: UIButton = createButton(title: "pay with card detail and save")
    private lazy var payWithCardDetailWith3DS: UIButton = createButton(title: "pay with card detail with 3DS")
    private lazy var applepayButton: UIButton = createButton(title: "Apple Pay")
    private lazy var paymentMethodsButton: UIButton = createButton(title: "get payment methods")
    private lazy var savedCardButton: UIButton = createButton(title: "get saved cards")

    private lazy var cardInfo: CardInfoView = {
        let ci = CardInfoView()
        ci.translatesAutoresizingMaskIntoConstraints = false
        ci.isHidden = true
        ci.pay.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        return ci
    }()

    private lazy var paymentMethodList: PaymentMethodListView = {
        let pv = PaymentMethodListView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.isHidden = true
        return pv
    }()

    private lazy var savedCard: SavedCardView = {
        let sc = SavedCardView()
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.delegate = self
        sc.isHidden = true
        return sc
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.hidesWhenStopped = true
        return ai
    }()

    private var paymentIntent: AWXPaymentIntent?
    private var applePayProvider: AWXApplePayProvider?
    private var provider: AWXDefaultProvider?
    private var flowMode: AirwallexFlowMode = .cardWithoutUI
    private var session: AWXSession?
    private var editableCard: AWXCard = .init(number: "4012000300000005", expiryMonth: "12", expiryYear: "2032", name: "John Citizen", cvc: "123", bin: nil, last4: nil, brand: nil, country: nil, funding: nil, fingerprint: nil, cvcCheck: nil, avsCheck: nil, numberType: nil)
    private var fixedCard: AWXCard = .init(number: "4012000300000088", expiryMonth: "12", expiryYear: "2032", name: "John Citizen", cvc: "123", bin: nil, last4: nil, brand: nil, country: nil, funding: nil, fingerprint: nil, cvcCheck: nil, avsCheck: nil, numberType: nil)

    private let client: AWXAPIClientOC = .init(configuration: AWXAPIClientConfiguration.shared())

    var shipping: AWXPlaceDetails?
    var products: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupExamplesAPIClient()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        paymentModeTable.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .none)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicator.center = view.center
    }

    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingTapped))

        [paymentModeTable,
         scroll,
         activityIndicator,
         cardInfo,
         paymentMethodList,
         savedCard].forEach { view.addSubview($0) }

        [payWithCardDetailButton,
         payWithCardDetailAndSaveButton,
         payWithCardDetailWith3DS,
         applepayButton,
         paymentMethodsButton,
         savedCardButton].forEach { scroll.addSubview($0) }

        var allConstraints = [
            paymentModeTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            paymentModeTable.leftAnchor.constraint(equalTo: view.leftAnchor),
            paymentModeTable.rightAnchor.constraint(equalTo: view.rightAnchor),
            paymentModeTable.heightAnchor.constraint(equalToConstant: 140),

            scroll.topAnchor.constraint(equalTo: paymentModeTable.bottomAnchor, constant: 10.0),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ]

        allConstraints.append(contentsOf: setupButtonConstraints(payWithCardDetailButton, topAnchor: scroll.topAnchor))
        allConstraints.append(contentsOf: setupButtonConstraints(payWithCardDetailAndSaveButton, topAnchor: payWithCardDetailButton.bottomAnchor))
        allConstraints.append(contentsOf: setupButtonConstraints(payWithCardDetailWith3DS, topAnchor: payWithCardDetailAndSaveButton.bottomAnchor))
        allConstraints.append(contentsOf: setupButtonConstraints(applepayButton, topAnchor: payWithCardDetailWith3DS.bottomAnchor))
        allConstraints.append(contentsOf: setupButtonConstraints(paymentMethodsButton, topAnchor: applepayButton.bottomAnchor))
        allConstraints.append(contentsOf: setupButtonConstraints(savedCardButton, topAnchor: paymentMethodsButton.bottomAnchor))
        allConstraints.append(savedCardButton.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -30))

        allConstraints.append(contentsOf: setupSubviewConstraints(cardInfo))
        allConstraints.append(contentsOf: setupSubviewConstraints(paymentMethodList))
        allConstraints.append(contentsOf: setupSubviewConstraints(savedCard))

        NSLayoutConstraint.activate(allConstraints)
    }

    private func setupButtonConstraints(_ button: UIButton, topAnchor: NSLayoutYAxisAnchor) -> [NSLayoutConstraint] {
        return [
            button.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 48),
            button.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -48),
            button.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -96),
            button.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            button.heightAnchor.constraint(equalToConstant: 50),
        ]
    }

    private func setupSubviewConstraints(_ subview: UIView) -> [NSLayoutConstraint] {
        return [
            subview.topAnchor.constraint(equalTo: view.topAnchor),
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
    }

    private func setupExamplesAPIClient() {
        APIClient.shared().apiKey = AirwallexExamplesKeys.shared().apiKey
        APIClient.shared().clientID = AirwallexExamplesKeys.shared().clientId
    }

    @objc private func mainButtonTapped(_ button: UIButton) {
        switch button {
        case payWithCardDetailButton:
            flowMode = .cardWithoutUI
        case payWithCardDetailAndSaveButton:
            flowMode = .cardAndSaveWithoutUI
        case payWithCardDetailWith3DS:
            flowMode = .cardWith3DS
        case applepayButton:
            flowMode = .applepay
        case paymentMethodsButton:
            flowMode = .paymentMethods
        case savedCardButton:
            flowMode = .savedCard
        default:
            break
        }

        startAnimating()
        // Usually you should call your backend to get these info. You should not store api_key or client_id in your APP directly.
        APIClient.shared().createAuthenticationToken { error in
            if let error {
                self.showAlert(error.localizedDescription, withTitle: NSLocalizedString("Fail to request token.", comment: ""))
                self.stopAnimating()
            } else {
                let customerId = UserDefaults.standard.string(forKey: kCachedCustomerID)
                print(customerId)
                self.createPaymentIntentWithCustomerId(customerId)
            }
        }
    }

    private func getAvailablePaymentMethods() {
        let configuration = AWXGetPaymentMethodTypesConfiguration()
        configuration.transactionCurrency = session?.currency()
        configuration.transactionMode = session?.transactionMode()
        configuration.countryCode = session?.countryCode
        configuration.lang = session?.lang
        configuration.pageNum = 0
        configuration.pageSize = 20

        AWXAPIClient.getAvailablePaymentMethodsWithConfiguration(configuration) { response, error in
            if let response {
                self.view.bringSubviewToFront(self.paymentMethodList)
                self.paymentMethodList.isHidden = false
                self.paymentMethodList.reload(with: response.items ?? [])
            } else if let error {
                self.showAlert(error.localizedDescription, withTitle: nil)
                self.stopAnimating()
            } else {
                self.stopAnimating()
            }
        }
    }

    private func getSavedCards() {
        let request = AWXGetPaymentConsentsRequest()
        request.customerId = session?.customerId() ?? ""
        request.status = "VERIFIED"
        request.nextTriggeredBy = FormatNextTriggerByType(.customerType)
        request.pageNum = 0
        request.pageSize = 20
        client.send(request) { response, _ in
            if let result = response as? AWXGetPaymentConsentsResponse {
                self.view.bringSubviewToFront(self.savedCard)
                self.savedCard.isHidden = false
                self.savedCard.reload(with: result.items)
            }
        }
    }

    private func createPaymentIntentWithCustomerId(_ customerId: String?) {
        let group = DispatchGroup()

        var taskError: Error?
        var paymentIntent: AWXPaymentIntent?
        var customerSecret: String?

        var parameters = ["amount": AirwallexExamplesKeys.shared().amount,
                          "currency": AirwallexExamplesKeys.shared().currency,
                          "merchant_order_id": NSUUID().uuidString,
                          "request_id": NSUUID().uuidString,
                          "metadata": ["id": 1],
                          "return_url": AirwallexExamplesKeys.shared().returnUrl,
                          "order": [
                              "products": [[
                                  "type": "Free engraving",
                                  "code": "123",
                                  "name": "AirPods Pro",
                                  "sku": "piece",
                                  "quantity": 1,
                                  "unit_price": 399.0,
                                  "desc": "Buy AirPods Pro, per month with trade-in",
                                  "url": "www.aircross.com",
                              ],
                              [
                                  "type": "White",
                                  "code": "123",
                                  "name": "HomePod",
                                  "sku": "piece",
                                  "quantity": 1,
                                  "unit_price": 469.0,
                                  "desc": "Buy HomePod, per month with trade-in",
                                  "url": "www.aircross.com",
                              ]],
                              "shipping": [
                                  "first_name": "Jason",
                                  "last_name": "Wang",
                                  "phone_number": "13800000000",
                                  "address": [
                                      "country_code": "CN",
                                      "state": "Shanghai",
                                      "city": "Shanghai",
                                      "street": "Pudong District",
                                      "postcode": "100000",
                                  ],
                              ],
                              "type": "physical_goods",
                          ]] as [String: Any]

        if let customerId {
            parameters["customer_id"] = customerId
        }

        if checkoutMode != .recurring {
            group.enter()
            APIClient.shared().createPaymentIntent(withParameters: parameters) { intent, error in
                if let error {
                    taskError = error
                    group.leave()
                    return
                }

                paymentIntent = intent
                group.leave()
            }
        }

        if let customerId, checkoutMode == .recurring {
            group.enter()
            APIClient.shared().generateSecret(withCustomerId: customerId) { result, error in
                if let error {
                    taskError = error
                    group.leave()
                    return
                }
                customerSecret = result?["client_secret"] as? String ?? ""
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.stopAnimating()

            if let taskError {
                self.showAlert(taskError.localizedDescription, withTitle: nil)
                return
            }

            // Step 2: Setup client secret from payment intent or setup client secret generated with customer id
            // This is only for example. You should call your backend to get payment intent.
            AWXAPIClientConfiguration.shared().clientSecret = paymentIntent?.clientSecret ?? customerSecret
            self.showEntirePaymentFlowWithPaymentIntent(paymentIntent)
        }
    }

    @objc private func payTapped() {
        cardInfo.isHidden = true
        switch flowMode {
        case .cardWithoutUI:
            let provider = provider as? AWXCardProvider
            editableCard = cardInfo.card
            startAnimating()
            provider?.confirmPaymentIntent(with: editableCard, billing: shipping, saveCard: false)
        case .cardAndSaveWithoutUI:
            let provider = provider as? AWXCardProvider
            editableCard = cardInfo.card
            startAnimating()
            provider?.confirmPaymentIntent(with: editableCard, billing: shipping, saveCard: true)
        case .cardWith3DS:
            let provider = provider as? AWXCardProvider
            startAnimating()
            provider?.confirmPaymentIntent(with: fixedCard, billing: shipping, saveCard: false)
        default:
            break
        }
    }

    private func showEntirePaymentFlowWithPaymentIntent(_ paymentIntent: AWXPaymentIntent?) {
        self.paymentIntent = paymentIntent
        // Step 3: Create session
        let session = createSession(paymentIntent)

        // Step 4: Present payment flow
        let context = AWXUIContext.shared()

        context.delegate = self
        context.session = session
        self.session = session
        switch flowMode {
        case .cardWithoutUI, .cardAndSaveWithoutUI:
            let provider = AWXCardProvider(delegate: self, session: session)
            self.provider = provider
            cardInfo.card = editableCard
            cardInfo.isEditEnabled = true
            cardInfo.isHidden = false
            view.bringSubviewToFront(cardInfo)
        case .cardWith3DS:
            let provider = AWXCardProvider(delegate: self, session: session)
            self.provider = provider
            cardInfo.card = fixedCard
            cardInfo.isEditEnabled = false
            cardInfo.isHidden = false
            view.bringSubviewToFront(cardInfo)
        case .applepay:
            let provider = AWXApplePayProvider(delegate: self, session: session)
            provider.startPayment()
            applePayProvider = provider
        case .paymentMethods:
            getAvailablePaymentMethods()
        case .savedCard:
            getSavedCards()
        }
    }

    @objc private func settingTapped() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OptionsViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func createSession(_ paymentIntent: AWXPaymentIntent?) -> AWXSession {
        switch checkoutMode {
        case .oneOff:
            let session = AWXOneOffSession()
            let options = AWXApplePayOptions(merchantIdentifier: "merchant.com.airwallex.paymentacceptance")
            options.additionalPaymentSummaryItems = [
                PKPaymentSummaryItem(label: "goods", amount: .init(string: "2")), PKPaymentSummaryItem(label: "tax", amount: .init(string: "1")),
            ]
            options.requiredBillingContactFields = [PKContactField.postalAddress]
            options.totalPriceLabel = "COMPANY, INC."
            session.applePayOptions = options
            session.countryCode = AirwallexExamplesKeys.shared().countryCode
            session.billing = shipping
            session.returnURL = AirwallexExamplesKeys.shared().returnUrl
            session.paymentIntent = paymentIntent
            session.autoCapture = UserDefaults.standard.bool(forKey: kCachedAutoCapture)
            // you can configure the payment method list manually.(But only available ones will be displayed)
//            session.paymentMethods = ["card"];
//            session.hidePaymentConsents = true;
            return session
        case .recurring:
            let session = AWXRecurringSession()
            session.countryCode = AirwallexExamplesKeys.shared().countryCode
            session.billing = shipping
            session.returnURL = AirwallexExamplesKeys.shared().returnUrl
            session.setCurrency(AirwallexExamplesKeys.shared().currency)
            session.setAmount(.init(string: AirwallexExamplesKeys.shared().amount))
            session.setCustomerId(UserDefaults.standard.string(forKey: kCachedCustomerID))
            session.nextTriggerByType = AirwallexNextTriggerByType(rawValue: UInt(UserDefaults.standard.integer(forKey: kCachedNextTriggerBy))) ?? .customerType
            session.setRequiresCVC(UserDefaults.standard.bool(forKey: kCachedRequiresCVC))
            session.merchantTriggerReason = .unscheduled
            // you can configure the payment method list manually.(But only available ones will be displayed)
            //        session.paymentMethods = ["card"];

            return session
        case .recurringWithIntent:
            let session = AWXRecurringWithIntentSession()
            session.countryCode = AirwallexExamplesKeys.shared().countryCode
            session.billing = shipping
            session.returnURL = AirwallexExamplesKeys.shared().returnUrl
            session.paymentIntent = paymentIntent
            session.nextTriggerByType = AirwallexNextTriggerByType(rawValue: UInt(UserDefaults.standard.integer(forKey: kCachedNextTriggerBy))) ?? .customerType
            session.setRequiresCVC(UserDefaults.standard.bool(forKey: kCachedRequiresCVC))
            session.autoCapture = UserDefaults.standard.bool(forKey: kCachedAutoCapture)
            // you can configure the payment method list manually.(But only available ones will be displayed)
            //        session.paymentMethods = ["card"];

            return session
        }
    }

    private func showPaymentSuccess() {
        let title = NSLocalizedString("Payment successful", comment: "")
        let message = NSLocalizedString("Your payment has been charged", comment: "")
        showAlert(message, withTitle: title)
    }

    private func showPaymentFailure(_ error: Error?) {
        let title = NSLocalizedString("Payment failed", comment: "")
        let message = error?.localizedDescription ?? NSLocalizedString("There was an error while processing your payment. Please try again.", comment: "")
        showAlert(message, withTitle: title)
    }

    private func showPaymentCancel() {
        let title = NSLocalizedString("Payment cancelled", comment: "")
        let message = NSLocalizedString("Your payment has been cancelled", comment: "")
        showAlert(message, withTitle: title)
    }

    private func startAnimating() {
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }

    private func stopAnimating() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }

    private func createButton(title: String) -> UIButton {
        let btn = UIButton()
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 24)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(mainButtonTapped(_:)), for: .touchUpInside)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }
}

extension FlowWithoutUIViewController: AWXPaymentResultDelegate {
    func paymentViewController(_: UIViewController, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
        stopAnimating()
        switch status {
        case .success:
            showPaymentSuccess()
        case .failure:
            showPaymentFailure(error)
        case .cancel:
            showPaymentCancel()
        default:
            break
        }
    }

    func paymentViewController(_: UIViewController, didCompleteWithPaymentConsentId Id: String) {
        print("didGetPaymentConsentId: \(Id)")
    }
}

extension FlowWithoutUIViewController: AWXProviderDelegate {
    func provider(_: AWXDefaultProvider, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
        stopAnimating()
        switch status {
        case .success:
            showPaymentSuccess()
        case .failure:
            showPaymentFailure(error)
        case .cancel:
            showPaymentCancel()
        default:
            break
        }
    }

    func provider(_: AWXDefaultProvider, didCompleteWithPaymentConsentId Id: String) {
        print("didGetPaymentConsentId: \(Id)")
    }

    func provider(_: AWXDefaultProvider, didInitializePaymentIntentId paymentIntentId: String) {
        print("didInitializePaymentIntentId: \(paymentIntentId)")
    }

    func providerDidEndRequest(_: AWXDefaultProvider) {
        print("providerDidEndRequest")
    }

    func providerDidStartRequest(_: AWXDefaultProvider) {
        print("providerDidStartRequest")
    }

    func provider(_: AWXDefaultProvider, shouldHandle nextAction: AWXConfirmPaymentNextAction) {
        guard let actionClass = ClassToHandleNextActionForType(nextAction) as? AWXDefaultActionProvider.Type else {
            showAlert(NSLocalizedString("No provider matched the next action.", comment: ""), withTitle: nil)
            return
        }
        if let session {
            let actionProvider = actionClass.init(delegate: self, session: session)
            actionProvider.handle(nextAction)
            provider = actionProvider
        } else {
            return
        }
    }

    func provider(_: AWXDefaultProvider, shouldPresent controller: UIViewController?, forceToDismiss _: Bool, withAnimation: Bool) {
        if let controller {
            if controller is UINavigationController {
                present(controller, animated: withAnimation)
            } else {
                navigationController?.pushViewController(controller, animated: withAnimation)
            }
        }
    }

    func provider(_: AWXDefaultProvider, shouldInsert controller: UIViewController?) {
        if let controller {
            addChild(controller)
            controller.view.frame = CGRectInset(view.frame, 0, CGRectGetMaxY(view.bounds))
            view.addSubview(controller.view)
            controller.didMove(toParent: self)
        }
    }
}

extension FlowWithoutUIViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentModeTableCell", for: indexPath)
        cell.textLabel?.text = dataArray[indexPath.row]
        cell.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousIndexPath = IndexPath(row: selectedIndex, section: 0)
        let previousCell = tableView.cellForRow(at: previousIndexPath)
        previousCell?.accessoryType = .none

        selectedIndex = indexPath.row
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.accessoryType = .checkmark

        checkoutMode = AirwallexCheckoutMode(rawValue: indexPath.row) ?? .oneOff
        payWithCardDetailAndSaveButton.isEnabled = indexPath.row != 1
        applepayButton.isEnabled = indexPath.row == 0
    }
}

extension FlowWithoutUIViewController: SavedCardViewDelegate {
    func consentSelected(_ consent: AWXPaymentConsent) {
        if consent.paymentMethod?.card?.numberType == "PAN" {
            showPayment(consent)
        } else if let session {
            let provider = AWXDefaultProvider(delegate: self, session: session)
            provider.confirmPaymentIntent(with: consent.paymentMethod ?? AWXPaymentMethod(type: nil, id: nil, billing: nil, card: nil, additionalParams: nil, customerId: nil), paymentConsent: consent, device: nil)
            self.provider = provider
        }
    }

    private func showPayment(_ paymentConsent: AWXPaymentConsent) {
        let cv = AWXPaymentViewController(shownDirectly: true, isFlowFromPushing: true)
        cv.delegate = AWXUIContext.shared().delegate
        if let session {
            cv.session = session
        }
        cv.paymentConsent = paymentConsent
        navigationController?.pushViewController(cv, animated: true)
    }
}
