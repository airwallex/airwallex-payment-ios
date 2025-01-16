//
//  Untitled.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Combine

protocol BillingInfoCellConfiguring {
    var canReuseShippingAddress: Bool { get }
    var shouldReuseShippingAddress: Bool { get }
    var firstNameConfigurer: BaseTextFieldConfiguring { get }
    var lastNameConfigurer: BaseTextFieldConfiguring { get }
    var countryConfigurer: OptionSelectionViewConfiguring { get }
    var streetConfigurer: BaseTextFieldConfiguring { get }
    var stateConfigurer: BaseTextFieldConfiguring { get }
    var cityConfigurer: BaseTextFieldConfiguring { get }
    var zipConfigurer: BaseTextFieldConfiguring { get }
    var phoneConfigurer: BaseTextFieldConfiguring { get }
    var emailConfigurer: BaseTextFieldConfiguring { get }
    
    var errorHintForBillingFields: String? { get }
    var triggerLayoutUpdate: () -> Void { get }
    var toggleReuseSelection: () -> Void { get }
}

class BillingInfoCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font  = .awxBody
        view.textColor = .awxTextPrimary
        view.text = NSLocalizedString("Billing Address", bundle: .payment, comment: "")
        return view
    }()
    
    private lazy var reuseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(
            NSLocalizedString("Same as shipping address", bundle: .payment, comment: "checkbox in checkout view"),
            for: .normal
        )
        button.setTitleColor(.awxTextPrimary, for: .normal)
        button.titleLabel?.font = .awxHint
        
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        let normalImage = UIImage(systemName: "square", withConfiguration: config)!
            .withTintColor(.awxBorderPerceivable, renderingMode: .alwaysOriginal)
        
        let selectedImage = UIImage(systemName: "checkmark.square.fill", withConfiguration: config)!
            .withTintColor(.awxBackgroundInteractive, renderingMode: .alwaysOriginal)
        
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.setImage(selectedImage, for: [.selected, .highlighted])
        
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        
        button.addTarget(self, action: #selector(reuseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var countrySelectionView: OptionSelectionView = {
        let view = OptionSelectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMaxXMinYCorner ]
        return view
    }()
    
    private let streetTextField: BaseTextField = {
        let view = BaseTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = []
        return view
    }()
    
    private let stateTextField: BaseTextField = {
        let view = BaseTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = []
        return view
    }()
    
    private let cityTextField: BaseTextField = {
        let view = BaseTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = []
        return view
    }()
    
    private let zipCodeTextField: BaseTextField = {
        let view = BaseTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = []
        return view
    }()
    
    private let firstNameTextField: BaseTextField = {
        let view = BaseTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = []
        return view
    }()
    
    private let lastNameTextField: BaseTextField = {
        let view = BaseTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = []
        return view
    }()
    
    private let phoneTextField: BaseTextField = {
        let view = BaseTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = []
        return view
    }()
    
    private let emailTextField: BaseTextField = {
        let view = BaseTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMaxXMaxYCorner ]
        return view
    }()
    
    private let hintLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxTextError
        view.font = .awxHint
        return view
    }()
    
    private let stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = -1
        view.alignment = .leading
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupObservation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var viewModel: (any BillingInfoCellConfiguring)?
    
    func setup(_ viewModel: any BillingInfoCellConfiguring) {
        self.viewModel = viewModel
        reuseButton.isHidden = !viewModel.canReuseShippingAddress
        reuseButton.isSelected = viewModel.shouldReuseShippingAddress
        
        countrySelectionView.setup(viewModel.countryConfigurer)
        
        viewModel.streetConfigurer.returnActionHandler = { [weak self] _ in
            self?.stateTextField.becomeFirstResponder()
        }
        streetTextField.setup(viewModel.streetConfigurer)
        
        viewModel.stateConfigurer.returnActionHandler = { [weak self] _ in
            self?.cityTextField.becomeFirstResponder()
        }
        stateTextField.setup(viewModel.stateConfigurer)
        
        viewModel.cityConfigurer.returnActionHandler = { [weak self] _ in
            self?.zipCodeTextField.becomeFirstResponder()
        }
        cityTextField.setup(viewModel.cityConfigurer)
        
        viewModel.zipConfigurer.returnActionHandler = { [weak self] _ in
            self?.firstNameTextField.becomeFirstResponder()
        }
        zipCodeTextField.setup(viewModel.zipConfigurer)
        
        viewModel.firstNameConfigurer.returnActionHandler = { [weak self] _ in
            self?.lastNameTextField.becomeFirstResponder()
        }
        firstNameTextField.setup(viewModel.firstNameConfigurer)
        
        viewModel.lastNameConfigurer.returnActionHandler = { [weak self] _ in
            self?.phoneTextField.becomeFirstResponder()
        }
        lastNameTextField.setup(viewModel.lastNameConfigurer)
        
        viewModel.phoneConfigurer.returnActionHandler = { [weak self] _ in
            self?.emailTextField.becomeFirstResponder()
        }
        phoneTextField.setup(viewModel.phoneConfigurer)
        
        emailTextField.setup(viewModel.emailConfigurer)
        
        hintLabel.text = viewModel.errorHintForBillingFields
        hintLabel.isHidden = (hintLabel.text ?? "").isEmpty
    }
    
    @objc func reuseButtonTapped() {
        reuseButton.isSelected = !reuseButton.isSelected
        viewModel?.toggleReuseSelection()
    }
}

private extension BillingInfoCell {
    func setupViews() {
        contentView.addSubview(stack)
        stack.addArrangedSubview(titleLabel)
        stack.setCustomSpacing(.spacing_8, after: titleLabel)
        stack.addArrangedSubview(reuseButton)
        stack.setCustomSpacing(.spacing_12, after: reuseButton)
        
        stack.addArrangedSubview(countrySelectionView)
        stack.addArrangedSubview(streetTextField)
        
        let stateCitySpacer = stack.addSpacer(40, priority: .defaultLow)
        do {
            // horizontal stack for state and city
            stack.addSubview(stateTextField)
            stack.addSubview(cityTextField)
        }
        
        stack.addArrangedSubview(zipCodeTextField)
        
        let nameSpacer = stack.addSpacer(40, priority: .defaultLow)
        do {
            // horizontal stack for first name and last name
            stack.addSubview(firstNameTextField)
            stack.addSubview(lastNameTextField)
        }
        
        stack.addArrangedSubview(phoneTextField)
        stack.addArrangedSubview(emailTextField)
        
        stack.setCustomSpacing(.spacing_4, after: emailTextField)
        stack.addArrangedSubview(hintLabel)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            nameSpacer.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor, multiplier: 1),
            firstNameTextField.topAnchor.constraint(equalTo: nameSpacer.topAnchor),
            firstNameTextField.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            firstNameTextField.trailingAnchor.constraint(equalTo: stack.centerXAnchor, constant: 1),
            lastNameTextField.topAnchor.constraint(equalTo: nameSpacer.topAnchor),
            lastNameTextField.leadingAnchor.constraint(equalTo: stack.centerXAnchor),
            lastNameTextField.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            
            countrySelectionView.widthAnchor.constraint(equalTo: stack.widthAnchor),
            streetTextField.widthAnchor.constraint(equalTo: stack.widthAnchor),
            
            stateCitySpacer.heightAnchor.constraint(equalTo: stateTextField.heightAnchor, multiplier: 1),
            stateTextField.topAnchor.constraint(equalTo: stateCitySpacer.topAnchor),
            stateTextField.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            stateTextField.trailingAnchor.constraint(equalTo: stack.centerXAnchor, constant: 1),
            cityTextField.topAnchor.constraint(equalTo: stateCitySpacer.topAnchor),
            cityTextField.leadingAnchor.constraint(equalTo: stack.centerXAnchor),
            cityTextField.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            
            zipCodeTextField.widthAnchor.constraint(equalTo: stack.widthAnchor),
            emailTextField.widthAnchor.constraint(equalTo: stack.widthAnchor),
            phoneTextField.widthAnchor.constraint(equalTo: stack.widthAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupObservation() {
        let fields = [
            streetTextField,
            stateTextField,
            cityTextField,
            zipCodeTextField,
            firstNameTextField,
            lastNameTextField,
            phoneTextField,
            emailTextField
        ]
        
        Publishers.MergeMany(fields.map { $0.textDidBeginEditingPublisher })
            .sink { [weak self] _ in
                self?.validateInputAndUpdateLayering(fields)
            }
            .store(in: &cancellables)
        
        Publishers.MergeMany(fields.map { $0.textDidEndEditingPublisher})
            .sink { [weak self] textField in
                guard let self, let viewModel = self.viewModel else { return }
                self.hintLabel.text = viewModel.errorHintForBillingFields
                self.hintLabel.isHidden = (self.hintLabel.text ?? "").isEmpty
                self.validateInputAndUpdateLayering(fields)
                viewModel.triggerLayoutUpdate()
            }
            .store(in: &cancellables)
    }
    
    func validateInputAndUpdateLayering(_ fields: [BaseTextField]) {
        for view in fields {
            guard let viewModel = view.viewModel else { continue }
            if !viewModel.isValid {
                stack.bringSubviewToFront(view)
            }
        }
        if let editingField = fields.first(where: { $0.isFirstResponder }) {
            stack.bringSubviewToFront(editingField)
        }
    }

}
