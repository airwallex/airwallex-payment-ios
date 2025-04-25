//
//  BillingInfoCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Combine

class BillingInfoCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font  = .awxFont(.body2)
        view.textColor = .awxColor(.textPrimary)
        view.text = NSLocalizedString("Billing Address", bundle: .paymentSheet, comment: "")
        return view
    }()
    
    private lazy var reuseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(
            NSLocalizedString("Same as shipping address", bundle: .paymentSheet, comment: "checkbox in checkout view"),
            for: .normal
        )
        button.setTitleColor(.awxColor(.textPrimary), for: .normal)
        button.titleLabel?.font = .awxFont(.caption2)
        
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        let normalImage = UIImage(systemName: "square", withConfiguration: config)!
            .withTintColor(.awxColor(.borderPerceivable), renderingMode: .alwaysOriginal)
        
        let selectedImage = UIImage(systemName: "checkmark.square.fill", withConfiguration: config)!
            .withTintColor(.awxColor(.backgroundInteractive), renderingMode: .alwaysOriginal)
        
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
        let view = OptionSelectionView<CountrySelectionViewModel>()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMaxXMinYCorner ]
        return view
    }()
    
    private let streetTextField: BaseTextField = {
        let view = BaseTextField<InfoCollectorTextFieldViewModel>()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = []
        return view
    }()
    
    private let stateTextField: BaseTextField = {
        let view = BaseTextField<InfoCollectorTextFieldViewModel>()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = []
        return view
    }()
    
    private let cityTextField: BaseTextField = {
        let view = BaseTextField<InfoCollectorTextFieldViewModel>()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = []
        return view
    }()
    
    private let zipCodeTextField: BaseTextField = {
        let view = BaseTextField<InfoCollectorTextFieldViewModel>()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.box.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()
    
    private let hintLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxColor(.textError)
        view.font = .awxFont(.caption2)
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
    
    private(set) var viewModel: BillingInfoCellViewModel?
    
    func setup(_ viewModel: BillingInfoCellViewModel) {
        self.viewModel = viewModel
        reuseButton.isHidden = !viewModel.canReusePrefilledAddress
        reuseButton.isSelected = viewModel.shouldReusePrefilledAddress
        
        countrySelectionView.setup(viewModel.countryConfigurer)
        
        viewModel.streetConfigurer.returnActionHandler = { [weak self] _ in
            self?.stateTextField.becomeFirstResponder() ?? false
        }
        streetTextField.setup(viewModel.streetConfigurer)
        
        viewModel.stateConfigurer.returnActionHandler = { [weak self] _ in
            self?.cityTextField.becomeFirstResponder() ?? false
        }
        stateTextField.setup(viewModel.stateConfigurer)
        
        viewModel.cityConfigurer.returnActionHandler = { [weak self] _ in
            self?.zipCodeTextField.becomeFirstResponder()  ?? false
        }
        cityTextField.setup(viewModel.cityConfigurer)
        
        zipCodeTextField.setup(viewModel.zipConfigurer)
        
        hintLabel.text = viewModel.errorHintForBillingFields
        hintLabel.isHidden = (hintLabel.text ?? "").isEmpty
    }
    
    @objc func reuseButtonTapped() {
        reuseButton.isSelected = !reuseButton.isSelected
        viewModel?.toggleReuseSelection()
    }
    
    var allFields: [UIResponder] {
        [streetTextField, stateTextField, cityTextField, zipCodeTextField]
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

private extension BillingInfoCell {
    func setupViews() {
        contentView.addSubview(stack)
        stack.addArrangedSubview(titleLabel)
        stack.setCustomSpacing(8, after: titleLabel)
        stack.addArrangedSubview(reuseButton)
        stack.setCustomSpacing(12, after: reuseButton)
        
        stack.addArrangedSubview(countrySelectionView)
        stack.addArrangedSubview(streetTextField)
        
        let stateCitySpacer = stack.addSpacer(40, priority: .defaultLow)
        do {
            // horizontal stack for state and city
            stack.addSubview(stateTextField)
            stack.addSubview(cityTextField)
        }
        
        stack.addArrangedSubview(zipCodeTextField)
        stack.setCustomSpacing(4, after: zipCodeTextField)
        stack.addArrangedSubview(hintLabel)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
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
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupObservation() {
        let fields = [
            streetTextField,
            stateTextField,
            cityTextField,
            zipCodeTextField
        ]
        
        Publishers.MergeMany(fields.map { $0.textField.textDidBeginEditingPublisher } + fields.map { $0.textField.textDidEndEditingPublisher})
            .debounce(for: .milliseconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.validateInputAndUpdateLayering(fields)
            }
            .store(in: &cancellables)
    }
    
    func validateInputAndUpdateLayering(_ fields: [BaseTextField<InfoCollectorTextFieldViewModel>]) {
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
