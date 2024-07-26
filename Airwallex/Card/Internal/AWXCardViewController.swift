//
//  AWXCardViewController.swift
//  Card
//
//  Created by Tony He (CTR) on 2024/7/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
import AirRisk


@objcMembers
@objc
public class AWXCardViewController: UIViewController {
    
    public var viewModel: AWXCardViewModel?
    public var provider: AWXDefaultProvider?
    public var session: AWXSession?
    
    private(set) lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    public lazy var container: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        sv.spacing = 16.0
        sv.layoutMargins = .init(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        sv.isLayoutMarginsRelativeArrangement = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    public lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = NSLocalizedString("Card", comment: "Card")
        lb.textColor = UIColor.airwallexPrimaryText
        lb.font = UIFont.airwallexTitle
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    public lazy var cardNoField: AWXFloatingCardTextField = {
        let tf = AWXFloatingCardTextField()
        tf.cardBrands = viewModel?.makeDisplayedCardBrands()
        tf.validationMessageCallback = { [weak self] cardNumber in
            self?.viewModel?.validationMessageFromCardNumber(cardNumber ?? "")
        }
        tf.brandUpdateCallback = { [weak self] brand in
            guard let self = self else { return }
            self.currentBrand = brand
            if self.saveCard && brand == AWXBrandTypeUnionPay {
                self.addUnionPayWarningViewIfNecessary()
            } else {
                self.warningView.removeFromSuperview()
            }
        }
        tf.isRequired = true
        tf.placeholder = "1234 1234 1234 1234"
        tf.floatingText = NSLocalizedString("Card number", comment : "Card number")
        tf.delegate = self
        return tf
    }()
    public lazy var nameField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .nameOnCard
        tf.placeholder = NSLocalizedString("Name on card", comment: "Name on card")
        tf.isRequired = true
        tf.delegate = self
        return tf
    }()
    public lazy var cvcStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 5.0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    public lazy var expiresField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .expires
        tf.placeholder = NSLocalizedString("Expires MM / YY", comment: "Expires MM / YY")
        tf.isRequired = true
        tf.delegate = self
        return tf
    }()
    public lazy var cvcField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .CVC
        tf.placeholder = NSLocalizedString("CVC / CVV", comment: "CVC / CVV")
        tf.isRequired = true
        tf.delegate = self
        return tf
    }()
    public lazy var billingStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        sv.spacing = 16.0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    public lazy var billingLabel: UILabel = {
        let lb = UILabel()
        lb.text = NSLocalizedString("Billing info", comment: "Billing info")
        lb.textColor = UIColor.airwallexPrimaryText
        lb.font = UIFont.airwallexSubhead2
        return lb
    }()
    public lazy var firstNameField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .firstName
        tf.placeholder = NSLocalizedString("First name", comment: "First Name")
        tf.isRequired = true
        return tf
    }()
    public lazy var lastNameField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .lastName
        tf.placeholder = NSLocalizedString("Last name", comment: "Last Name")
        tf.isRequired = true
        return tf
    }()
    public lazy var countryView: AWXFloatingLabelView = {
        let lv = AWXFloatingLabelView()
        lv.placeholder = NSLocalizedString("Country / Region", comment: "Country / Region")
        lv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectCountries)))
        return lv
    }()
    public lazy var stateField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .state
        tf.placeholder = NSLocalizedString("State", comment: "State")
        tf.isRequired = true
        return tf
    }()
    public lazy var cityField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .city
        tf.placeholder = NSLocalizedString("City", comment: "City")
        tf.isRequired = true
        return tf
    }()
    public lazy var streetField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .street
        tf.placeholder = NSLocalizedString("Street", comment: "Street")
        tf.isRequired = true
        return tf
    }()
    public lazy var zipCodeField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .zipcode
        tf.placeholder = NSLocalizedString("Zip code (optional)", comment: "Zip code (optional)")
        return tf
    }()
    public lazy var emailField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .email
        tf.placeholder = NSLocalizedString("Email (optional)", comment: "Email (optional)")
        return tf
    }()
    public lazy var phoneNumberField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .phoneNumber
        tf.placeholder = NSLocalizedString("Phone number (optional)", comment: "Phone number (optional)")
        return tf
    }()
    public lazy var confirmButton: AWXActionButton = {
        let btn = AWXActionButton()
        btn.isEnabled = true
        btn.setTitle(viewModel?.ctaTitle ?? "", for: .normal)
        btn.addTarget(self, action: #selector(confirmPayment), for: .touchUpInside)
        btn.heightAnchor.constraint(equalToConstant: 52.0).isActive = true
        return btn
    }()
    public lazy var saveCardSwitchContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 23.0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    public lazy var saveCardSwitch: UISwitch = {
        let sw = UISwitch()
        sw.addTarget(self, action: #selector(saveCardSwitchChanged(_:)), for: .valueChanged)
        return sw
    }()
    public lazy var saveCardLabel: UILabel = {
        let lb = UILabel()
        lb.text = NSLocalizedString("Save this card for future payments", comment: "Save this card for future payments")
        lb.textColor = UIColor.airwallexSecondaryText
        lb.font = UIFont.airwallexSubhead1
        return lb
    }()
    public lazy var addressSwitchContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 23.0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    public lazy var addressSwitch: UISwitch = {
        let sw = UISwitch()
        sw.addTarget(self, action: #selector(addressSwitchChanged(_:)), for: .valueChanged)
        return sw
    }()
    public lazy var addressLabel: UILabel = {
        let lb = UILabel()
        lb.text = NSLocalizedString("Same as shipping address", comment: "Same as shipping address")
        lb.textColor = UIColor.airwallexSecondaryText
        lb.font = UIFont.airwallexSubhead1
        return lb
    }()
    
    public lazy var warningView: AWXWarningView = {
        AWXWarningView.init(message: "For UnionPay, only credit cards can be saved. Click “Pay” to proceed with a one time payment or use another card if you would like to save it for future use.")
    }()
    public var currentBrand: AWXBrandType?
    public var paymentMethodType: AWXPaymentMethodType?

    public var saveCard: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AirwallexRisk.log(event: "show_create_card", screen: "page_create_card")
        registerKeyboard()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboard()
    }
    
    func startIndicator() {
        startAnimating()
        confirmButton.isEnabled = false
    }
    
    func stopIndicator() {
        stopAnimating()
        confirmButton.isEnabled = true
    }
    
    func setupViews() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close", in: Bundle.resource()), style: .plain, target: self, action: #selector(close))
        
        enableTapToEndEditing()
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(container)
        
        let views = ["scrollView": scrollView,
                     "stackView":container]
        let metrics = ["margin": 16.0,
                       "padding": 33.0]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", metrics: metrics, views: views))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView(==scrollView)]|", metrics: metrics, views: views))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", metrics: metrics, views: views))
        
        container.addArrangedSubview(titleLabel)
        container.addArrangedSubview(cardNoField)
        container.addArrangedSubview(nameField)
        container.addArrangedSubview(cvcStackView)
        cvcStackView.addArrangedSubview(expiresField)
        cvcStackView.addArrangedSubview(cvcField)
        
        expiresField.widthAnchor.constraint(equalTo: cvcField.widthAnchor, multiplier: 1.7).isActive = true

        saveCardSwitchContainer.addArrangedSubview(saveCardLabel)
        saveCardSwitchContainer.addArrangedSubview(saveCardSwitch)
        if viewModel?.isCardSavingEnabled == true {
            container.addArrangedSubview(saveCardSwitchContainer)
        }
        if viewModel?.isBillingInformationRequired == true {
            container.addArrangedSubview(billingStackView)
            billingStackView.addArrangedSubview(addressSwitchContainer)
            addressSwitchContainer.addArrangedSubview(addressLabel)
            addressSwitchContainer.addArrangedSubview(addressSwitch)
            billingStackView.addArrangedSubview(firstNameField)
            billingStackView.addArrangedSubview(lastNameField)
            billingStackView.addArrangedSubview(countryView)
            billingStackView.addArrangedSubview(stateField)
            billingStackView.addArrangedSubview(cityField)
            billingStackView.addArrangedSubview(streetField)
            billingStackView.addArrangedSubview(zipCodeField)
            billingStackView.addArrangedSubview(emailField)
            billingStackView.addArrangedSubview(phoneNumberField)
            
            firstNameField.next = lastNameField
            
            phoneNumberField.next = stateField
            stateField.next = cityField
            cityField.next = streetField
            streetField.next = zipCodeField
            zipCodeField.next = emailField
            emailField.next = phoneNumberField
        }
        
        container.addArrangedSubview(confirmButton)
        
        cardNoField.next = nameField
        nameField.next = expiresField
        expiresField.next = cvcField
        
        if let billing = viewModel?.initialBilling {
            firstNameField.setText(billing.firstName ?? "", animated: false)
            lastNameField.setText(billing.lastName ?? "", animated: false)
            emailField.setText(billing.email ?? "", animated: false)
            phoneNumberField.setText(billing.phoneNumber ?? "", animated: false)
            
            let address = billing.address
            if address != nil {
                countryView.setText(viewModel?.selectedCountry?.countryName ?? "", animated: false)
                stateField.setText(address?.state ?? "", animated: false)
                cityField.setText(address?.city ?? "", animated: false)
                streetField.setText(address?.street ?? "", animated: false)
                zipCodeField.setText(address?.postcode ?? "", animated: false)
            }
        }
        setBillingInputHidden(isHidden: viewModel?.isReusingShippingAsBillingInformation == true)
        addressSwitch.isOn = viewModel?.isReusingShippingAsBillingInformation == true
        saveCard = false
    }


    func addUnionPayWarningViewIfNecessary() {
        for (index,subview) in container.arrangedSubviews.enumerated() {
            if subview == saveCardSwitchContainer && container.arrangedSubviews[index + 1] != warningView {
                container.insertArrangedSubview(warningView, at: index + 1)
            }
        }
    }

    func saveCardSwitchChanged(_ sender: UISwitch) {
        saveCard = sender.isOn
        if saveCard, currentBrand == AWXBrandTypeUnionPay {
            addUnionPayWarningViewIfNecessary()
        } else {
            warningView.removeFromSuperview()
        }
        
        if saveCard {
            AWXAnalyticsLogger.shared().logAction(withName: "save_card")
        }
    }
    
    func addressSwitchChanged(_ sender: UISwitch) {
        do {
            try viewModel?.setReusesShippingAsBillingInformation(sender.isOn)
        } catch {
            let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .cancel){ _ in sender.isOn = !sender.isOn })
            present(alert, animated: true)
            return
        }
        setBillingInputHidden(isHidden: viewModel?.isReusingShippingAsBillingInformation ?? true)
        AWXAnalyticsLogger.shared().logAction(withName: "toggle_billing_address")
    }
    
    func setBillingInputHidden(isHidden:Bool) {
        firstNameField.isHidden = isHidden
        lastNameField.isHidden = isHidden
        countryView.isHidden = isHidden
        stateField.isHidden = isHidden
        cityField.isHidden = isHidden
        streetField.isHidden = isHidden
        zipCodeField.isHidden = isHidden
        emailField.isHidden = isHidden
        phoneNumberField.isHidden = isHidden
    }
    
    func selectCountries() {
        let controller = AWXCountryListViewController.init(nibName: nil, bundle: nil)
        controller.delegate = self
        controller.currentCountry = viewModel?.selectedCountry
        present(controller, animated: true)
    }
    
    func confirmPayment() {
        AWXAnalyticsLogger.shared().logAction(withName: "tap_pay_button")
        AirwallexRisk.log(event: "click_payment_button", screen: "page_create_card")
        logMessage("Start payment. Intent ID: \(session?.paymentIntentId() ?? "")")
        if let provider = viewModel?.preparedProviderWithDelegate(self) {
            
            do {
                try viewModel?.confirmPayment(provider: provider, billing: makeBilling(), card: makeCard(), shouldStoreCardDetails: saveCard)
                
                self.provider = provider
            } catch {
                let alert = UIAlertController(title: nil, message: error.localizedDescription as String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .cancel, handler: nil))
                present(alert, animated: true)
                
                AWXAnalyticsLogger.shared().logAction(withName: "card_payment_validation", additionalInfo: ["message": error])
                logMessage("Payment failed. Intent ID: \(session?.paymentIntentId() ?? ""). Reason: \(error).")
            }
        }
    }
    
    func makeBilling() -> AWXPlaceDetails {
        let address =  viewModel?.makeBilling(FirstName: firstNameField.text(), lastName: lastNameField.text(), email: emailField.text(), phoneNumber: phoneNumberField.text(), state: stateField.text(), city: cityField.text(), street: streetField.text(), postcode: zipCodeField.text())
        return address ?? AWXPlaceDetails()
    }
    
    func makeCard() -> AWXCard {
        let card = viewModel?.makeCard(name: nameField.text(), number: cardNoField.text(), expiry: expiresField.text(), cvc: cvcField.text())
        return card ?? AWXCard()
    }
    
}


extension AWXCardViewController: AWXFloatingLabelTextFieldDelegate {
    
    public func floatingLabelTextField(_ floatingLabelTextField: AWXFloatingLabelTextField, textFieldShouldBeginEditing textField: UITextField) -> Bool {
        switch textField {
        case cardNoField.textField:
            AirwallexRisk.log(event: "input_card_number", screen: "page_create_card")
        case cvcField.textField:
            AirwallexRisk.log(event: "input_card_cvc", screen: "page_create_card")
        case expiresField.textField:
            AirwallexRisk.log(event: "input_card_expiry", screen: "page_create_card")
        case nameField.textField:
            AirwallexRisk.log(event: "input_card_holder_name", screen: "page_create_card")
        default:
            break
        }
        return true
    }
    
}


extension AWXCardViewController: AWXCountryListViewControllerDelegate {
    public func countryListViewController(_ controller: AWXCountryListViewController, didSelect country: AWXCountry) {
        controller .dismiss(animated: true)
        viewModel?.selectedCountry = country
        countryView.setText(country.countryName, animated: false)
    }

}


extension AWXCardViewController {
    
    func registerKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unregisterKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func keyboardWillChangeFrame(_ notification: Notification) {
        if let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = CGRectGetHeight(rect)
            scrollView.contentInset.bottom = keyboardHeight
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
        }
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.verticalScrollIndicatorInsets = .zero
    }
    
}

extension AWXCardViewController: AWXProviderDelegate {
    public func providerDidStartRequest(_ provider: AWXDefaultProvider) {
        logMessage("providerDidStartRequest:")
        startIndicator()
    }
    
    public func providerDidEndRequest(_ provider: AWXDefaultProvider) {
        logMessage("providerDidEndRequest:")
        stopIndicator()
    }
    
    public func provider(_ provider: AWXDefaultProvider, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
        logMessage("provider:didCompleteWithStatus:error: \(status)  \(error?.localizedDescription ?? "")")
        
        dismiss(animated: true) {
            let delegate = AWXUIContext.shared().delegate
            delegate?.paymentViewController(self, didCompleteWith: status, error: error)
            self.logMessage("Delegate: \(delegate?.description ?? ""), paymentViewController:didCompleteWithStatus:error: \(self.presentationController?.description ?? "")  \(status)  \(error?.localizedDescription ?? "")")
        }
    }
    
    public func provider(_ provider: AWXDefaultProvider, didCompleteWithPaymentConsentId Id: String) {
        let delegate = AWXUIContext.shared().delegate
        if delegate?.responds(to: #selector(AWXPaymentResultDelegate.paymentViewController(_:didCompleteWithPaymentConsentId:))) == true {
            delegate?.paymentViewController?(self, didCompleteWithPaymentConsentId: Id)
        }
    }
    
    public func provider(_ provider: AWXDefaultProvider, didInitializePaymentIntentId paymentIntentId: String) {
        logMessage("provider:didInitializePaymentIntentId:  \(paymentIntentId)")
        viewModel?.updatePaymentIntentId(paymentIntentId)
    }
    
    public func provider(_ provider: AWXDefaultProvider, shouldHandle nextAction: AWXConfirmPaymentNextAction) {
        logMessage("provider:shouldHandleNextAction:  type:\(nextAction.type), stage: \(nextAction.stage ?? "")")
        let actionProvider = viewModel?.actionProviderForNextAction( nextAction, delegate: self)
        if actionProvider == nil {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("No provider matched the next action.", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        actionProvider?.handle(nextAction)
        self.provider = actionProvider
    }
    
    public func provider(_ provider: AWXDefaultProvider, shouldPresent controller: UIViewController?, forceToDismiss: Bool, withAnimation: Bool) {
        if forceToDismiss {
            presentedViewController?.dismiss(animated: true) {
                if let controller = controller {
                    self.present(controller, animated: withAnimation)
                }
            }
        } else if let controller = controller {
            self.present(controller, animated: withAnimation)
        }
    }
    
    public func provider(_ provider: AWXDefaultProvider, shouldInsert controller: UIViewController?) {
        if let controller = controller {
            addChild(controller)
            view.addSubview(controller.view)
            controller.didMove(toParent: self)
        }
    }
}
