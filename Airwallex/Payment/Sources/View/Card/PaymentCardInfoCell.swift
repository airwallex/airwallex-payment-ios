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
    var nameOnCardConfigurer: InformativeUserInputViewConfiguring { get }
    
    var errorHintForCardFields: String? { get }
    var callbackForLayoutUpdate: () -> Void { get }
}

class PaymentCardInfoCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxBody
        view.textColor = .awxTextSecondary
        view.text = NSLocalizedString("Card Information", comment: "")
        return view
    }()
    
    private let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cardNumberView: CardNumberInputView = {
        let view = CardNumberInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.userInputTextField.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let expiresTextField: BasicUserInputView = {
        let view = BasicUserInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.maskedCorners = .layerMinXMaxYCorner
        return view
    }()
    
    private let cvcTextField: BasicUserInputView = {
        let view = BasicUserInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.maskedCorners = .layerMaxXMaxYCorner
        
        let image = UIImage(named: "cvc", in: .resource(), compatibleWith: nil)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.stack.addArrangedSubview(imageView)
        return view
    }()
    
    private let hintLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxTextError
        view.font = .awxHint
        return view
    }()
    
    private let nameInputView: InformativeUserInputView = {
        let view = InformativeUserInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let stack: UIStackView = {
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
        hintLabel.text = viewModel.errorHintForCardFields
        
        nameInputView.setup(viewModel.nameOnCardConfigurer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupObservation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private var lastEditingField: UIView?
    
    func setupObservation() {
        
        let adjustLayering = { [weak self] view in
            guard let self else { return }
            let arr: [any ViewConfigurable] = [ self.cardNumberView, self.expiresTextField, self.cvcTextField ]
            for view in arr {
                guard let viewModel = view.viewModel as? any BasicUserInputViewConfiguring else {
                    return
                }
                if !viewModel.isValid {
                    self.container.bringSubviewToFront(view)
                }
            }
            self.container.bringSubviewToFront(view)
        }
        cardNumberView.userInputTextField.textDidBeginEditingPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                adjustLayering(self.cardNumberView)
            }
            .store(in: &cancellables)
        
        expiresTextField.textDidBeginEditingPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                adjustLayering(self.expiresTextField)
            }
            .store(in: &cancellables)
        
        cvcTextField.textDidBeginEditingPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                adjustLayering(self.cvcTextField)
            }
            .store(in: &cancellables)
        
        Publishers.Merge3(
            cardNumberView.userInputTextField.textDidEndEditingPublisher,
            expiresTextField.textDidEndEditingPublisher,
            cvcTextField.textDidEndEditingPublisher
        )
        .sink { [weak self] _ in
            guard let self, let viewModel = self.viewModel else { return }
            self.setup(viewModel)
            viewModel.callbackForLayoutUpdate()
        }
        .store(in: &cancellables)
    }
    
    func setupViews() {
        contentView.addSubview(stack)
        stack.addArrangedSubview(container)
        do {
            container.addSubview(titleLabel)
            container.addSubview(cardNumberView)
            container.addSubview(expiresTextField)
            container.addSubview(cvcTextField)
            container.addSubview(hintLabel)
        }
        
        stack.addArrangedSubview(nameInputView)
        
        cardNumberView.nextInputView = expiresTextField
        expiresTextField.nextInputView = cvcTextField
        cvcTextField.nextInputView = nameInputView
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            cardNumberView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .spacing_4),
            cardNumberView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            cardNumberView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            expiresTextField.topAnchor.constraint(equalTo: cardNumberView.bottomAnchor, constant: -1),
            expiresTextField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            expiresTextField.trailingAnchor.constraint(equalTo: container.centerXAnchor),
            
            cvcTextField.topAnchor.constraint(equalTo: cardNumberView.bottomAnchor, constant: -1),
            cvcTextField.leadingAnchor.constraint(equalTo: container.centerXAnchor, constant: -1),
            cvcTextField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            cvcTextField.bottomAnchor.constraint(equalTo: expiresTextField.bottomAnchor),
            
            hintLabel.topAnchor.constraint(equalTo: cvcTextField.bottomAnchor, constant: .spacing_4),
            hintLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hintLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hintLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}

