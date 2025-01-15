//
//  CartViewController.swift
//  Examples
//
//  Created by Hector.Huang on 2024/9/6.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Airwallex
import UIKit

class CartViewController: UIViewController {
    private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var checkoutButton: UIButton!
    
    var products: [Product] = .init()
    var shipping: AWXPlaceDetails?
    var apiClient: APIClient!
    private var applePayProvider: AWXApplePayProvider?
    private var redirectProvider: AWXRedirectActionProvider?
    
    private var checkoutMode: AirwallexCheckoutMode? {
        AirwallexCheckoutMode(rawValue: UserDefaults.standard.integer(forKey: kCachedCheckoutMode))
    }
    
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
    
    lazy var applePayOptions: AWXApplePayOptions = {
        let options = AWXApplePayOptions(merchantIdentifier: applePayMerchantId)
        options.additionalPaymentSummaryItems = [.init(label: "goods", amount: 2), .init(label: "tax", amount: 1)]
        options.totalPriceLabel = "COMPANY, INC."
        options.requiredBillingContactFields = [.postalAddress]
        return options
    }()
    
    private var apiKey: String? {
        AirwallexExamplesKeys.shared().apiKey.nilIfEmpty
    }
    private var clientID: String? {
        AirwallexExamplesKeys.shared().clientId.nilIfEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCartData()
        setupSDK()
    }
    
    private func setupViews() {
        view.backgroundColor = AWXTheme.shared().primaryBackgroundColor()
        titleLabel.textColor = AWXTheme.shared().primaryTextColor()

        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        view.addSubview(activityIndicator)
    }

    private func setupCartData() {
        let product0 = Product(name: "AirPods Pro", detail: "Free engraving x 1", price: 399)
        let product1 = Product(name: "HomePod", detail: "White x 1", price: 469)
        products = [product0, product1]

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
        self.shipping = AWXPlaceDetails.decode(fromJSON: shipping) as? AWXPlaceDetails
    }

    private func setupSDK() {
        // Step 1: Use a preset mode (Note: test mode as default)
        //    [Airwallex setMode:AirwallexSDKTestMode];
        // Or set base URL directly
        let mode = AirwallexExamplesKeys.shared().environment
        Airwallex.setMode(mode)

        // You can disable sending Analytics data or printing local logs
        //    Airwallex.disableAnalytics()

        // you can enable local log file
        //    Airwallex.enableLocalLogFile()

        // Theme customization
        //    let tintColor = UIColor.systemPink
        //    AWXTheme.shared().tintColor = tintColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicator.center = view.center
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    func reloadData() {
        let amount = AirwallexExamplesKeys.shared().amount
        let currency = AirwallexExamplesKeys.shared().currency
        let countryCode = AirwallexExamplesKeys.shared().countryCode
        let returnUrl = AirwallexExamplesKeys.shared().returnUrl

        checkoutButton.isEnabled = shipping != nil && Decimal(string: amount)! > 0 && !currency.isEmpty && !countryCode.isEmpty && !returnUrl.isEmpty

        let checkoutTitle = if (UserDefaults.standard.bool(forKey: kCachedApplePayMethodOnly)) {
            "Pay"
        } else if (UserDefaults.standard.bool(forKey: kCachedRedirectPayOnly)) {
            "Pay by redirection"
        } else if (UserDefaults.standard.bool(forKey: kCachedCardMethodOnly)) {
            "Pay by card"
        } else {
            "Checkout"
        }
        checkoutButton.setTitle(checkoutTitle, for: .normal)
        tableView.reloadData()
    }
    
    private func startAnimating() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }

    private func stopAnimating() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    @IBAction private func menuPressed(_ sender: UIBarButtonItem) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "WeChat Demo", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "showWeChatDemo", sender: nil)
        }))
        controller.addAction(UIAlertAction(title:"H5 Demo", style:.default, handler: { _ in
            self.performSegue(withIdentifier: "showH5Demo", sender: nil)
        }))
        controller.addAction(UIAlertAction(title:"Settings", style:.default, handler: { _ in
            if let optionsVC = UIStoryboard(name: "Main", bundle: nil).createOptionsViewController() {
                self.navigationController?.pushViewController(optionsVC, animated: true)
            }
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        let popPresenter = controller.popoverPresentationController
        popPresenter?.barButtonItem = sender

        present(controller, animated: true)
    }
    
    @IBAction private func checkoutPressed(_ sender: UIButton) {
        guard let checkoutMode else {
            showAlert("Checkout Mode is not set", withTitle: nil)
            return
        }
        
        let customerID = UserDefaults.standard.string(forKey: kCachedCustomerID)
        
        switch (checkoutMode) {
        case .oneOffMode, .recurringWithIntentMode:
            startAnimating()
            // get intent from your server for one-off or recurringWithIntent session, can ignore customer ID if guest checkout
            apiClient.createPaymentIntent(request: createPaymentIntentRequest(customerID: customerID), completion: { [weak self] result in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.stopAnimating()
                    switch result {
                    case .success(let paymentIntent):
                        // Step 2: Set client secret from payment intent
                        AWXAPIClientConfiguration.shared().clientSecret = paymentIntent.clientSecret
                        
                        // Step 3: Create AWXSession
                       let session = self.createSession(paymentIntent: paymentIntent, mode: checkoutMode)
                        
                        // Step 4: Present payment flow
                        self.presentPaymentFlow(session: session)
                    case .failure(let error):
                        self.showAlert(error.localizedDescription, withTitle: nil)
                    }
                }
            })
        case .recurringMode:
            guard let customerID else {
                showAlert("Customer ID is not set", withTitle: nil)
                return
            }
            
            startAnimating()
            // get client secret for recurring session
            apiClient.generateClientSecret(customerID: customerID, apiKey: apiKey, clientID: clientID, completion: { [weak self] result in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.stopAnimating()
                    switch result {
                    case .success(let clientSecret):
                        // Step 2: Set client secret
                        AWXAPIClientConfiguration.shared().clientSecret = clientSecret
                        
                        // Step 3: Create AWXSession
                        let session = self.createSession(mode: .recurringMode)
                        
                        // Step 4: Present recurring flow
                        self.presentPaymentFlow(session: session)
                    case .failure(let error):
                        self.showAlert(error.localizedDescription, withTitle: nil)
                    }
                }
            })
        }
    }
    
    private func presentPaymentFlow(session: AWXSession) {
        // Apple Pay low-level API integration
        if (UserDefaults.standard.bool(forKey: kCachedApplePayMethodOnly)) {
            let applePayProvider = AWXApplePayProvider(delegate: self, session: session)
            applePayProvider.startPayment()
            self.applePayProvider = applePayProvider
            return
        }
        // Redirect Pay low-level API integration
        if (UserDefaults.standard.bool(forKey: kCachedRedirectPayOnly)) {
            let redirectProvider = AWXRedirectActionProvider(delegate: self, session: session)
            redirectProvider.confirmPaymentIntent(with: "paypal", additionalInfo: ["shopper_name": "Hector", "country_code": "CN"])
            self.redirectProvider = redirectProvider
            return
        }
        
        // Basic integration
        let context = AWXUIContext.shared()
        context.delegate = self
        context.session = session
        if (UserDefaults.standard.bool(forKey: kCachedCardMethodOnly)) {
            context.presentCardPaymentFlow(from: self, cardSchemes: [.visa, .mastercard])
        } else {
//            context.presentEntirePaymentFlow(from: self)
            context.presentPaymentViewController(from: self)
        }
    }
    
    private func createSession(paymentIntent: AWXPaymentIntent? = nil, mode: AirwallexCheckoutMode) -> AWXSession {
        switch mode {
        case .oneOffMode:
            let session = AWXOneOffSession()
            
            session.applePayOptions = applePayOptions
            session.countryCode = AirwallexExamplesKeys.shared().countryCode
            session.billing = shipping
            session.returnURL = AirwallexExamplesKeys.shared().returnUrl
            session.paymentIntent = paymentIntent
            session.autoCapture = UserDefaults.standard.bool(forKey: kCachedAutoCapture)
            
            // you can configure the payment method list manually.(But only available ones in your account will be displayed)
//            session.paymentMethods = ["card"]
//            session.hidePaymentConsents = true
            return session
        case .recurringMode:
            let session = AWXRecurringSession()
            
            session.applePayOptions = applePayOptions
            session.countryCode = AirwallexExamplesKeys.shared().countryCode
            session.billing = shipping
            session.returnURL = AirwallexExamplesKeys.shared().returnUrl
            session.setCurrency(AirwallexExamplesKeys.shared().currency)
            session.setAmount(NSDecimalNumber(string: AirwallexExamplesKeys.shared().amount))
            session.setCustomerId(UserDefaults.standard.string(forKey: kCachedCustomerID))
            session.nextTriggerByType = AirwallexNextTriggerByType(rawValue: UInt(UserDefaults.standard.integer(forKey: kCachedNextTriggerBy)))!
            session.setRequiresCVC(UserDefaults.standard.bool(forKey: kCachedRequiresCVC))
            session.merchantTriggerReason = .unscheduled
            return session
        case .recurringWithIntentMode:
            let session = AWXRecurringWithIntentSession()
            
            session.applePayOptions = applePayOptions
            session.countryCode = AirwallexExamplesKeys.shared().countryCode
            session.billing = shipping
            session.returnURL = AirwallexExamplesKeys.shared().returnUrl
            session.paymentIntent = paymentIntent
            session.nextTriggerByType = AirwallexNextTriggerByType(rawValue: UInt(UserDefaults.standard.integer(forKey: kCachedNextTriggerBy)))!
            session.setRequiresCVC(UserDefaults.standard.bool(forKey: kCachedRequiresCVC))
            session.autoCapture = UserDefaults.standard.bool(forKey: kCachedAutoCapture)
            session.merchantTriggerReason = .scheduled
            return session
        }
    }
    
    private func createPaymentIntentRequest(customerID: String?) -> PaymentIntentRequest {
        PaymentIntentRequest(
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
            customerID: customerID,
            paymentMethodOptions: AirwallexExamplesKeys.shared().force3DS ? ["card": ["three_ds_action": "FORCE_3DS"]] : nil,
            apiKey: apiKey,
            clientID: clientID
        )
    }
    
    private func handlePaymentResult(status: AirwallexPaymentStatus, error: Error?) {
        switch status {
        case .success:
            self.showAlert("Your payment has been charged", withTitle: "Payment successful")
        case .inProgress:
            print("Payment in progress, you should check payment status from time to time from backend and show result to the payer")
        case .failure:
            self.showAlert(error?.localizedDescription ?? "There was an error while processing your payment. Please try again.", withTitle: "Payment failed")
        case .cancel:
            break
            // wpdebug
//            self.showAlert("Your payment has been cancelled", withTitle: "Payment cancelled")
        }
    }
}

extension CartViewController: AWXPaymentResultDelegate {
    func paymentViewController(_ controller: UIViewController, didCompleteWith status: AirwallexPaymentStatus, error: Error?) {
        controller.dismiss(animated: true) {
            self.handlePaymentResult(status: status, error: error)
        }
    }
}

// ApplePayProvider delegate methods, no need to conform to if using AWXUIContext
extension CartViewController: AWXProviderDelegate {
    func provider(_ provider: AWXDefaultProvider, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
        handlePaymentResult(status: status, error: error)
    }
    
    func providerDidStartRequest(_ provider: AWXDefaultProvider) {
    }
    
    func providerDidEndRequest(_ provider: AWXDefaultProvider) {
    }
    
    func provider(_ provider: AWXDefaultProvider, didInitializePaymentIntentId paymentIntentId: String) {
    }
}
