//
//  SettingsViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/23.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Combine
import Airwallex

class SettingsViewController: UIViewController {
    
    private lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let viewModel = TopViewModel(
            title: "Settings",
            actionTitle: "Reset",
            actionHandler: { [weak self] in
                self?.onResetButtonTapped()
            }
        )
        view.setup(viewModel)
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.keyboardDismissMode = .onDrag
        return view
    }()
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 24
        view.axis = .vertical
        return view
    }()
    
    private lazy var saveButton: UIButton = {
        let view = AWXButton(style: .primary, title: "Save")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onSaveButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = .awxCGColor(.borderDecorative)
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var optionForEnvironment: ConfigActionView = {
        let view = ConfigActionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = AccessibilityIdentifiers.SettingsScreen.optionButtonForEnvironment
        return view
    }()
    
    private lazy var optionForNextTrigger: ConfigActionView = {
        let view = ConfigActionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = AccessibilityIdentifiers.SettingsScreen.optionButtonForNextTriggerBy
        return view
    }()
    
    private lazy var optionForPaymentLayout: ConfigActionView = {
        let view = ConfigActionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = AccessibilityIdentifiers.SettingsScreen.optionButtonForLayout
        return view
    }()
    
    private lazy var switchForForce3DS: ConfigSwitchView = {
        let view = ConfigSwitchView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.optionSwitch.accessibilityIdentifier = AccessibilityIdentifiers.SettingsScreen.toggleFor3DS
        return view
    }()
    
    private lazy var switchForAutoCapture: ConfigSwitchView = {
        let view = ConfigSwitchView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var requiredBillingFieldsEntry: ConfigEntryView = {
        let view = ConfigEntryView()
        let viewModel = ConfigEntryViewModel(
            text: "Required billing fields"
        ) { [weak self] in
            guard let self else { return }
            let vc = BillingFieldsSettingViewController(settings: self.settings)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        view.setup(viewModel)
        return view
    }()
    
    private lazy var fieldForCustomerId: ConfigTextField = {
        let view = ConfigTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let button = customerIdActionButton
        button.sizeToFit()
        view.textField.rightView = button
        view.textField.rightViewMode = .always
        view.textField.accessibilityIdentifier = AccessibilityIdentifiers.SettingsScreen.textFieldForCustomerID
        return view
    }()
    
    private lazy var customerIdActionButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsImageWhenHighlighted = false
        view.setTitleColor(.awxColor(.iconLink), for: .normal)
        view.titleLabel?.font = .awxFont(.body1, weight: .medium)
        view.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        view.addTarget(self, action: #selector(onCustomerIdActionButtonTapped), for: .touchUpInside)
        view.accessibilityIdentifier = AccessibilityIdentifiers.SettingsScreen.actionButtonForCustomerID
        return view
    }()
    
    private lazy var fieldForAPIKey: ConfigTextField = {
        let view = ConfigTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var fieldForClientID: ConfigTextField = {
        let view = ConfigTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var fieldForAmount: ConfigTextField = {
        let view = ConfigTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textField.keyboardType = .decimalPad
        return view
    }()
    
    private lazy var fieldForCurrency: ConfigTextField = {
        let view = ConfigTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textField.keyboardType = .asciiCapable
        view.textField.autocapitalizationType = .allCharacters
        return view
    }()
    
    private lazy var fieldForCountryCode: ConfigTextField = {
        let view = ConfigTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textField.keyboardType = .asciiCapable
        view.textField.autocapitalizationType = .allCharacters
        return view
    }()
    
    private lazy var fieldForReturnURL: ConfigTextField = {
        let view = ConfigTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var regionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxFont(.caption1)
        view.textColor = .awxColor(.textPlaceholder)
        view.text = "WeChat Region: HK"
        return view
    }()
    
    private lazy var versionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxFont(.caption1)
        view.textColor = .awxColor(.textPlaceholder)
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        view.text = "App Version: v\(version) (\(build))"
        view.accessibilityLabel = AccessibilityIdentifiers.SettingsScreen.versionLabel
        view.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onVersionLabelTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var keyboardHandler = KeyboardHandler()
    
    private var cancellables = [AnyCancellable]()
    
    private lazy var settings = ExamplesKeys.allSettings
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardHandler.startObserving(scrollView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardHandler.stopObserving()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            bottomView.layer.borderColor = .awxCGColor(.borderDecorative)
        }
    }
}

private extension SettingsViewController {
    func setupViews() {
        
        customizeNavigationBackButton()
        view.backgroundColor = .awxColor(.backgroundPrimary)
        view.addSubview(scrollView)
        scrollView.addSubview(stack)
        stack.addArrangedSubview(topView)
        
        view.addSubview(bottomView)
        bottomView.addSubview(saveButton)
        
        stack.addArrangedSubview(optionForEnvironment)
        stack.addArrangedSubview(optionForNextTrigger)
        stack.addArrangedSubview(optionForPaymentLayout)
        
        stack.addArrangedSubview(requiredBillingFieldsEntry)
        stack.addArrangedSubview(switchForForce3DS)
        stack.addArrangedSubview(switchForAutoCapture)
        stack.addArrangedSubview(fieldForCustomerId)
        
        stack.addArrangedSubview(fieldForAPIKey)
        stack.addArrangedSubview(fieldForClientID)
        stack.addArrangedSubview(fieldForAmount)
        stack.addArrangedSubview(fieldForCurrency)
        stack.addArrangedSubview(fieldForCountryCode)
        stack.addArrangedSubview(fieldForReturnURL)
        
        stack.addArrangedSubview(regionLabel)
        stack.addArrangedSubview(versionLabel)
        
        var constraints = [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 6),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            stack.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor, constant: -32),
            
            bottomView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -1),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 1),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            saveButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 16),
            saveButton.leadingAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            saveButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 52),
        ]
        
        let nextButtonBottomConstraint = saveButton.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -40)
        nextButtonBottomConstraint.priority = .required - 1
        constraints.append(nextButtonBottomConstraint)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func reloadData() {
        setupOptionForEnvironment()
        setupOptionForNextTrigger()
        setupOptionForPaymentLayout()
        setupSwitches()
        setupCustomerIDGenerator()
        setupFields()
    }
    
    func setupOptionForEnvironment() {
        let env = settings.environment
        var environmentOptions = [ AirwallexSDKMode.productionMode, AirwallexSDKMode.demoMode, AirwallexSDKMode.stagingMode]
#if DEBUG
        if !CommandLine.arguments.contains("-production") {
            environmentOptions.remove(at: 0)
        }
#endif
        let optionTitle = env.displayName
        
        let viewModel = ConfigActionViewModel(
            configName: "Environment",
            configValue: optionTitle,
            caption: "If you switch environment, you will need to restart the app for it to take effect. ",
            primaryAction: { [weak self] optionView in
                guard let self else { return }
                self.showOptions(environmentOptions.map { $0.displayName }, sender: optionView) { index, _ in
                    let environment = environmentOptions[index]
                    guard environment != env else { return }
                    self.settings.environment = environment
                    //  customerId are stored by environment
                    self.settings.customerId = ExamplesKeys.readValue("customerId", environment: environment)
                    self.settings.clientId = ExamplesKeys.readValue("clientId", environment: environment)
                    self.settings.apiKey = ExamplesKeys.readValue("apiKey", environment: environment)
                    self.reloadData()
                }
            }
        )
        optionForEnvironment.setup(viewModel)
    }
    
    func setupOptionForNextTrigger() {
        
        if ExamplesKeys.checkoutMode == .oneOff {
            let viewModel = ConfigActionViewModel(
                configName: "Next trigger by",
                configValue: AirwallexNextTriggerByType.customerType.displayName,
                primaryAction: nil
            )
            optionForNextTrigger.setup(viewModel)
        } else {
            let option = settings.nextTriggerByType
            let options = [ AirwallexNextTriggerByType.customerType, AirwallexNextTriggerByType.merchantType ]

            let viewModel = ConfigActionViewModel(
                configName: "Next trigger by",
                configValue: option.displayName,
                primaryAction: { [weak self] optionView in
                    guard let self else { return }
                    self.showOptions(options.map { $0.displayName }, sender: optionView) { index, _ in
                        guard let newValue = AirwallexNextTriggerByType(rawValue: UInt(index)),
                              option != newValue else {
                            return
                        }
                        self.settings.nextTriggerByType = newValue
                        self.setupOptionForNextTrigger()
                    }
                }
            )
            optionForNextTrigger.setup(viewModel)
        }
    }
    
    func setupOptionForPaymentLayout() {
        let option = settings.paymentLayout
        let options = AWXUIContext.PaymentLayout.allCases
        
        let viewModel = ConfigActionViewModel(
            configName: "Payment Layout",
            configValue: option.displayName,
            primaryAction: { [weak self] optionView in
                guard let self else { return }
                self.showOptions(options.map { $0.displayName }, sender: optionView) { index, _ in
                    guard let newValue = AWXUIContext.PaymentLayout(rawValue: index),
                          option != newValue else {
                        return
                    }
                    self.settings.paymentLayout = newValue
                    self.setupOptionForPaymentLayout()
                }
            }
        )
        optionForPaymentLayout.setup(viewModel)
    }
    
    func setupSwitches() {
        
        switchForForce3DS.setup(
            ConfigSwitchViewModel(
                title: "Force 3DS",
                isOn: settings.force3DS,
                action: { [weak self] isOn in
                    self?.settings.force3DS = isOn
                })
        )
        
        switchForAutoCapture.setup(
            ConfigSwitchViewModel(
                title: "Auto capture",
                isOn: settings.autoCapture,
                action: { [weak self] isOn in
                    self?.settings.autoCapture = isOn
                }
            )
        )
    }
    
    func setupCustomerIDGenerator() {
        fieldForCustomerId.setup(
            ConfigTextFieldViewModel(
                displayName: "Customer ID",
                text: settings.customerId,
                textDidChange: { [weak self] text in
                    self?.updateCustomerIDGeneratorActionButton()
                },
                textDidEndEditing: { [weak self] text in
                    self?.settings.customerId = text?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
                }
            )
        )
        updateCustomerIDGeneratorActionButton()
    }
    
    func updateCustomerIDGeneratorActionButton() {
        if let id = fieldForCustomerId.textField.text, !id.isEmpty {
            customerIdActionButton.setImage(
                UIImage(systemName: "xmark")?.withTintColor(.awxColor(.iconLink), renderingMode: .alwaysOriginal),
                for: .normal
            )
            customerIdActionButton.setTitle(nil, for: .normal)
        } else {
            customerIdActionButton.setTitle(
                "Generate",
                for: .normal
            )
            customerIdActionButton.setImage(nil, for: .normal)
        }
    }
    
    func setupFields() {
        fieldForAPIKey.setup(
            ConfigTextFieldViewModel(
                displayName: "API key",
                text: settings.apiKey,
                textDidEndEditing: { [weak self] text in
                    self?.settings.apiKey = text
                }
            )
        )
        fieldForClientID.setup(
            ConfigTextFieldViewModel(
                displayName: "Client ID",
                text: settings.clientId,
                textDidEndEditing: { [weak self] text in
                    self?.settings.clientId = text
                }
            )
        )
        fieldForAmount.setup(
            ConfigTextFieldViewModel(
                displayName: "Amount",
                text: settings.amount,
                textDidEndEditing: { [weak self] text in
                    self?.settings.amount = text ?? ""
                }
            )
        )
        fieldForCurrency.setup(
            ConfigTextFieldViewModel(
                displayName: "Currency",
                text: settings.currency,
                textDidEndEditing: { [weak self] text in
                    self?.settings.currency = text ?? ""
                }
            )
        )
        fieldForCountryCode.setup(
            ConfigTextFieldViewModel(
                displayName: "Country Code",
                text: settings.countryCode,
                textDidEndEditing: { [weak self] text in
                    self?.settings.countryCode = text ?? ""
                }
            )
        )
        fieldForReturnURL.setup(
            ConfigTextFieldViewModel(
                displayName: "Return URL",
                text: settings.returnUrl,
                textDidEndEditing: { [weak self] text in
                    self?.settings.returnUrl = text ?? ""
                }
            )
        )
    }
}

private extension SettingsViewController {
    @objc func onResetButtonTapped() {
        let env = ExamplesKeys.environment
        ExamplesKeys.reset()
        settings = ExamplesKeys.allSettings
        // refresh UI
        reloadData()
        
        // exit if needed
        guard env == ExamplesKeys.environment else {
            showAlert(message: "Relaunch (manually) required for the new environment to take effect.", buttonTitle: "Exit") {
                exit(0)
            }
            return
        }
        showAlert(message: "Settings cleared") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func onSaveButtonTapped() {
        // This line of code forces the text field to end editing when the Save button is pressed.
        // It is especially useful for debugging in simulators, where the keyboard is not displayed while editing.
        scrollView.endEditing(true)
        
        guard NSLocale.isoCountryCodes.contains(where: { $0 == settings.countryCode }) else {
            showAlert(message: "invalid country code \(settings.countryCode)")
            return
        }
        
        guard NSLocale.isoCurrencyCodes.contains(where: { $0 == settings.currency }) else {
            showAlert(message: "invalid currency code \(settings.currency)")
            return
        }
        
        let env = ExamplesKeys.environment
        ExamplesKeys.allSettings = settings
        print(settings)
        // exit if needed
        guard env == ExamplesKeys.environment else {
            showAlert(message: "Relaunch (manually) required for the new environment to take effect.", buttonTitle: "Exit") {
                exit(0)
            }
            return
        }
        showAlert(message: "Settings saved", buttonTitle: "Close") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func onCustomerIdActionButtonTapped() {
        if let id = fieldForCustomerId.textField.text, !id.isEmpty {
            // clear customerId
            settings.customerId = nil
            setupCustomerIDGenerator()
        } else {
            // generate new customerId
            self.startLoading()
            self.view.endEditing(true)
            let request = CustomerRequest(
                firstName: "Jason",
                lastName: "Wang",
                email: "john.doe@airwallex.com",
                phoneNumber: "13800000000",
                additionalInfo: ["registered_via_social_media": false,
                                 "registration_date": "2019-09-18",
                                 "first_successful_order_date": "2019-09-18"],
                metadata: ["id": 1],
                apiKey: settings.apiKey,
                clientID: settings.clientId
            )
            
            if settings.environment == .productionMode {
                // apiKey and clientId may not have been saved yet
                // update them manually
                MockAPIClient.shared().apiKey = settings.apiKey
                MockAPIClient.shared().clientID = settings.clientId
            }
            
            var customerFetcher: APIClient
            switch settings.environment {
            case .demoMode, .stagingMode:
                let baseURL = DemoStoreAPIClient.baseURLForEnvironment(settings.environment)
                customerFetcher = DemoStoreAPIClient(baseURL: baseURL)
            case .productionMode:
                customerFetcher = DirectAPIClient(
                    apiKey: settings.apiKey,
                    clientID: settings.clientId
                )
            }
            
            customerFetcher.createCustomer(
                request: request) { result in
                    Task {
                        self.stopLoading()
                        switch result {
                        case .success(let customer):
                            self.settings.customerId = customer.id
                            self.setupCustomerIDGenerator()
                        case .failure(let error):
                            self.showAlert(message: error.localizedDescription)
                        }
                    }
                }
        }
    }
    
    @objc func onVersionLabelTapped() {
        self.scrollView.endEditing(true)
    }
}
