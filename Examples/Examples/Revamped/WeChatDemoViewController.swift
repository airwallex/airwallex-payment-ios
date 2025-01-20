//
//  WeChatDemoViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex

class WeChatDemoViewController: UIViewController {
    
    struct FieldKey {
        static let appId = "appId"
        static let partnerId = "partnerId"
        static let prepayId = "prepayId"
        static let package = "package"
        static let nonceStr = "nonceStr"
        static let timeStamp = "timeStamp"
        static let sign = "sign"
    }
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxFont(.headline1, weight: .bold)
        view.textColor = .awxTextPrimary
        view.text = "Launch HTML 5 demo"
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
    
    private lazy var fieldViewModels: [ConfigTextFieldViewModel] = [
        ConfigTextFieldViewModel(
            displayName: NSLocalizedString("WeChat App ID", comment: "wechat demo"),
            fieldKey: FieldKey.appId,
            text: "wx4c86d73fe4f82431"
        ),
        ConfigTextFieldViewModel(
            displayName: NSLocalizedString("Partner ID", comment: "wechat demo"),
            fieldKey: FieldKey.partnerId
        ),
        ConfigTextFieldViewModel(
            displayName: NSLocalizedString("Prepay ID", comment: "wechat demo"),
            fieldKey: FieldKey.prepayId
        ),
        ConfigTextFieldViewModel(
            displayName: NSLocalizedString("Package", comment: "wechat demo"),
            fieldKey: FieldKey.package
        ),
        ConfigTextFieldViewModel(
            displayName: NSLocalizedString("NonceStr", comment: "wechat demo"),
            fieldKey: FieldKey.nonceStr
        ),
        ConfigTextFieldViewModel(
            displayName: NSLocalizedString("Time Stamp", comment: "wechat demo"),
            fieldKey: FieldKey.timeStamp
        ),
        ConfigTextFieldViewModel(
            displayName: NSLocalizedString("Sign", comment: "wechat demo"),
            fieldKey: FieldKey.sign
        ),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customiseNavigationBackButton()
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
        stack.addArrangedSubview(titleLabel)
        for viewModel in fieldViewModels {
            let textField = ConfigTextField()
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.setup(viewModel)
            stack.addArrangedSubview(textField)
        }
        
        view.addSubview(bottomView)
        bottomView.addSubview(nextButton)
        
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
        
        guard fieldViewModels.allSatisfy({
            $0.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        }) else {
            showAlert(message: NSLocalizedString("Please fill in all the fields", comment: "wechat demo"))
            return
        }
        var payReq = PayReq()
        payReq.partnerId = fieldViewModels.first(where: { $0.fieldKey == FieldKey.partnerId })?.text ?? ""
        payReq.prepayId = fieldViewModels.first(where: { $0.fieldKey == FieldKey.prepayId })?.text ?? ""
        payReq.package = fieldViewModels.first(where: { $0.fieldKey == FieldKey.package })?.text ?? ""
        payReq.nonceStr = fieldViewModels.first(where: { $0.fieldKey == FieldKey.nonceStr })?.text ?? ""
        payReq.timeStamp = UInt32(fieldViewModels.first(where: { $0.fieldKey == FieldKey.timeStamp })?.text ?? "") ?? 0
        payReq.sign = fieldViewModels.first(where: { $0.fieldKey == FieldKey.sign })?.text ?? ""
        
        Task {
            let success = await WXApi.send(payReq)
            showAlert(message: success ? "Succeed to pay" : "Failed to call WeChat Pay")
        }
    }
}
