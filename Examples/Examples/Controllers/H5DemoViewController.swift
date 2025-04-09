//
//  H5DemoViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/20.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Combine
#if canImport(Airwallex)
import Airwallex
#elseif canImport(AirwallexPayment)
import AirwallexPayment
import AirwallexCore
#endif

class H5DemoViewController: UIViewController {
    private let localizationComment = "H5 demo view controller"
    
    private lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let viewModel = TopViewModel(
            title: NSLocalizedString("Launch HTML 5 demo", comment: localizationComment)
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
    
    private lazy var paymentURLField: ConfigTextField = {
        let view = ConfigTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let viewModel = ConfigTextFieldViewModel(
            displayName: "Payment URL",
            text: nil,
            caption: nil
        )
        view.setup(viewModel)
        return view
    }()
    
    private lazy var referrerURLField: ConfigTextField = {
        let view = ConfigTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let viewModel = ConfigTextFieldViewModel(
            displayName: "Referrer URL",
            text: "https://checkout.airwallex.com",
            caption: nil
        )
        view.setup(viewModel)
        return view
    }()
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 24
        view.axis = .vertical
        return view
    }()
    
    private lazy var nextButton: UIButton = {
        let view = AWXButton(style: .primary, title: NSLocalizedString("Next", comment: localizationComment))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onNextButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = .awxCGColor(.borderDecorative)
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var keyboardHandler = KeyboardHandler()
    
    private var cancellables = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavigationBackButton()
        setupViews()
        
        let publishers = [
            NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification, object: paymentURLField.textField),
            NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification, object: referrerURLField.textField)
        ]
        Publishers.MergeMany(publishers)
            .filter { [weak self] _ in
                guard let self,
                      let url = self.paymentURLField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !url.isEmpty,
                      let referrer = self.referrerURLField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !referrer.isEmpty else {
                    return false
                }
                return true
            }
            .sink { [weak self] _ in
                guard let self else { return }
                self.onNextButtonTapped()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: PaymentResultViewController.paymentResultNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.navigationController?.popToViewController(self, animated: false)
                let successVC = PaymentResultViewController()
                self.navigationController?.pushViewController(successVC, animated: true)
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
    
    private func setupViews() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        view.backgroundColor = .awxColor(.backgroundPrimary)
        view.addSubview(scrollView)
        scrollView.addSubview(stack)
        stack.addArrangedSubview(topView)
        stack.addArrangedSubview(paymentURLField)
        stack.addArrangedSubview(referrerURLField)
        
        view.addSubview(bottomView)
        bottomView.addSubview(nextButton)
        
        var constraints = [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            stack.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor, constant: -32),
            
            bottomView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -1),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 1),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            nextButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 16),
            nextButton.leadingAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            nextButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 52),
        ]
        let nextButtonBottomConstraint = nextButton.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -40)
        nextButtonBottomConstraint.priority = .required - 1
        constraints.append(nextButtonBottomConstraint)
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func onNextButtonTapped() {
        var url = paymentURLField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard url.isEmpty == false,
              let referrer = referrerURLField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !referrer.isEmpty else {
            showAlert(message: NSLocalizedString("Please fill in all the fields", comment: localizationComment))
            return
        }
        
        guard let URL  = URL(string: url) else {
            showAlert(message: "Invalid URL")
            return
        }
        
        // add default scheme for url
        if URL.scheme == nil {
            url = "https://" + url
        }
        
        let webVC = WebViewController(url: url, referer: referrer)
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            bottomView.layer.borderColor = .awxCGColor(.borderDecorative)
        }
    }
}
