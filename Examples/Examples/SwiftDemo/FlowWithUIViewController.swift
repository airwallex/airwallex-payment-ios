//
//  FlowWithUIViewController.swift
//  SwiftExamples
//
//  Created by Tony He (CTR) on 2024/8/12.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

enum AirwallexCheckoutMode: Int {
    case oneOff
    case recurring
    case recurringWithIntent
}

class FlowWithUIViewController: UIViewController {
    enum AirwallexFlowMode {
        case presentEntire
        case pushEntire
        case presentCustomEntire
        case pushCustomEntire
        case presentCard
        case pushCard
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

    private lazy var presentPaymentListButton: UIButton = createButton(title: "present payment list")
    private lazy var pushPaymentListButton: UIButton = createButton(title: "push payment list")
    private lazy var presentCustomPaymentListButton: UIButton = createButton(title: "present custom payment list")
    private lazy var pushCustomPaymentListButton: UIButton = createButton(title: "push custom payment list")
    private lazy var presentCardPaymentButton: UIButton = createButton(title: "present card payment")
    private lazy var pushCardPaymentButton: UIButton = createButton(title: "push card payment")

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.hidesWhenStopped = true
        return ai
    }()

    private var paymentIntent: AWXPaymentIntent?
    private var applePayProvider: AWXApplePayProvider?
    private var provider: AWXDefaultProvider?
    private var flowMode: AirwallexFlowMode = .presentEntire
    private var session: AWXSession?

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
         activityIndicator].forEach { view.addSubview($0) }

        [presentPaymentListButton,
         pushPaymentListButton,
         presentCustomPaymentListButton,
         pushCustomPaymentListButton,
         presentCardPaymentButton,
         pushCardPaymentButton].forEach { scroll.addSubview($0) }

        let constraints = [
            paymentModeTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            paymentModeTable.leftAnchor.constraint(equalTo: view.leftAnchor),
            paymentModeTable.rightAnchor.constraint(equalTo: view.rightAnchor),
            paymentModeTable.heightAnchor.constraint(equalToConstant: 140),

            scroll.topAnchor.constraint(equalTo: paymentModeTable.bottomAnchor, constant: 10.0),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ]

        var allConstraints = constraints
        allConstraints.append(contentsOf: setupButtonConstraints(presentPaymentListButton, topAnchor: scroll.topAnchor))
        allConstraints.append(contentsOf: setupButtonConstraints(pushPaymentListButton, topAnchor: presentPaymentListButton.bottomAnchor))
        allConstraints.append(contentsOf: setupButtonConstraints(presentCustomPaymentListButton, topAnchor: pushPaymentListButton.bottomAnchor))
        allConstraints.append(contentsOf: setupButtonConstraints(pushCustomPaymentListButton, topAnchor: presentCustomPaymentListButton.bottomAnchor))
        allConstraints.append(contentsOf: setupButtonConstraints(presentCardPaymentButton, topAnchor: pushCustomPaymentListButton.bottomAnchor))
        allConstraints.append(contentsOf: setupButtonConstraints(pushCardPaymentButton, topAnchor: presentCardPaymentButton.bottomAnchor))
        allConstraints.append(pushCardPaymentButton.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -30))

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

    private func setupExamplesAPIClient() {
        APIClient.shared().apiKey = AirwallexExamplesKeys.shared().apiKey
        APIClient.shared().clientID = AirwallexExamplesKeys.shared().clientId
    }

    @objc private func mainButtonTapped(_ button: UIButton) {
        switch button {
        case presentPaymentListButton:
            flowMode = .presentEntire
        case pushPaymentListButton:
            flowMode = .pushEntire
        case presentCustomPaymentListButton:
            flowMode = .presentCustomEntire
        case pushCustomPaymentListButton:
            flowMode = .pushCustomEntire
        case presentPaymentListButton:
            flowMode = .presentCard
        case pushCardPaymentButton:
            flowMode = .pushCard
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
        case .presentEntire:
            context.presentEntirePaymentFlow(from: self)
        case .pushEntire:
            context.pushEntirePaymentFlow(from: self)
        case .presentCustomEntire:
            session.paymentMethods = ["PayPal", "card", "alipaycn"]
            context.presentEntirePaymentFlow(from: self)
        case .pushCustomEntire:
            session.paymentMethods = ["PayPal", "card", "alipaycn"]
            context.pushEntirePaymentFlow(from: self)
        case .presentCard:
            let cardSchemes = [AWXCardBrand.visa, .mastercard, .amex, .unknown, .JCB]
            context.presentCardPaymentFlowFrom(self, cardSchemes: cardSchemes)
        case .pushCard:
            let cardSchemes = [AWXCardBrand.visa, .mastercard, .amex, .unknown, .JCB]
            context.pushCardPaymentFlowFrom(self, cardSchemes: cardSchemes)
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
        showAlert(NSLocalizedString("Your payment has been charged", comment: ""), withTitle: NSLocalizedString("Payment successful", comment: ""))
    }

    private func showPaymentFailure(_ error: Error?) {
        let message = error?.localizedDescription ?? NSLocalizedString("There was an error while processing your payment. Please try again.", comment: "")
        showAlert(message, withTitle: NSLocalizedString("Payment failed", comment: ""))
    }

    private func showPaymentCancel() {
        showAlert(NSLocalizedString("Your payment has been cancelled", comment: ""), withTitle: NSLocalizedString("Payment cancelled", comment: ""))
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

extension FlowWithUIViewController: AWXPaymentResultDelegate {
    func paymentViewController(_: UIViewController, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
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

extension FlowWithUIViewController: AWXProviderDelegate {
    func provider(_: AWXDefaultProvider, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
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

extension FlowWithUIViewController: UITableViewDelegate, UITableViewDataSource {
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
    }
}
