//
//  UIIntegrationDemoViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class UIIntegrationDemoViewController: UIViewController {
    
    private let commentForLocalization = "UI integration demo"
    
    private lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let viewModel = TopViewModel(
            title: NSLocalizedString("Integrate with Airwallex UI", comment: "UI integration demo"),
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
    
    private lazy var defaultPaymentlistButton = {
        let view = UIButton(style: .secondary, title: NSLocalizedString("Launch default payments list", comment: commentForLocalization))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onDefaultPaymentListButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var customPaymentlistButton = {
        let view = UIButton(style: .secondary, title: NSLocalizedString("Launch custom payments list", comment: commentForLocalization))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onCustomPaymentListButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var cardPaymentButton = {
        let view = UIButton(style: .secondary, title: NSLocalizedString("Launch card payment", comment: commentForLocalization))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onCardPaymentButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var cardPaymentDialogButton = {
        let view = UIButton(style: .secondary, title: NSLocalizedString("Launch card payment (dialog)", comment: commentForLocalization))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onCardPaymentDialogButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var shippingAddressDialogButton = {
        let view = UIButton(style: .secondary, title: NSLocalizedString("Launch shipping address (dialog)", comment: commentForLocalization))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onShippingAddressDialogButtonTapped), for: .touchUpInside)
        return view
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customizeNavigationBackButton()
        setupViews()
        setupCheckoutMode()
    }
}

private extension UIIntegrationDemoViewController {
    
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
            bottomStack.addArrangedSubview(defaultPaymentlistButton)
            bottomStack.addArrangedSubview(customPaymentlistButton)
            bottomStack.addArrangedSubview(cardPaymentButton)
            bottomStack.addArrangedSubview(cardPaymentDialogButton)
            bottomStack.addArrangedSubview(shippingAddressDialogButton)
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
    
    @objc func onDefaultPaymentListButtonTapped() {
        AirwallexExamplesKeys.shared().cardMethodOnly = false
        let viewController = UIStoryboard.instantiateCartViewController()!
        viewController.preferredPaymentLaunchStyle = .push
        viewController.shipping = shippingAddress
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func onCustomPaymentListButtonTapped() {
        AirwallexExamplesKeys.shared().cardMethodOnly = false
        let viewController = UIStoryboard.instantiateCartViewController()!
        viewController.preferredPaymentLaunchStyle = .push
        viewController.paymentMethods = [ "applepay", "card", "alipaycn" ]
        viewController.shipping = shippingAddress
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func onCardPaymentButtonTapped() {
        AirwallexExamplesKeys.shared().cardMethodOnly = true
        let viewController = UIStoryboard.instantiateCartViewController()!
        viewController.preferredPaymentLaunchStyle = .push
        viewController.shipping = shippingAddress
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func onCardPaymentDialogButtonTapped() {
        AirwallexExamplesKeys.shared().cardMethodOnly = true
        let viewController = UIStoryboard.instantiateCartViewController()!
        viewController.preferredPaymentLaunchStyle = .present
        viewController.shipping = shippingAddress
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func onShippingAddressDialogButtonTapped() {
        let controller = AWXShippingViewController(nibName: nil, bundle: nil)
        controller.delegate = self
        controller.shipping = shippingAddress
        let nav = UINavigationController(rootViewController: controller)
        navigationController?.present(nav, animated: true)
    }
}

extension UIIntegrationDemoViewController: AWXShippingViewControllerDelegate {
    func shippingViewController(_ controller: AWXShippingViewController, didEditShipping shipping: AWXPlaceDetails) {
        navigationController?.popToViewController(self, animated: true)
        shippingAddress = shipping
    }
}
