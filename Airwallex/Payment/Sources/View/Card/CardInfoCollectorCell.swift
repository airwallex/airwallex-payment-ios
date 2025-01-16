//
//  CardPaymentInfoCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
import Combine

protocol CardInfoCollectorCellConfiguring {
    var cardNumberConfigurer: CardNumberTextFieldConfiguring { get }
    var expireDataConfigurer: BaseTextFieldConfiguring { get }
    var cvcConfigurer: BaseTextFieldConfiguring { get }
    var nameOnCardConfigurer: InfoCollectorTextFieldConfiguring { get }
    
    var errorHintForCardFields: String? { get }
    var triggerLayoutUpdate: () -> Void { get }
}

class CardInfoCollectorCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxBody
        view.textColor = .awxTextPrimary
        view.text = NSLocalizedString("Card Information", comment: "")
        return view
    }()
    
    private let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let numberTextField: CardNumberTextField = {
        let view = CardNumberTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let expiresTextField: BaseTextField = {
        let view = BaseTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = .layerMinXMaxYCorner
        return view
    }()
    
    private let cvcTextField: BaseTextField = {
        let view = BaseTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = .layerMaxXMaxYCorner
        
        let image = UIImage(named: "cvc", in: .resource(), compatibleWith: nil)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.horizontalStack.addArrangedSubview(imageView)
        view.horizontalStack.addSpacer(.spacing_8)
        return view
    }()
    
    private let hintLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxTextError
        view.font = .awxHint
        return view
    }()
    
    private let nameTextField: InfoCollectorTextField = {
        let view = InfoCollectorTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let vStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = .spacing_16
        view.axis = .vertical
        return view
    }()
    
    private(set) var viewModel: CardInfoCollectorCellConfiguring?
    
    func setup(_ viewModel: CardInfoCollectorCellConfiguring) {
        self.viewModel = viewModel
        
        viewModel.cardNumberConfigurer.returnActionHandler = { [weak self] textField in
            self?.expiresTextField.becomeFirstResponder()
        }
        numberTextField.setup(viewModel.cardNumberConfigurer)
        
        viewModel.expireDataConfigurer.returnActionHandler = { [weak self] _ in
            self?.cvcTextField.becomeFirstResponder()
        }
        expiresTextField.setup(viewModel.expireDataConfigurer)
        
        viewModel.cvcConfigurer.returnActionHandler = { [weak self] _ in
            self?.nameTextField.becomeFirstResponder()
        }
        cvcTextField.setup(viewModel.cvcConfigurer)
        hintLabel.text = viewModel.errorHintForCardFields
        
        nameTextField.setup(viewModel.nameOnCardConfigurer)
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
}

private extension CardInfoCollectorCell {
    
    func setupObservation() {
        let updateLayering = { [weak self] in
            guard let self else { return }
            let arr = [ self.numberTextField, self.expiresTextField, self.cvcTextField ]
            
            for view in arr {
                guard let viewModel = view.viewModel else { continue }
                if !viewModel.isValid {
                    self.container.bringSubviewToFront(view)
                }
            }
            if let editingField = arr.first(where: { $0.isFirstResponder }) {
                self.container.bringSubviewToFront(editingField)
            }
        }
        
        Publishers.Merge3(
            numberTextField.textDidBeginEditingPublisher,
            expiresTextField.textDidBeginEditingPublisher,
            cvcTextField.textDidBeginEditingPublisher
        )
        .sink { _ in
            updateLayering()
        }
        .store(in: &cancellables)
        
        Publishers.Merge4(
            numberTextField.textDidEndEditingPublisher,
            expiresTextField.textDidEndEditingPublisher,
            cvcTextField.textDidEndEditingPublisher,
            nameTextField.textDidEndEditingPublisher
        )
        .sink { [weak self] textField in
            guard let self, let viewModel = self.viewModel else { return }
            self.hintLabel.text = viewModel.errorHintForCardFields
            if textField !== nameTextField {
                updateLayering()
            }
            viewModel.triggerLayoutUpdate()
        }
        .store(in: &cancellables)
    }
    
    func setupViews() {
        contentView.addSubview(vStack)
        vStack.addArrangedSubview(container)
        do {
            container.addSubview(titleLabel)
            container.addSubview(numberTextField)
            container.addSubview(expiresTextField)
            container.addSubview(cvcTextField)
            container.addSubview(hintLabel)
        }
        
        vStack.addArrangedSubview(nameTextField)
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            numberTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .spacing_4),
            numberTextField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            numberTextField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            expiresTextField.topAnchor.constraint(equalTo: numberTextField.bottomAnchor, constant: -1),
            expiresTextField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            expiresTextField.trailingAnchor.constraint(equalTo: container.centerXAnchor),
            
            cvcTextField.topAnchor.constraint(equalTo: numberTextField.bottomAnchor, constant: -1),
            cvcTextField.leadingAnchor.constraint(equalTo: container.centerXAnchor, constant: -1),
            cvcTextField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            cvcTextField.bottomAnchor.constraint(equalTo: expiresTextField.bottomAnchor),
            
            hintLabel.topAnchor.constraint(equalTo: cvcTextField.bottomAnchor, constant: .spacing_4),
            hintLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hintLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hintLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}

