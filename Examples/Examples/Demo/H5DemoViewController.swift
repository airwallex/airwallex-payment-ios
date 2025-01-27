//
//  H5DemoViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/20.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex
import Combine

class H5DemoViewController: UIViewController {

    private lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let viewModel = TopViewModel(
            title: NSLocalizedString("Launch HTML 5 demo", comment: "H5 demo")
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
            displayName: NSLocalizedString("Payment URL", comment: "H5 demo placeholder"),
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
            displayName: NSLocalizedString("Referrer URL", comment: "H5 demo placeholder"),
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
        let view = UIButton(style: .primary, title: NSLocalizedString("Next", comment: "H5 demo next action"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onNextButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.awxBorderDecorative.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var keyboardHandler = KeyboardHandler()
    
    private var cancellable: AnyCancellable? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavigationBackButton()
        setupViews()
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
        view.backgroundColor = .awxBackgroundPrimary
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
        guard let url = paymentURLField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !url.isEmpty,
              let referrer = referrerURLField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !referrer.isEmpty else {
            let alert = UIAlertController(
                title: nil,
                message: NSLocalizedString("Please fill in all the fields", comment: "H5 demo view controller"),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Sure", comment: "H5 demo view controller"),
                style: .default)
            )
            present(alert, animated: true)
            return
        }
        
        let webVC = WebViewController()
        webVC.url = url
        webVC.referer = referrer
        navigationController?.pushViewController(webVC, animated: true)
        
        cancellable = NotificationCenter.default.publisher(for: Notification.Name(rawValue: "showSuccessfullVC"))
            .sink {[weak webVC, weak self] _ in
                guard let self else { return }
                if let webVC {
                    webVC.navigationController?.popViewController(animated: true)
                }
                
                let successVC = SuccessViewController()
                self.navigationController?.pushViewController(successVC, animated: true)
                self.cancellable = nil
            }
    }
}
