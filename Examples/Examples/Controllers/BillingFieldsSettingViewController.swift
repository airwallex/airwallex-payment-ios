//
//  BillingFieldsSettingViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/4/16.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class BillingFieldsSettingViewController: UIViewController {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let pageName: String = "Required Billing Fields Setting"
    private lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let viewModel = TopViewModel(
            title: NSLocalizedString("Required Billing Fields", comment: pageName)
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
    
    private lazy var switchForName: ConfigSwitchView = {
        let view = ConfigSwitchView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(
            ConfigSwitchViewModel(
                title: NSLocalizedString("Name", comment: pageName),
                isOn: settings.requiresName,
                action: { [weak self] isOn in
                    self?.settings.requiresName = isOn
                }
            )
        )
        return view
    }()
    
    private lazy var switchForEmail: ConfigSwitchView = {
        let view = ConfigSwitchView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(
            ConfigSwitchViewModel(
                title: NSLocalizedString("Email", comment: pageName),
                isOn: settings.requiresEmail,
                action: { [weak self] isOn in
                    self?.settings.requiresEmail = isOn
                }
            )
        )
        return view
    }()
    
    private lazy var switchForPhone: ConfigSwitchView = {
        let view = ConfigSwitchView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(
            ConfigSwitchViewModel(
                title: NSLocalizedString("Phone Number", comment: pageName),
                isOn: settings.requiresPhone,
                action: { [weak self] isOn in
                    self?.settings.requiresPhone = isOn
                }
            )
        )
        return view
    }()
    
    private lazy var switchForAddress: ConfigSwitchView = {
        let view = ConfigSwitchView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(
            ConfigSwitchViewModel(
                title: NSLocalizedString("Address", comment: pageName),
                isOn: settings.requiresAddress,
                action: { [weak self] isOn in
                    self?.settings.requiresAddress = isOn
                }
            )
        )
        return view
    }()
    
    private lazy var switchForCountryCode: ConfigSwitchView = {
        let view = ConfigSwitchView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(
            ConfigSwitchViewModel(
                title: NSLocalizedString("Country Code", comment: pageName),
                isOn: settings.requiresCountryCode,
                action: { [weak self] isOn in
                    self?.settings.requiresCountryCode = isOn
                }
            )
        )
        return view
    }()
    
    let settings: ExamplesKeys.AllSettings
    
    init(settings: ExamplesKeys.AllSettings) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
}

private extension BillingFieldsSettingViewController {
        
    func setupViews() {
        customizeNavigationBackButton()
        view.backgroundColor = .awxColor(.backgroundPrimary)
        view.addSubview(scrollView)
        scrollView.addSubview(stack)
        stack.addArrangedSubview(topView)
        stack.addArrangedSubview(switchForName)
        stack.addArrangedSubview(switchForEmail)
        stack.addArrangedSubview(switchForPhone)
        stack.addArrangedSubview(switchForAddress)
        stack.addArrangedSubview(switchForCountryCode)
        
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 6),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            stack.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor, constant: -32),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
