//
//  CardPaymentInfoCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
import Combine

protocol PaymentCardInfoCellConfiguring {
    var cardNumberConfigurer: CardNumberInputViewConfiguring { get }
    var expireDataConfigurer: ErrorHintableTextFieldConfiguring { get }
    var cvcConfigurer: ErrorHintableTextFieldConfiguring { get }
}

class PaymentCardInfoCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    let label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxBody
        view.textColor = .awxTextSecondary
        view.text = NSLocalizedString("Card Information", comment: "")
        return view
    }()
    
    let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let cardNumberView: CardNumberInputView = {
        let view = CardNumberInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.userInputTextField.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    let expiresTextField: BasicUserInputView = {
        let view = BasicUserInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.maskedCorners = .layerMinXMaxYCorner
        return view
    }()
    
    let cvcTextField: BasicUserInputView = {
        let view = BasicUserInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.maskedCorners = .layerMaxXMaxYCorner
        
        let image = UIImage(named: "cvc", in: .payment, compatibleWith: nil)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.stack.addArrangedSubview(imageView)
        return view
    }()
    
    let nameInputView: InformativeUserInputView = {
        let view = InformativeUserInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topLabel.text = NSLocalizedString("Name on card", comment: "")
        return view
    }()
    
    let emailInputView: InformativeUserInputView = {
        let view = InformativeUserInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topLabel.text = NSLocalizedString("Email", comment: "")
        view.textField.update(for: .email)
        view.textField.keyboardType = .emailAddress
        return view
    }()
    
    let stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = .spacing_16
        view.axis = .vertical
        return view
    }()
    
    private(set) var viewModel: PaymentCardInfoCellConfiguring?
    
    func setup(_ viewModel: PaymentCardInfoCellConfiguring) {
        self.viewModel = viewModel
        cardNumberView.setup(viewModel.cardNumberConfigurer)
        expiresTextField.setup(viewModel.expireDataConfigurer)
        cvcTextField.setup(viewModel.cvcConfigurer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(stack)
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(container)
        do {
            container.addSubview(cardNumberView)
            container.addSubview(expiresTextField)
            container.addSubview(cvcTextField)
        }
        
        stack.addArrangedSubview(nameInputView)
        stack.addArrangedSubview(emailInputView)
        nameInputView.nextInputView = emailInputView
        nameInputView.textField.returnKeyType = .next
        
        let constraints = [
            cardNumberView.topAnchor.constraint(equalTo: container.topAnchor),
            cardNumberView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            cardNumberView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            expiresTextField.topAnchor.constraint(equalTo: cardNumberView.bottomAnchor, constant: -1),
            expiresTextField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            expiresTextField.trailingAnchor.constraint(equalTo: container.centerXAnchor),
            expiresTextField.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            cvcTextField.topAnchor.constraint(equalTo: cardNumberView.bottomAnchor, constant: -1),
            cvcTextField.leadingAnchor.constraint(equalTo: container.centerXAnchor, constant: -1),
            cvcTextField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            cvcTextField.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}

