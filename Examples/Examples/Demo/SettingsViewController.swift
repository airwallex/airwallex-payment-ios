//
//  SettingsViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/23.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex

class SettingsViewController: UIViewController {
    
    private let pageName: String = "SDK Demo Setting"
    private lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let viewModel = TopViewModel(
            title: NSLocalizedString("Settings", comment: pageName),
            actionTitle: NSLocalizedString("Reset", comment: pageName),
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
        view.keyboardDismissMode = .interactive
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
        let view = UIButton(style: .primary, title: NSLocalizedString("Save", comment: pageName))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onSaveButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.awxBorderDecorative.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var optionForEnvironment: ConfigActionView = {
        let view = ConfigActionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var optionForNextTrigger: ConfigActionView = {
        let view = ConfigActionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var switchForCVC: ConfigSwitchView = {
        let view = ConfigSwitchView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var switchFor3DS: ConfigSwitchView = {
        let view = ConfigSwitchView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var switchForAutoCapture: ConfigSwitchView = {
        let view = ConfigSwitchView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var customerIDGenerator: ConfigActionView = {
        let view = ConfigActionView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        view.textColor = .awxTextPlaceholder
        view.text = "WeChat Region: HK"
        return view
    }()
    
    private lazy var versionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxFont(.caption1)
        view.textColor = .awxTextPlaceholder
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        view.text = "App Version: v\(version) (\(build))"
        return view
    }()
    
    private lazy var keyboardHandler = KeyboardHandler()
    
    private lazy var customerFetcher = Airwallex.apiClient
    
    private lazy var environmentOptions = [
        (env: AirwallexSDKMode.productionMode, title: "Production"),
        (env: AirwallexSDKMode.demoMode, title: "Demo"),
        (env: AirwallexSDKMode.stagingMode, title: "Staging")
    ]
    
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
}

private extension SettingsViewController {
    func setupViews() {
        customizeNavigationBackButton()
        view.backgroundColor = .awxBackgroundPrimary
        view.addSubview(scrollView)
        scrollView.addSubview(stack)
        stack.addArrangedSubview(topView)
        
        view.addSubview(bottomView)
        bottomView.addSubview(saveButton)
        
        stack.addArrangedSubview(optionForEnvironment)
        stack.addArrangedSubview(optionForNextTrigger)
        stack.addArrangedSubview(switchForCVC)
        stack.addArrangedSubview(switchFor3DS)
        stack.addArrangedSubview(switchForAutoCapture)
        stack.addArrangedSubview(customerIDGenerator)
        
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
        setupSwitches()
        setupCustomerIDGenerator()
        setupFields()
    }
    
    func setupOptionForEnvironment() {
        let env = AirwallexExamplesKeys.shared().environment
        
        let optionTitle = environmentOptions.first { $0.env == env }!.title
        
        let viewModel = ConfigActionViewModel(
            configName: NSLocalizedString("Environment", comment: pageName),
            configValue: optionTitle,
            caption: NSLocalizedString("If you switch environment, you will need to restart the app for it to take effect. ", comment: pageName),
            primaryAction: { [weak self] optionView in
                guard let self else { return }
                self.showOptions(self.environmentOptions.map { $0.title }, sender: optionView) { index, _ in
                    let environment = self.environmentOptions[index].env
                    guard environment != env else {
                        return
                    }
                    AirwallexExamplesKeys.shared().environment = environment
                    Airwallex.setMode(environment)
                    self.setupOptionForEnvironment()
                    self.showAlert(message: "Resart the app for \(self.environmentOptions[index].title) to take effect", title: nil) {
                        exit(0)
                    }
                }
            }
        )
        optionForEnvironment.setup(viewModel)
    }
    
    func setupOptionForNextTrigger() {
        let option = AirwallexExamplesKeys.shared().nextTriggerByType
        let optionTitleArr = ["Customer", "Merchant"]
        let optionTitle = optionTitleArr[Int(option.rawValue)]
        
        let viewModel = ConfigActionViewModel(
            configName: NSLocalizedString("Next trigger by", comment: pageName),
            configValue: optionTitle,
            primaryAction: { [weak self] optionView in
                guard let self else { return }
                self.showOptions(optionTitleArr, sender: optionView) { index, _ in
                    guard let newValue = AirwallexNextTriggerByType(rawValue: UInt(index)),
                          option != newValue else {
                        return
                    }
                    AirwallexExamplesKeys.shared().nextTriggerByType = newValue
                    self.setupOptionForNextTrigger()
                }
            }
        )
        optionForNextTrigger.setup(viewModel)
    }
    
    func setupSwitches() {
        switchForCVC.setup(
            ConfigSwitchViewModel(
                title: NSLocalizedString("Requires CVC", comment: pageName),
                isOn: AirwallexExamplesKeys.shared().requireCVC,
                action: { isOn in
                    AirwallexExamplesKeys.shared().requireCVC = isOn
                }
            )
        )
        
        switchFor3DS.setup(
            ConfigSwitchViewModel(
                title: NSLocalizedString("Requires 3DS", comment: pageName),
                isOn: AirwallexExamplesKeys.shared().force3DS,
                action: { isOn in
                    AirwallexExamplesKeys.shared().force3DS = isOn
                }
            )
        )
        
        switchForAutoCapture.setup(
            ConfigSwitchViewModel(
                title: NSLocalizedString("Auto capture", comment: pageName),
                isOn: AirwallexExamplesKeys.shared().autoCapture,
                action: { isOn in
                    AirwallexExamplesKeys.shared().autoCapture = isOn
                }
            )
        )
    }
    
    func setupCustomerIDGenerator() {
        let customerId = AirwallexExamplesKeys.shared().customerId
        if let customerId {
            let viewModel = ConfigActionViewModel(
                configName: NSLocalizedString("Customer ID", comment: pageName),
                configValue: customerId,
                secondaryActionIcon: UIImage(systemName: "xmark")?.withTintColor(.awxIconLink, renderingMode: .alwaysOriginal),
                secondaryAction: { [weak self] _ in
                    AirwallexExamplesKeys.shared().customerId = nil
                    self?.setupCustomerIDGenerator()
                }
            )
            customerIDGenerator.setup(viewModel)
        } else {
            let viewModel = ConfigActionViewModel(
                configName: NSLocalizedString("Customer ID", comment: pageName),
                configValue: nil,
                secondaryActionIcon: nil,
                secondaryActionTitle: NSLocalizedString("Generate", comment: pageName),
                secondaryAction: { [weak self] _ in
                    guard let self else { return }
                    self.startLoading()
                    let request = CustomerRequest(
                        firstName: "Jason",
                        lastName: "Wang",
                        email: "john.doe@airwallex.com",
                        phoneNumber: "13800000000",
                        additionalInfo: ["registered_via_social_media": false,
                                         "registration_date": "2019-09-18",
                                         "first_successful_order_date": "2019-09-18"],
                        metadata: ["id": 1],
                        apiKey: AirwallexExamplesKeys.shared().apiKey,
                        clientID: AirwallexExamplesKeys.shared().clientId
                    )
                    self.customerFetcher.createCustomer(
                        request: request) { result in
                            Task {
                                self.stopLoading()
                                switch result {
                                case .success(let customer):
                                    AirwallexExamplesKeys.shared().customerId = customer.id
                                    self.setupCustomerIDGenerator()
                                case .failure(let error):
                                    self.showAlert(message: error.localizedDescription)
                                }
                            }
                        }
                }
            )
            customerIDGenerator.setup(viewModel)
        }
    }
    
    func setupFields() {
        fieldForAPIKey.setup(
            ConfigTextFieldViewModel(
                displayName: "API key",
                text: AirwallexExamplesKeys.shared().apiKey
            )
        )
        fieldForClientID.setup(
            ConfigTextFieldViewModel(
                displayName: "Client ID",
                text: AirwallexExamplesKeys.shared().clientId
            )
        )
        fieldForAmount.setup(
            ConfigTextFieldViewModel(
                displayName: "Amount",
                text: AirwallexExamplesKeys.shared().amount
            )
        )
        fieldForCurrency.setup(
            ConfigTextFieldViewModel(
                displayName: "Currency",
                text: AirwallexExamplesKeys.shared().currency
            )
        )
        fieldForCountryCode.setup(
            ConfigTextFieldViewModel(
                displayName: "Country Code",
                text: AirwallexExamplesKeys.shared().countryCode
            )
        )
        fieldForReturnURL.setup(
            ConfigTextFieldViewModel(
                displayName: "Return URL",
                text: AirwallexExamplesKeys.shared().returnUrl
            )
        )
    }
}

private extension SettingsViewController {
    @objc func onResetButtonTapped() {
        let currentEnv = AirwallexExamplesKeys.shared().environment
        AirwallexExamplesKeys.shared().resetKeys()
        guard currentEnv == AirwallexExamplesKeys.shared().environment else {
            // refresh UI
            reloadData()
            let envTitle = environmentOptions.first { $0.env == AirwallexExamplesKeys.shared().environment }!.title
            showAlert(message: "Resart the app for \(envTitle) environment to take effect", title: nil) {
                exit(0)
            }
            return
        }
        
        // reset api client
        MockAPIClient.shared().apiKey = AirwallexExamplesKeys.shared().apiKey
        MockAPIClient.shared().clientID = AirwallexExamplesKeys.shared().clientId
        MockAPIClient.shared().createAuthenticationToken()
        
        // refresh UI
        reloadData()
    }
    
    @objc func onSaveButtonTapped() {
        // switches and configActionView will automatic save when value changed
        AirwallexExamplesKeys.shared().apiKey = fieldForAPIKey.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        AirwallexExamplesKeys.shared().clientId = fieldForClientID.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        AirwallexExamplesKeys.shared().amount = fieldForAmount.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        AirwallexExamplesKeys.shared().currency = fieldForCurrency.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        AirwallexExamplesKeys.shared().countryCode = fieldForCountryCode.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        AirwallexExamplesKeys.shared().returnUrl = fieldForReturnURL.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        navigationController?.popViewController(animated: true)
    }
}
