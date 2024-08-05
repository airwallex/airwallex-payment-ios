//
//  AWXCardViewController.swift
//  Card
//
//  Created by Tony He (CTR) on 2024/7/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import AirwallexRisk
import UIKit

@objcMembers
@objc
public class AWXCardViewController: UIViewController {
    public var viewModel: AWXCardViewModel?
    private var session: AWXSession? { viewModel?.session }

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var container: UIStackView = {
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

    private lazy var titleStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 16.0
        return sv
    }()

    private lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = NSLocalizedString("Card", comment: "Card")
        lb.textColor = UIColor.airwallexPrimaryText
        lb.font = UIFont.airwallexTitle
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private lazy var cardNoField: AWXFloatingCardTextField = {
        let tf = AWXFloatingCardTextField()
        tf.cardBrands = viewModel?.makeDisplayedCardBrands()
        tf.validationMessageCallback = { [weak self] cardNumber in
            self?.viewModel?.validationMessageFromCardNumber(cardNumber ?? "")
        }
        tf.brandUpdateCallback = { [weak self] brand in
            guard let self = self else { return }
            self.currentBrand = AWXBrandType(rawValue: brand)
            if self.saveCard && brand == AWXBrandType.unionPay.rawValue {
                self.addUnionPayWarningViewIfNecessary()
            } else {
                self.warningView.removeFromSuperview()
            }
        }
        tf.isRequired = true
        tf.placeholder = "1234 1234 1234 1234"
        tf.floatingText = NSLocalizedString("Card number", comment: "Card number")
        tf.delegate = self
        return tf
    }()

    private lazy var nameField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .nameOnCard
        tf.placeholder = NSLocalizedString("Name on card", comment: "Name on card")
        tf.isRequired = true
        tf.delegate = self
        return tf
    }()

    private lazy var cvcStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 5.0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var expiresField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .expires
        tf.placeholder = NSLocalizedString("Expires MM / YY", comment: "Expires MM / YY")
        tf.isRequired = true
        tf.delegate = self
        return tf
    }()

    private lazy var cvcField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .CVC
        tf.placeholder = NSLocalizedString("CVC / CVV", comment: "CVC / CVV")
        tf.isRequired = true
        tf.delegate = self
        return tf
    }()

    private lazy var billingStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        sv.spacing = 16.0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var billingLabel: UILabel = {
        let lb = UILabel()
        lb.text = NSLocalizedString("Billing info", comment: "Billing info")
        lb.textColor = UIColor.airwallexPrimaryText
        lb.font = UIFont.airwallexSubhead2
        return lb
    }()

    private lazy var firstNameField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .firstName
        tf.placeholder = NSLocalizedString("First name", comment: "First Name")
        tf.isRequired = true
        return tf
    }()

    private lazy var lastNameField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .lastName
        tf.placeholder = NSLocalizedString("Last name", comment: "Last Name")
        tf.isRequired = true
        return tf
    }()

    private lazy var countryView: AWXFloatingLabelView = {
        let lv = AWXFloatingLabelView()
        lv.placeholder = NSLocalizedString("Country / Region", comment: "Country / Region")
        lv.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(selectCountries)))
        return lv
    }()

    private lazy var stateField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .state
        tf.placeholder = NSLocalizedString("State", comment: "State")
        tf.isRequired = true
        return tf
    }()

    private lazy var cityField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .city
        tf.placeholder = NSLocalizedString("City", comment: "City")
        tf.isRequired = true
        return tf
    }()

    private lazy var streetField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .street
        tf.placeholder = NSLocalizedString("Street", comment: "Street")
        tf.isRequired = true
        return tf
    }()

    private lazy var zipCodeField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .zipcode
        tf.placeholder = NSLocalizedString("Zip code (optional)", comment: "Zip code (optional)")
        return tf
    }()

    private lazy var emailField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .email
        tf.placeholder = NSLocalizedString("Email (optional)", comment: "Email (optional)")
        return tf
    }()

    private lazy var phoneNumberField: AWXFloatingLabelTextField = {
        let tf = AWXFloatingLabelTextField()
        tf.fieldType = .phoneNumber
        tf.placeholder = NSLocalizedString(
            "Phone number (optional)", comment: "Phone number (optional)"
        )
        return tf
    }()

    private lazy var confirmButton: AWXActionButton = {
        let btn = AWXActionButton()
        btn.isEnabled = true
        btn.setTitle(viewModel?.ctaTitle ?? "", for: .normal)
        btn.addTarget(self, action: #selector(confirmPayment), for: .touchUpInside)
        btn.heightAnchor.constraint(equalToConstant: 52.0).isActive = true
        return btn
    }()

    private lazy var saveCardSwitchContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 23.0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var saveCardSwitch: UISwitch = {
        let sw = UISwitch()
        sw.addTarget(self, action: #selector(saveCardSwitchChanged(_:)), for: .valueChanged)
        return sw
    }()

    private lazy var saveCardLabel: UILabel = {
        let lb = UILabel()
        lb.text = NSLocalizedString(
            "Save this card for future payments", comment: "Save this card for future payments"
        )
        lb.textColor = UIColor.airwallexSecondaryText
        lb.font = UIFont.airwallexSubhead1
        return lb
    }()

    private lazy var addressSwitchContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 23.0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var addressSwitch: UISwitch = {
        let sw = UISwitch()
        sw.addTarget(self, action: #selector(addressSwitchChanged(_:)), for: .valueChanged)
        return sw
    }()

    private lazy var addressLabel: UILabel = {
        let lb = UILabel()
        lb.text = NSLocalizedString("Same as shipping address", comment: "Same as shipping address")
        lb.textColor = UIColor.airwallexSecondaryText
        lb.font = UIFont.airwallexSubhead1
        return lb
    }()

    private lazy var warningView: AWXWarningView = .init(
        message:
        NSLocalizedString("For UnionPay, only credit cards can be saved. Click “Pay” to proceed with a one time payment or use another card if you would like to save it for future use.", comment: "For UnionPay, only credit cards can be saved. Click “Pay” to proceed with a one time payment or use another card if you would like to save it for future use.")
    )

    private lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close", in: Bundle.resource()), for: .normal)
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        return btn
    }()

    private var currentBrand: AWXBrandType?
    private var paymentMethodType: AWXPaymentMethodType?

    private var saveCard: Bool = false

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel?.delegate = self
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Risk.log(event: "show_create_card", screen: "page_create_card")
        registerKeyboard()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboard()
    }

    private func startIndicator() {
        startAnimating()
        confirmButton.isEnabled = false
    }

    private func stopIndicator() {
        stopAnimating()
        confirmButton.isEnabled = true
    }

    private func setupViews() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "close", in: Bundle.resource()), style: .plain, target: self,
            action: #selector(goBack)
        )
        closeButton.isHidden = navigationController != nil

        enableTapToEndEditing()
        view.backgroundColor = .white

        view.addSubview(scrollView)
        scrollView.addSubview(container)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            container.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            container.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            container.topAnchor.constraint(equalTo: scrollView.topAnchor),
            container.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])

        container.addArrangedSubview(titleStack)
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(closeButton)
        [cardNoField, nameField, cvcStackView].forEach {
            container.addArrangedSubview($0)
        }
        cvcStackView.addArrangedSubview(expiresField)
        cvcStackView.addArrangedSubview(cvcField)

        expiresField.widthAnchor.constraint(equalTo: cvcField.widthAnchor, multiplier: 1.7).isActive =
            true

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
            [firstNameField, lastNameField, countryView, stateField, cityField, streetField, zipCodeField, emailField, phoneNumberField].forEach {
                billingStackView.addArrangedSubview($0)
            }
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

    private func addUnionPayWarningViewIfNecessary() {
        for (index, subview) in container.arrangedSubviews.enumerated() {
            if subview == saveCardSwitchContainer && container.arrangedSubviews[index + 1] != warningView {
                container.insertArrangedSubview(warningView, at: index + 1)
            }
        }
    }

    func saveCardSwitchChanged(_ sender: UISwitch) {
        saveCard = sender.isOn
        if saveCard, currentBrand == AWXBrandType.unionPay {
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
            let alert = UIAlertController(
                title: nil, message: error.localizedDescription, preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .cancel) { _ in
                    sender.isOn = !sender.isOn
                })
            present(alert, animated: true)
            return
        }
        setBillingInputHidden(isHidden: viewModel?.isReusingShippingAsBillingInformation ?? true)
        AWXAnalyticsLogger.shared().logAction(withName: "toggle_billing_address")
    }

    private func setBillingInputHidden(isHidden: Bool) {
        [firstNameField,
         lastNameField,
         countryView,
         stateField,
         cityField,
         streetField,
         zipCodeField,
         emailField,
         phoneNumberField].forEach {
            $0.isHidden = isHidden
        }
    }

    func selectCountries() {
        let controller = AWXCountryListViewController(nibName: nil, bundle: nil)
        controller.delegate = self
        controller.currentCountry = viewModel?.selectedCountry
        present(controller, animated: true)
    }

    func confirmPayment() {
        AWXAnalyticsLogger.shared().logAction(withName: "tap_pay_button")
        Risk.log(event: "click_payment_button", screen: "page_create_card")
        logMessage("Start payment. Intent ID: \(session?.paymentIntentId() ?? "")")
        if let provider = viewModel?.preparedProviderWithDelegate() {
            do {
                try viewModel?.confirmPayment(
                    provider: provider, billing: makeBilling(), card: makeCard(),
                    shouldStoreCardDetails: saveCard
                )
            } catch {
                let alert = UIAlertController(
                    title: nil, message: error.localizedDescription as String, preferredStyle: .alert
                )
                alert.addAction(
                    UIAlertAction(
                        title: NSLocalizedString("Close", comment: "Close"), style: .cancel, handler: nil
                    ))
                present(alert, animated: true)

                AWXAnalyticsLogger.shared().logAction(
                    withName: "card_payment_validation", additionalInfo: ["message": error]
                )
                logMessage(
                    "Payment failed. Intent ID: \(session?.paymentIntentId() ?? ""). Reason: \(error).")
            }
        }
    }

    private func makeBilling() -> AWXPlaceDetails {
        let address = viewModel?.makeBilling(
            firstName: firstNameField.text(), lastName: lastNameField.text(), email: emailField.text(),
            phoneNumber: phoneNumberField.text(), state: stateField.text(), city: cityField.text(),
            street: streetField.text(), postcode: zipCodeField.text()
        )
        return address ?? AWXPlaceDetails()
    }

    private func makeCard() -> AWXCard {
        let card = viewModel?.makeCard(
            name: nameField.text(), number: cardNoField.text(), expiry: expiresField.text(),
            cvc: cvcField.text()
        )
        return card ?? AWXCard()
    }

    func goBack() {
        navigationController?.popViewController(animated: true)
    }

    func close() {
        dismiss(animated: true) {
            let delegate = AWXUIContext.shared().delegate
            delegate?.paymentViewController(self, didCompleteWith: .cancel, error: nil)
            self.logMessage(
                "Delegate: \(delegate?.description ?? ""), paymentViewController:didCompleteWithStatus:error: \(self.presentationController?.description ?? "")"
            )
        }
    }
}

extension AWXCardViewController: AWXFloatingLabelTextFieldDelegate {
    public func floatingLabelTextField(
        _: AWXFloatingLabelTextField,
        textFieldShouldBeginEditing textField: UITextField
    ) -> Bool {
        switch textField {
        case cardNoField.textField:
            Risk.log(event: "input_card_number", screen: "page_create_card")
        case cvcField.textField:
            Risk.log(event: "input_card_cvc", screen: "page_create_card")
        case expiresField.textField:
            Risk.log(event: "input_card_expiry", screen: "page_create_card")
        case nameField.textField:
            Risk.log(event: "input_card_holder_name", screen: "page_create_card")
        default:
            break
        }
        return true
    }
}

extension AWXCardViewController: AWXCountryListViewControllerDelegate {
    public func countryListViewController(
        _ controller: AWXCountryListViewController, didSelect country: AWXCountry
    ) {
        controller.dismiss(animated: true)
        viewModel?.selectedCountry = country
        countryView.setText(country.countryName, animated: false)
    }
}

extension AWXCardViewController {
    func registerKeyboard() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillBeHidden(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    func unregisterKeyboard() {
        NotificationCenter.default.removeObserver(
            self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil
        )
        NotificationCenter.default.removeObserver(
            self, name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    func keyboardWillChangeFrame(_ notification: Notification) {
        if let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = CGRectGetHeight(rect)
            scrollView.contentInset.bottom = keyboardHeight
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
        }
    }

    func keyboardWillBeHidden(_: Notification) {
        scrollView.contentInset = .zero
        scrollView.verticalScrollIndicatorInsets = .zero
    }
}

extension AWXCardViewController: AWXCardviewModelDelegate {
    public func startLoading() {
        logMessage("startLoading:")
        startIndicator()
    }

    public func stopLoading() {
        logMessage("stopLoading:")
        stopIndicator()
    }

    public func shouldDismiss(completeStatus status: AirwallexPaymentStatus,
                              error: (any Error)?)
    {
        logMessage(
            "shouldDismiss completeStatus:error: \(status)  \(error?.localizedDescription ?? "")")

        dismiss(animated: true) {
            let delegate = AWXUIContext.shared().delegate
            delegate?.paymentViewController(self, didCompleteWith: status, error: error)
            self.logMessage(
                "Delegate: \(delegate?.description ?? ""), paymentViewController:didCompleteWithStatus:error: \(self.presentationController?.description ?? "")  \(status)  \(error?.localizedDescription ?? "")"
            )
        }
    }

    public func didCompleteWithPaymentConsentId(_ Id: String) {
        let delegate = AWXUIContext.shared().delegate
        if delegate?.responds(
            to: #selector(
                AWXPaymentResultDelegate.paymentViewController(_:didCompleteWithPaymentConsentId:))) == true
        {
            delegate?.paymentViewController?(self, didCompleteWithPaymentConsentId: Id)
        }
    }

    public func shouldPresent(_ controller: UIViewController?, forceToDismiss: Bool, withAnimation: Bool) {
        if forceToDismiss {
            presentedViewController?.dismiss(animated: true) {
                if let controller = controller {
                    self.present(controller, animated: withAnimation)
                }
            }
        } else if let controller = controller {
            present(controller, animated: withAnimation)
        }
    }

    public func shouldInsert(_ controller: UIViewController?) {
        if let controller = controller {
            addChild(controller)
            view.addSubview(controller.view)
            controller.didMove(toParent: self)
        }
    }

    public func shouldShowError(_ error: String) {
        let alert = UIAlertController(
            title: nil, message: error,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Close", comment: "Close"), style: .cancel, handler: nil
            ))
        present(alert, animated: true)
    }
}
