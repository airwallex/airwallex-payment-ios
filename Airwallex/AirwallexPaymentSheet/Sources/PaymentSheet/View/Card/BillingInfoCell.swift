//
//  BillingInfoCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Combine
import UIKit
#if canImport(AirwallexPayment)
import AirwallexPayment
#endif

private protocol CornerMaskable: AnyObject {
    var box: UIView { get }
}

// OptionSelectionView inherits from BaseTextField, so this conformance covers both.
extension BaseTextField: CornerMaskable {}

class BillingInfoCell: UICollectionViewCell, ViewReusable, ViewConfigurable {

    private let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font  = .awxFont(.body2)
        view.textColor = .awxColor(.textPrimary)
        return view
    }()

    private lazy var reuseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
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

    private lazy var countrySelectionView: OptionSelectionView<CountrySelectionViewModel> = {
        let view = OptionSelectionView<CountrySelectionViewModel>()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let streetTextField: BaseTextField<InfoCollectorTextFieldViewModel> = {
        let view = BaseTextField<InfoCollectorTextFieldViewModel>()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stateTextField: BaseTextField<InfoCollectorTextFieldViewModel> = {
        let view = BaseTextField<InfoCollectorTextFieldViewModel>()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stateDropdownView: OptionSelectionView<SubdivisionSelectionViewModel> = {
        let view = OptionSelectionView<SubdivisionSelectionViewModel>()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let cityTextField: BaseTextField<InfoCollectorTextFieldViewModel> = {
        let view = BaseTextField<InfoCollectorTextFieldViewModel>()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let zipCodeTextField: BaseTextField<InfoCollectorTextFieldViewModel> = {
        let view = BaseTextField<InfoCollectorTextFieldViewModel>()
        view.translatesAutoresizingMaskIntoConstraints = false
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

    private let addressFieldsStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = -1
        view.alignment = .fill
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
        titleLabel.text = NSLocalizedString("Billing Address", bundle: .paymentSheet.language(viewModel.language), comment: "Billing Address - title")
        reuseButton.setTitle(
            NSLocalizedString("Same as shipping address", bundle: .paymentSheet.language(viewModel.language), comment: "Billing Address - reuse toggle"),
            for: .normal
        )
        viewModel.updateFieldsLayeringForErrorStatus = { [weak self] in
            self?.setNeedsLayout()
        }
        reuseButton.isHidden = !viewModel.canReusePrefilledAddress
        reuseButton.isSelected = viewModel.shouldReusePrefilledAddress

        countrySelectionView.setup(viewModel.countryConfigurer)
        rebuildAddressFields()

        hintLabel.text = viewModel.errorHintForBillingFields
        hintLabel.isHidden = (hintLabel.text ?? "").isEmpty
    }

    @objc func reuseButtonTapped() {
        reuseButton.isSelected = !reuseButton.isSelected
        viewModel?.toggleReuseSelection()
    }

    var allFields: [UIResponder] {
        guard let viewModel else { return [] }
        return viewModel.currentFields.compactMap { spec -> UIResponder? in
            switch spec.kind {
            case .street: return streetTextField
            case .state:  return spec.subdivision != nil ? stateDropdownView : stateTextField
            case .city:   return cityTextField
            case .postcode: return zipCodeTextField
            }
        }
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

    override func layoutSubviews() {
        super.layoutSubviews()
        validateInputAndUpdateLayering()
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
        stack.addArrangedSubview(addressFieldsStack)
        stack.setCustomSpacing(4, after: addressFieldsStack)
        stack.addArrangedSubview(hintLabel)

        let constraints = [
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            countrySelectionView.widthAnchor.constraint(equalTo: stack.widthAnchor),
            addressFieldsStack.widthAnchor.constraint(equalTo: stack.widthAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    var allTextFields: [BaseTextField<InfoCollectorTextFieldViewModel>] {
        [streetTextField, stateTextField, cityTextField, zipCodeTextField]
    }

    func setupObservation() {
        let beginPublishers = allTextFields.map { $0.textField.textDidBeginEditingPublisher }
        let endPublishers = allTextFields.map { $0.textField.textDidEndEditingPublisher }
        Publishers.MergeMany(beginPublishers + endPublishers)
            .debounce(for: .milliseconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.setNeedsLayout()
            }
            .store(in: &cancellables)
    }

    func rebuildAddressFields() {
        guard let viewModel else { return }

        // Tear down everything inside the address-fields stack.
        // Removing the subviews automatically deactivates constraints that referenced them.
        addressFieldsStack.subviews.forEach { $0.removeFromSuperview() }

        var newConstraints: [NSLayoutConstraint] = []
        let fields = viewModel.currentFields
        var index = 0
        while index < fields.count {
            let spec = fields[index]
            let next = index + 1 < fields.count ? fields[index + 1] : nil
            if spec.width == .half, next?.width == .half, let next {
                let leftView = view(for: spec)
                let rightView = view(for: next)
                let spacer = addressFieldsStack.addSpacer(40, priority: .defaultLow)
                addressFieldsStack.addSubview(leftView)
                addressFieldsStack.addSubview(rightView)
                newConstraints += [
                    spacer.heightAnchor.constraint(equalTo: leftView.heightAnchor),
                    leftView.topAnchor.constraint(equalTo: spacer.topAnchor),
                    leftView.leadingAnchor.constraint(equalTo: addressFieldsStack.leadingAnchor),
                    leftView.trailingAnchor.constraint(equalTo: addressFieldsStack.centerXAnchor, constant: 1),
                    rightView.topAnchor.constraint(equalTo: spacer.topAnchor),
                    rightView.bottomAnchor.constraint(equalTo: leftView.bottomAnchor),
                    rightView.leadingAnchor.constraint(equalTo: addressFieldsStack.centerXAnchor),
                    rightView.trailingAnchor.constraint(equalTo: addressFieldsStack.trailingAnchor),
                ]
                index += 2
                rightView.setContentHuggingPriority(.defaultLow + 50, for: .vertical)
                rightView.setContentCompressionResistancePriority(.defaultHigh + 50, for: .vertical)
            } else {
                let single = view(for: spec)
                addressFieldsStack.addArrangedSubview(single)
                index += 1
            }
        }
        NSLayoutConstraint.activate(newConstraints)

        bindFieldViewModels()
        applyCornerMasking()
    }

    /// Returns the persistent field view for the given spec.
    func view(for spec: AddressFieldSpec) -> UIView {
        switch spec.kind {
        case .street: return streetTextField
        case .state:  return spec.subdivision != nil ? stateDropdownView : stateTextField
        case .city:   return cityTextField
        case .postcode: return zipCodeTextField
        }
    }

    /// Wire each visible configurer to its view and set up return-key chaining
    /// (each non-last text field's "next" jumps to the next visible text field).
    func bindFieldViewModels() {
        guard let viewModel else { return }

        // Set up each visible configurer with its view.
        for spec in viewModel.currentFields {
            switch spec.kind {
            case .street:
                streetTextField.setup(viewModel.streetConfigurer)
            case .state:
                if spec.subdivision != nil, let dropdown = viewModel.stateDropdownConfigurer {
                    stateDropdownView.setup(dropdown)
                } else {
                    stateTextField.setup(viewModel.stateConfigurer)
                }
            case .city:
                cityTextField.setup(viewModel.cityConfigurer)
            case .postcode:
                zipCodeTextField.setup(viewModel.zipConfigurer)
            }
        }

        // Chain return-key handlers across visible *text* fields (skip the dropdown).
        let chainableFields: [(BaseTextField<InfoCollectorTextFieldViewModel>, InfoCollectorTextFieldViewModel)] =
            viewModel.currentFields.compactMap { spec in
                switch spec.kind {
                case .street:    return (streetTextField, viewModel.streetConfigurer)
                case .state:     return spec.subdivision != nil ? nil : (stateTextField, viewModel.stateConfigurer)
                case .city:      return (cityTextField, viewModel.cityConfigurer)
                case .postcode:  return (zipCodeTextField, viewModel.zipConfigurer)
                }
            }
        for (index, entry) in chainableFields.enumerated() {
            let (_, configurer) = entry
            if index + 1 < chainableFields.count {
                let nextField = chainableFields[index + 1].0
                configurer.returnActionHandler = { [weak nextField] _ in
                    nextField?.becomeFirstResponder() ?? false
                }
            } else {
                configurer.returnActionHandler = nil
            }
        }
    }

    func applyCornerMasking() {
        countrySelectionView.box.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let allBoxes: [CornerMaskable] = [
            streetTextField, stateTextField, stateDropdownView, cityTextField, zipCodeTextField,
        ]
        for field in allBoxes {
            field.box.layer.maskedCorners = []
        }

        guard let viewModel, let last = viewModel.currentFields.last else { return }
        let secondLast = viewModel.currentFields.dropLast().last
        if last.width == .half, secondLast?.width == .half, let secondLast {
            if let left = view(for: secondLast) as? CornerMaskable {
                left.box.layer.maskedCorners = [.layerMinXMaxYCorner]
            }
            if let right = view(for: last) as? CornerMaskable {
                right.box.layer.maskedCorners = [.layerMaxXMaxYCorner]
            }
        } else if let single = view(for: last) as? CornerMaskable {
            single.box.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }

    var visibleAddressFieldViews: [UIView] {
        guard let viewModel else { return [] }
        return viewModel.currentFields.map { view(for: $0) }
    }

    func shouldBringForward(_ view: UIView) -> Bool {
        if let field = view as? BaseTextField<InfoCollectorTextFieldViewModel> {
            return field.viewModel?.isValid == false || field.isFirstResponder
        }
        if let dropdown = view as? OptionSelectionView<SubdivisionSelectionViewModel> {
            // Dropdowns are tap-driven — no first-responder state; only the invalid case matters.
            return dropdown.viewModel?.isValid == false
        }
        return false
    }

    func validateInputAndUpdateLayering() {
        var addressNeedsFront = false
        for fieldView in visibleAddressFieldViews where shouldBringForward(fieldView) {
            if !addressNeedsFront {
                addressNeedsFront = true
                stack.bringSubviewToFront(addressFieldsStack)
            }
            addressFieldsStack.bringSubviewToFront(fieldView)
        }
        if countrySelectionView.viewModel?.isValid == false {
            stack.bringSubviewToFront(countrySelectionView)
        }
        if let editing = visibleAddressFieldViews.first(where: { $0.isFirstResponder }) {
            stack.bringSubviewToFront(addressFieldsStack)
            addressFieldsStack.bringSubviewToFront(editing)
        }
    }
}
