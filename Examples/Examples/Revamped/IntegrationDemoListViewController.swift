//
//  IntegrationDemoListViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class IntegrationDemoListViewController: UIViewController {
    
    enum IntegrationType {
        case UI
        case API
    }
    
    struct ActionViewModel {
        let title: String
        let action: () -> Void
    }
    
    private let commentForLocalization = "UI integration demo"
    
    private lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let title = integrationType == .UI ? NSLocalizedString("Integrate with Airwallex UI", comment: "UI integration demo")
        : NSLocalizedString("Integrate with low-level API", comment: "UI integration demo")
        
        let viewModel = TopViewModel(
            title: title,
            actionIcon: UIImage(named: "gear")?.withTintColor(.awxIconLink, renderingMode: .alwaysOriginal),
            actionHandler: { [weak self] in
                self?.onSettingButtonTapped()
            }
        )
        view.setup(viewModel)
        return view
    }()
    
    private lazy var optionView: OptionSelectView = {
        let view = OptionSelectView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.keyboardDismissMode = .interactive
        return view
    }()
    
    private lazy var topStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 16
        view.axis = .vertical
        return view
    }()
    
    private lazy var bottomStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 16
        view.axis = .vertical
        return view
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .awxBorderDecorative
        return view
    }()
    
    private lazy var viewModelsForUIIntegration: [ActionViewModel] = [
        ActionViewModel(
            title: NSLocalizedString("Launch default payments list", comment: commentForLocalization),
            action: { [weak self] in
                self?.launchDefaultPaymentsList()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Launch custom payments list", comment: commentForLocalization),
            action: { [weak self] in
                self?.launchCustompaymentsList()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Launch card payment", comment: commentForLocalization),
            action: { [weak self] in
                self?.launchCardPayment()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Launch card payment (dialog)", comment: commentForLocalization),
            action: { [weak self] in
                self?.launchCardPaymentDialog()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Launch shipping address (dialog)", comment: commentForLocalization),
            action: { [weak self] in
                self?.launchShippingAddressDialog()
            }
        ),
    ]
    
    private lazy var viewModelsForAPIIntegration: [ActionViewModel] = [
        ActionViewModel(
            title: NSLocalizedString("Pay with card", comment: commentForLocalization),
            action: { [weak self] in
                self?.payWithCard(autoSave: false)
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Pay with card and save card", comment: commentForLocalization),
            action: { [weak self] in
                self?.payWithCard(autoSave: true)
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("pay with card and trigger 3DS", comment: commentForLocalization),
            action: { [weak self] in
                self?.payWithCardAndTrigger3DS()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("pay with Apple Pay", comment: commentForLocalization),
            action: { [weak self] in
                self?.payWithApplePay()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Get payment methods", comment: commentForLocalization),
            action: { [weak self] in
                self?.getPaymentMethods()
            }
        ),
        ActionViewModel(
            title: NSLocalizedString("Get saved card methods", comment: commentForLocalization),
            action: { [weak self] in
                self?.getSavedCardMethods()
            }
        ),
    ]
    
    private lazy var shippingAddress: AWXPlaceDetails = {
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
        return AWXPlaceDetails.decode(fromJSON: shipping) as! AWXPlaceDetails
    }()
    
    let integrationType: IntegrationType
    
    init(_ integrationStyle: IntegrationType) {
        self.integrationType = integrationStyle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customizeNavigationBackButton()
        setupViews()
        setupCheckoutMode()
    }
}

private extension IntegrationDemoListViewController {
    
    func setupViews() {
        view.backgroundColor = .awxBackgroundPrimary
        view.addSubview(scrollView)
        scrollView.addSubview(topStack)
        do {
            topStack.addArrangedSubview(topView)
            topStack.setCustomSpacing(24, after: topView)
            topStack.addArrangedSubview(optionView)
        }
        
        scrollView.addSubview(separator)
        scrollView.addSubview(bottomStack)
        do {
            let actions = integrationType == .UI ? viewModelsForUIIntegration : viewModelsForAPIIntegration
            for action in actions {
                let view = UIButton(style: .secondary, title: action.title)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.addTarget(self, action: #selector(onActionButtonTapped(_:)), for: .touchUpInside)
                bottomStack.addArrangedSubview(view)
            }
        }
        let heightRef = UIView()
        heightRef.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(heightRef)
        
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            topStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 6),
            topStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            topStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            topStack.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor, constant: -32),
            
            separator.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            bottomStack.topAnchor.constraint(greaterThanOrEqualTo: topStack.bottomAnchor, constant: 64),
            bottomStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            bottomStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            bottomStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            bottomStack.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor, constant: -32),
            
            heightRef.widthAnchor.constraint(equalToConstant: 10),
            heightRef.topAnchor.constraint(equalTo: scrollView.topAnchor),
            heightRef.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            heightRef.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            heightRef.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.safeAreaLayoutGuide.heightAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupCheckoutMode() {
        let viewModel = OptionSelectViewModel(
            displayName: NSLocalizedString("Payment type", comment: "mobile SDK demo"),
            selectedOption: AirwallexExamplesKeys.shared().checkoutMode.localizedDescription,
            handleSelection: { [weak self] in
                self?.handleUserTapOptionSelectView()
            }
        )
        optionView.setup(viewModel)
    }
    
    func onSettingButtonTapped() {
        let optionsViewController = UIStoryboard(name: "Main", bundle: nil).createOptionsViewController()!
        navigationController?.pushViewController(optionsViewController, animated: true)
    }

    func handleUserTapOptionSelectView() {
        showOptions(AirwallexCheckoutMode.allCases.map({ $0.localizedDescription }), sender: optionView) { index, _ in
            guard let checkoutMode = AirwallexCheckoutMode(rawValue: index) else { return }
            AirwallexExamplesKeys.shared().checkoutMode = checkoutMode
            self.setupCheckoutMode()
        }
    }
    
    @objc func onActionButtonTapped(_ sender: UIButton) {
        switch integrationType {
        case .UI:
            guard let title = sender.currentTitle,
                  let viewModel = viewModelsForUIIntegration.first(where: { $0.title == title }) else {
                return
            }
            viewModel.action()
        case .API:
            guard let title = sender.currentTitle,
                  let viewModel = viewModelsForAPIIntegration.first(where: { $0.title == title }) else {
                return
            }
            viewModel.action()
        }
    }
}

//  UI Integration actions
private extension IntegrationDemoListViewController {
    
    func launchDefaultPaymentsList() {
        AirwallexExamplesKeys.shared().cardMethodOnly = false
        let viewController = UIStoryboard.instantiateCartViewController()!
        viewController.preferredPaymentLaunchStyle = .push
        viewController.shipping = shippingAddress
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func launchCustompaymentsList() {
        AirwallexExamplesKeys.shared().cardMethodOnly = false
        let viewController = UIStoryboard.instantiateCartViewController()!
        viewController.preferredPaymentLaunchStyle = .push
        viewController.paymentMethods = [ "applepay", "card", "alipaycn" ]
        viewController.shipping = shippingAddress
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func launchCardPayment() {
        AirwallexExamplesKeys.shared().cardMethodOnly = true
        let viewController = UIStoryboard.instantiateCartViewController()!
        viewController.preferredPaymentLaunchStyle = .push
        viewController.shipping = shippingAddress
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func launchCardPaymentDialog() {
        AirwallexExamplesKeys.shared().cardMethodOnly = true
        let viewController = UIStoryboard.instantiateCartViewController()!
        viewController.preferredPaymentLaunchStyle = .present
        viewController.shipping = shippingAddress
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func launchShippingAddressDialog() {
        let controller = AWXShippingViewController(nibName: nil, bundle: nil)
        controller.delegate = self
        controller.shipping = shippingAddress
        let nav = UINavigationController(rootViewController: controller)
        navigationController?.present(nav, animated: true)
    }
}

// low level API integration actions
private extension IntegrationDemoListViewController {
    func payWithCard(autoSave: Bool) {
//        let card
    }
    
    func payWithCardAndTrigger3DS() {
        showAlert(message: "TODO")
    }
    
    func payWithApplePay() {
        showAlert(message: "TODO")
    }
    
    func getPaymentMethods() {
        showAlert(message: "TODO")
    }
    
    func getSavedCardMethods() {
        showAlert(message: "TODO")
    }
}

extension IntegrationDemoListViewController: AWXShippingViewControllerDelegate {
    func shippingViewController(_ controller: AWXShippingViewController, didEditShipping shipping: AWXPlaceDetails) {
        navigationController?.popToViewController(self, animated: true)
        shippingAddress = shipping
    }
}
