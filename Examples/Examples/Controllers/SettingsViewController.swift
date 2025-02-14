//
//  SettingsViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/23.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex
import Combine

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
    
    private lazy var switchForAutoCapture: ConfigSwitchView = {
        let view = ConfigSwitchView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var fieldForCustomerId: ConfigTextField = {
        let view = ConfigTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let button = customerIdActionButton
        button.sizeToFit()
        view.textField.rightView = button
        view.textField.rightViewMode = .always
        return view
    }()
    
    private lazy var customerIdActionButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsImageWhenHighlighted = false
        view.setTitleColor(.awxIconLink, for: .normal)
        view.titleLabel?.font = .awxFont(.body1, weight: .medium)
        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        view.addTarget(self, action: #selector(onCustomerIdActionButtonTapped), for: .touchUpInside)
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
    
    private lazy var environmentOptions: [AirwallexSDKMode] = {
        var arr = [ AirwallexSDKMode.demoMode, AirwallexSDKMode.stagingMode]
        #if !DEBUG
        arr.insert(AirwallexSDKMode.productionMode, at: 0)
        #endif
        return arr
    }()
    
    private var cancellables = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        reloadData()
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: fieldForCustomerId.textField)
            .sink { [weak self] _ in
                self?.updateCustomerIDGeneratorActionButton()
            }
            .store(in: &cancellables)
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
        setupSwitches()
        setupCustomerIDGenerator()
        setupFields()
    }
    
    func setupOptionForEnvironment() {
        let env = ExamplesKeys.environment
        
        let optionTitle = environmentOptions.first { $0 == env }!.displayName
        
        let viewModel = ConfigActionViewModel(
            configName: NSLocalizedString("Environment", comment: pageName),
            configValue: optionTitle,
            caption: NSLocalizedString("If you switch environment, you will need to restart the app for it to take effect. ", comment: pageName),
            primaryAction: { [weak self] optionView in
                guard let self else { return }
                self.showOptions(self.environmentOptions.map { $0.displayName }, sender: optionView) { index, _ in
                    let environment = self.environmentOptions[index]
                    guard environment != env else { return }
                    ExamplesKeys.environment = environment
                    Airwallex.setMode(environment)
                    //  some keys are stored by environment
                    self.reloadData()
                }
            }
        )
        optionForEnvironment.setup(viewModel)
    }
    
    func setupOptionForNextTrigger() {
        let option = ExamplesKeys.nextTriggerByType
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
                    ExamplesKeys.nextTriggerByType = newValue
                    self.setupOptionForNextTrigger()
                }
            }
        )
        optionForNextTrigger.setup(viewModel)
    }
    
    func setupSwitches() {
        switchForAutoCapture.setup(
            ConfigSwitchViewModel(
                title: NSLocalizedString("Auto capture", comment: pageName),
                isOn: ExamplesKeys.autoCapture,
                action: { isOn in
                    ExamplesKeys.autoCapture = isOn
                }
            )
        )
    }
    
    func setupCustomerIDGenerator() {
        fieldForCustomerId.setup(
            ConfigTextFieldViewModel(
                displayName: "Customer ID",
                text: ExamplesKeys.customerId
            )
        )
        
        updateCustomerIDGeneratorActionButton()
    }
    
    func updateCustomerIDGeneratorActionButton() {
        if let id = fieldForCustomerId.textField.text, !id.isEmpty {
            customerIdActionButton.setImage(
                UIImage(systemName: "xmark")?.withTintColor(.awxIconLink, renderingMode: .alwaysOriginal),
                for: .normal
            )
            customerIdActionButton.setTitle(nil, for: .normal)
        } else {
            customerIdActionButton.setTitle(
                NSLocalizedString("Generate", comment: pageName),
                for: .normal
            )
            customerIdActionButton.setImage(nil, for: .normal)
        }
    }
    
    func setupFields() {
        fieldForAPIKey.setup(
            ConfigTextFieldViewModel(
                displayName: "API key",
                text: ExamplesKeys.apiKey
            )
        )
        fieldForClientID.setup(
            ConfigTextFieldViewModel(
                displayName: "Client ID",
                text: ExamplesKeys.clientId
            )
        )
        fieldForAmount.setup(
            ConfigTextFieldViewModel(
                displayName: "Amount",
                text: ExamplesKeys.amount
            )
        )
        fieldForCurrency.setup(
            ConfigTextFieldViewModel(
                displayName: "Currency",
                text: ExamplesKeys.currency
            )
        )
        fieldForCountryCode.setup(
            ConfigTextFieldViewModel(
                displayName: "Country Code",
                text: ExamplesKeys.countryCode
            )
        )
        fieldForReturnURL.setup(
            ConfigTextFieldViewModel(
                displayName: "Return URL",
                text: ExamplesKeys.returnUrl
            )
        )
    }
}

private extension SettingsViewController {
    @objc func onResetButtonTapped() {
        let currentEnv = ExamplesKeys.environment
        ExamplesKeys.reset()
        guard currentEnv == ExamplesKeys.environment else {
            // refresh UI
            reloadData()
            let envTitle = environmentOptions.first { $0 == ExamplesKeys.environment }!.displayName
            showAlert(message: "Resart the app for \(envTitle) environment to take effect", title: nil) {
                exit(0)
            }
            return
        }
        
        // reset api client
        MockAPIClient.shared().apiKey = ExamplesKeys.apiKey ?? ""
        MockAPIClient.shared().clientID = ExamplesKeys.clientId ?? ""
        MockAPIClient.shared().createAuthenticationToken()
        
        // refresh UI
        reloadData()
    }
    
    @objc func onSaveButtonTapped() {
        // TODO: save all
        // switches and configActionView will automatic save when value changed
        ExamplesKeys.apiKey = fieldForAPIKey.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        ExamplesKeys.clientId = fieldForClientID.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        ExamplesKeys.amount = fieldForAmount.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        ExamplesKeys.currency = fieldForCurrency.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        ExamplesKeys.countryCode = fieldForCountryCode.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        ExamplesKeys.returnUrl = fieldForReturnURL.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        ExamplesKeys.customerId = fieldForCustomerId.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        navigationController?.popViewController(animated: true)
        MockAPIClient.shared().createAuthenticationToken()
    }
    
    @objc func onCustomerIdActionButtonTapped() {
        if let id = fieldForCustomerId.textField.text, !id.isEmpty {
            // clear customerId
            ExamplesKeys.customerId = nil
            setupCustomerIDGenerator()
        } else {
            // generate new customerId
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
                apiKey: ExamplesKeys.apiKey,
                clientID: ExamplesKeys.clientId
            )
            self.customerFetcher.createCustomer(
                request: request) { result in
                    Task {
                        self.stopLoading()
                        switch result {
                        case .success(let customer):
                            ExamplesKeys.customerId = customer.id
                            self.setupCustomerIDGenerator()
                        case .failure(let error):
                            self.showAlert(message: error.localizedDescription)
                        }
                    }
                }
        }
    }
}
