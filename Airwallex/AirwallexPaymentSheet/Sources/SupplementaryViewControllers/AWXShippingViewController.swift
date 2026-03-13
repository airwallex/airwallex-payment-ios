//
//  AWXShippingViewController.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/28.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif

@objc public protocol AWXShippingViewControllerDelegate: AnyObject {
    func shippingViewController(_ controller: AWXShippingViewController,
                                didEditShipping shipping: AWXPlaceDetails)
}

@objc public class AWXShippingViewController: AWXViewController {

    @objc public weak var delegate: (any AWXShippingViewControllerDelegate)?

    @objc public var shipping: AWXPlaceDetails?

    public init(shipping: AWXPlaceDetails? = nil,
                delegate: (any AWXShippingViewControllerDelegate)? = nil) {
        self.shipping = shipping
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Views

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.keyboardDismissMode = .interactive
        view.contentInsetAdjustmentBehavior = .always
        return view
    }()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 16
        return view
    }()

    // MARK: - View Models

    private lazy var firstNameVM = InfoCollectorTextFieldViewModel(
        textFieldType: .firstName,
        title: NSLocalizedString("First name", bundle: .paymentSheet, comment: "shipping field title"),
        text: shipping?.firstName,
        isRequired: true,
        clearButtonMode: .whileEditing,
        returnKeyType: .next,
        reconfigureHandler: { [weak self] vm, _ in self?.firstNameField.setup(vm) }
    )

    private lazy var lastNameVM = InfoCollectorTextFieldViewModel(
        textFieldType: .lastName,
        title: NSLocalizedString("Last name", bundle: .paymentSheet, comment: "shipping field title"),
        text: shipping?.lastName,
        isRequired: true,
        clearButtonMode: .whileEditing,
        returnKeyType: .next,
        reconfigureHandler: { [weak self] vm, _ in self?.lastNameField.setup(vm) }
    )

    private lazy var countryVM: CountrySelectionViewModel = {
        var country: AWXCountry?
        if let code = shipping?.address?.countryCode, !code.isEmpty {
            country = AWXCountry(code: code)
        }
        return CountrySelectionViewModel(
            country: country,
            title: NSLocalizedString("Country / Region", bundle: .paymentSheet, comment: "shipping field title"),
            handleUserInteraction: { [weak self] in self?.presentCountryPicker() },
            reconfigureHandler: { [weak self] vm, _ in self?.countryField.setup(vm as! CountrySelectionViewModel) }
        )
    }()

    private lazy var stateVM = InfoCollectorTextFieldViewModel(
        textFieldType: .state,
        title: NSLocalizedString("State", bundle: .paymentSheet, comment: "shipping field title"),
        text: shipping?.address?.state,
        isRequired: true,
        clearButtonMode: .whileEditing,
        returnKeyType: .next,
        reconfigureHandler: { [weak self] vm, _ in self?.stateField.setup(vm) }
    )

    private lazy var cityVM = InfoCollectorTextFieldViewModel(
        textFieldType: .city,
        title: NSLocalizedString("City", bundle: .paymentSheet, comment: "shipping field title"),
        text: shipping?.address?.city,
        isRequired: true,
        clearButtonMode: .whileEditing,
        returnKeyType: .next,
        reconfigureHandler: { [weak self] vm, _ in self?.cityField.setup(vm) }
    )

    private lazy var streetVM = InfoCollectorTextFieldViewModel(
        textFieldType: .street,
        title: NSLocalizedString("Street", bundle: .paymentSheet, comment: "shipping field title"),
        text: shipping?.address?.street,
        isRequired: true,
        clearButtonMode: .whileEditing,
        returnKeyType: .next,
        reconfigureHandler: { [weak self] vm, _ in self?.streetField.setup(vm) }
    )

    private lazy var zipcodeVM = InfoCollectorTextFieldViewModel(
        textFieldType: .zipcode,
        title: NSLocalizedString("Zip code (optional)", bundle: .paymentSheet, comment: "shipping field title"),
        text: shipping?.address?.postcode,
        isRequired: false,
        clearButtonMode: .whileEditing,
        returnKeyType: .next,
        reconfigureHandler: { [weak self] vm, _ in self?.zipcodeField.setup(vm) }
    )

    private lazy var emailVM = InfoCollectorTextFieldViewModel(
        textFieldType: .email,
        title: NSLocalizedString("Email (optional)", bundle: .paymentSheet, comment: "shipping field title"),
        text: shipping?.email,
        isRequired: false,
        clearButtonMode: .whileEditing,
        returnKeyType: .next,
        reconfigureHandler: { [weak self] vm, _ in self?.emailField.setup(vm) }
    )

    private lazy var phoneVM = InfoCollectorTextFieldViewModel(
        textFieldType: .phoneNumber,
        title: NSLocalizedString("Phone number (optional)", bundle: .paymentSheet, comment: "shipping field title"),
        text: shipping?.phoneNumber,
        isRequired: false,
        clearButtonMode: .whileEditing,
        returnKeyType: .done,
        reconfigureHandler: { [weak self] vm, _ in self?.phoneField.setup(vm) }
    )

    // MARK: - Fields

    private func makeTextField(for vm: InfoCollectorTextFieldViewModel) -> InfoCollectorTextField<InfoCollectorTextFieldViewModel> {
        let field = InfoCollectorTextField<InfoCollectorTextFieldViewModel>()
        field.setup(vm)
        return field
    }

    private lazy var firstNameField: InfoCollectorTextField<InfoCollectorTextFieldViewModel> = makeTextField(for: firstNameVM)
    private lazy var lastNameField: InfoCollectorTextField<InfoCollectorTextFieldViewModel> = makeTextField(for: lastNameVM)

    private lazy var countryField: OptionSelectionView<CountrySelectionViewModel> = {
        let field = OptionSelectionView<CountrySelectionViewModel>()
        field.setup(countryVM)
        return field
    }()

    private lazy var stateField: InfoCollectorTextField<InfoCollectorTextFieldViewModel> = makeTextField(for: stateVM)
    private lazy var cityField: InfoCollectorTextField<InfoCollectorTextFieldViewModel> = makeTextField(for: cityVM)
    private lazy var streetField: InfoCollectorTextField<InfoCollectorTextFieldViewModel> = makeTextField(for: streetVM)
    private lazy var zipcodeField: InfoCollectorTextField<InfoCollectorTextFieldViewModel> = makeTextField(for: zipcodeVM)
    private lazy var emailField: InfoCollectorTextField<InfoCollectorTextFieldViewModel> = makeTextField(for: emailVM)
    private lazy var phoneField: InfoCollectorTextField<InfoCollectorTextFieldViewModel> = makeTextField(for: phoneVM)

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFields()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerKeyboard()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboard()
    }

    public override func activeScrollView() -> UIScrollView? {
        scrollView
    }
}

extension AWXShippingViewController: AWXPageViewTrackable {
    public var pageName: String! {
        "shipping_address"
    }
}

// MARK: - Setup

private extension AWXShippingViewController {

    func setupUI() {
        title = NSLocalizedString("Shipping", bundle: .paymentSheet, comment: "title of shipping view controller")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        view.backgroundColor = .awxColor(.backgroundPrimary)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Save", bundle: .paymentSheet, comment: "save button on navigation bar"),
            style: .plain,
            target: self,
            action: #selector(savePressed)
        )

        if navigationController?.viewControllers.first === self {
            let image = UIImage(named: "close", in: .paymentSheet)?
                .withTintColor(.awxColor(.iconPrimary), renderingMode: .alwaysTemplate)
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: image,
                style: .plain,
                target: self,
                action: #selector(close(_:))
            )
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditingOnTap))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
        ])
    }

    func setupFields() {
        let fields: [UIView] = [
            firstNameField, lastNameField, countryField,
            stateField, cityField, streetField, zipcodeField,
            emailField, phoneField,
        ]
        fields.forEach { stackView.addArrangedSubview($0) }

        let textFieldEntries: [(field: UIView, vm: InfoCollectorTextFieldViewModel)] = [
            (firstNameField, firstNameVM),
            (lastNameField, lastNameVM),
            (stateField, stateVM),
            (cityField, cityVM),
            (streetField, streetVM),
            (zipcodeField, zipcodeVM),
            (emailField, emailVM),
            (phoneField, phoneVM),
        ]
        setupReturnKeyChain(textFieldEntries)
    }

    func setupReturnKeyChain(_ textFieldVMs: [(field: UIView, vm: InfoCollectorTextFieldViewModel)]) {
        if let last = textFieldVMs.last {
            last.vm.returnKeyType = .done
        }
        for (index, entry) in textFieldVMs.enumerated() {
            let nextIndex = index + 1
            if nextIndex < textFieldVMs.count {
                let nextField = textFieldVMs[nextIndex].field
                entry.vm.returnActionHandler = { _ in
                    nextField.becomeFirstResponder()
                }
            } else {
                entry.vm.returnActionHandler = { responder in
                    responder.resignFirstResponder()
                    return false
                }
            }
        }
    }
}

// MARK: - Actions

private extension AWXShippingViewController {

    @objc func endEditingOnTap() {
        view.endEditing(true)
    }

    @objc func savePressed() {
        let allVMs: [InfoCollectorTextFieldViewModel] = [
            firstNameVM, lastNameVM, countryVM, stateVM,
            cityVM, streetVM, zipcodeVM, emailVM, phoneVM,
        ]
        for vm in allVMs {
            vm.handleDidEndEditing(reconfigureStrategy: .onValidationChange)
        }

        if let errorHint = allVMs.first(where: { !$0.isValid })?.errorHint {
            showAlert(message: errorHint)
            return
        }

        let details = AWXPlaceDetails()
        details.firstName = firstNameVM.text ?? ""
        details.lastName = lastNameVM.text ?? ""
        details.email = emailVM.text
        details.phoneNumber = phoneVM.text

        let address = AWXAddress()
        address.countryCode = countryVM.country?.countryCode
        address.state = stateVM.text
        address.city = cityVM.text
        address.street = streetVM.text
        address.postcode = zipcodeVM.text
        details.address = address

        self.shipping = details
        delegate?.shippingViewController(self, didEditShipping: details)
    }
}

// MARK: - Country Picker

extension AWXShippingViewController: CountryListViewControllerDelegate {

    func presentCountryPicker() {
        let countryListVC = CountryListViewController()
        countryListVC.delegate = self
        countryListVC.selectedCountry = countryVM.country
        let nav = UINavigationController(rootViewController: countryListVC)
        present(nav, animated: true)
    }

    func countryListViewController(_ controller: CountryListViewController, didSelect country: AWXCountry) {
        controller.dismiss(animated: true)
        countryVM.country = country
    }
}
