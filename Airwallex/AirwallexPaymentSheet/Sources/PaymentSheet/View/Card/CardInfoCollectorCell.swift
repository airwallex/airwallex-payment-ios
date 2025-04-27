//
//  CardPaymentInfoCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
import Combine

class CardInfoCollectorCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxFont(.body2)
        view.textColor = .awxColor(.textPrimary)
        view.text = NSLocalizedString("Card Information", bundle: .paymentSheet, comment: "Card Info Cell - title")
        return view
    }()
    
    private let numberTextField: CardNumberTextField = {
        let view = CardNumberTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let expiresTextField: BaseTextField = {
        let view = BaseTextField<InfoCollectorTextFieldViewModel>()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = .layerMinXMaxYCorner
        return view
    }()
    
    private let cvcTextField: BaseTextField = {
        let view = BaseTextField<InfoCollectorTextFieldViewModel>()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = .layerMaxXMaxYCorner
        
        let image = UIImage(named: "cvc", in: .resource(), compatibleWith: nil)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.horizontalStack.addArrangedSubview(imageView)
        view.horizontalStack.addSpacer(8)
        return view
    }()
    
    private let hintLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxColor(.textError)
        view.font = .awxFont(.caption2)
        return view
    }()
    
    private(set) var viewModel: CardInfoCollectorCellViewModel?
    
    func setup(_ viewModel: CardInfoCollectorCellViewModel) {
        self.viewModel = viewModel
        
        viewModel.cardNumberConfigurer.returnActionHandler = { [weak self] _ in
            self?.expiresTextField.becomeFirstResponder() ?? false
        }
        numberTextField.setup(viewModel.cardNumberConfigurer)
        
        viewModel.expireDataConfigurer.returnActionHandler = { [weak self] _ in
            self?.cvcTextField.becomeFirstResponder() ?? false
        }
        expiresTextField.setup(viewModel.expireDataConfigurer)
        cvcTextField.setup(viewModel.cvcConfigurer)
        hintLabel.text = viewModel.errorHintForCardFields
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
    
    var allFields: [UIResponder] {
        [numberTextField, expiresTextField, cvcTextField]
    }
    
    override var canBecomeFirstResponder: Bool {
        allFields.contains { $0.canBecomeFirstResponder }
    }
    
    override func becomeFirstResponder() -> Bool {
        allFields.first { $0.canBecomeFirstResponder }?.becomeFirstResponder() ?? false
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        endEditing(true)
    }
    
    override var canResignFirstResponder: Bool {
        allFields.contains { $0.canResignFirstResponder }
    }
    
    override var isFirstResponder: Bool {
        allFields.contains { $0.isFirstResponder }
    }
}

private extension CardInfoCollectorCell {
    
    func setupObservation() {
        let updateLayering = { [weak self] in
            guard let self else { return }
            let arr: [(view: UIView, isValid: Bool, isFirstResponder: Bool)] = [
                (self.numberTextField, self.numberTextField.viewModel?.isValid ?? true, self.numberTextField.isFirstResponder),
                (self.expiresTextField, self.expiresTextField.viewModel?.isValid ?? true, self.expiresTextField.isFirstResponder),
                (self.cvcTextField, self.cvcTextField.viewModel?.isValid ?? true, self.cvcTextField.isFirstResponder)
            ]
            
            for (view, isValid, _) in arr {
                if !isValid {
                    self.contentView.bringSubviewToFront(view)
                }
            }
            if let editingField = arr.first(where: { $0.isFirstResponder })?.view {
                self.contentView.bringSubviewToFront(editingField)
            }
        }
        
        Publishers.MergeMany(
            numberTextField.textField.textDidBeginEditingPublisher,
            expiresTextField.textField.textDidBeginEditingPublisher,
            cvcTextField.textField.textDidBeginEditingPublisher,
            numberTextField.textField.textDidEndEditingPublisher,
            expiresTextField.textField.textDidEndEditingPublisher,
            cvcTextField.textField.textDidEndEditingPublisher
        )
        .debounce(for: .milliseconds(1), scheduler: DispatchQueue.main)
        .sink { _ in updateLayering() }
        .store(in: &cancellables)
    }
    
    func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(numberTextField)
        contentView.addSubview(expiresTextField)
        contentView.addSubview(cvcTextField)
        contentView.addSubview(hintLabel)
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            numberTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            numberTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            numberTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            expiresTextField.topAnchor.constraint(equalTo: numberTextField.bottomAnchor, constant: -1),
            expiresTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            expiresTextField.trailingAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            cvcTextField.topAnchor.constraint(equalTo: numberTextField.bottomAnchor, constant: -1),
            cvcTextField.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -1),
            cvcTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cvcTextField.bottomAnchor.constraint(equalTo: expiresTextField.bottomAnchor),
            
            hintLabel.topAnchor.constraint(equalTo: cvcTextField.bottomAnchor, constant: 4),
            hintLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hintLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hintLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}

