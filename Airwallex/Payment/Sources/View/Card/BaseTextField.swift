//
//  BaseTextField.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Combine

protocol BaseTextFieldConfiguring: AnyObject {
    var isEnabled: Bool { get }
    var text: String? { get }
    var attributedText: NSAttributedString? { get }
    var isValid: Bool { get }
    var errorHint: String? { get }
    var textFieldType: AWXTextFieldType? { get }
    var placeholder: String? { get }
    
    /// will be called in UITextField's `textField(_:shouldChangeCharactersIn:replacementString:) -> Bool` delegate to decide whether
    /// we should let user continue input in `nextField`
    /// - Parameter userInput: user input
    /// - Returns: true means we have a valid input and we should make `nextFiled`  the first responder
    func handleTextDidUpdate(to userInput: String) -> Bool
    func handleDidEndEditing()
}

class BaseTextField<T: BaseTextFieldConfiguring>: UIView, ViewConfigurable, UITextFieldDelegate {
    
    let textField: ContentInsetableTextField = {
        let view = ContentInsetableTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxTextPrimary
        view.font = .awxBody
        view.setContentHuggingPriority(.defaultLow - 50, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh - 50, for: .horizontal)
        view.textInsets = UIEdgeInsets(top: .spacing_12, left: .spacing_16, bottom: .spacing_12, right: .spacing_16)
        return view
    }()
    
    let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = .spacing_4
        stack.axis = .vertical
        return stack
    }()
    
    let box: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.cornerRadius = .radius_l
        view.layer.borderColor = UIColor.awxBorderDecorative.cgColor
        view.backgroundColor = .awxBackgroundField
        return view
    }()

    let horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        return stack
    }()
    
    weak var nextField: UIResponder? {
        didSet {
            if nextField != nil {
                textField.returnKeyType = .next
            } else {
                textField.returnKeyType = .default
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        addSubview(verticalStack)
        verticalStack.addArrangedSubview(box)
        box.addSubview(horizontalStack)
        horizontalStack.addArrangedSubview(textField)
        
        textField.delegate = self
        
        let constraints = [
            verticalStack.topAnchor.constraint(equalTo: topAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            horizontalStack.topAnchor.constraint(equalTo: box.topAnchor),
            horizontalStack.leadingAnchor.constraint(equalTo: box.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: box.trailingAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: box.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        updateBorderAppearance()
    }
    
    override var canBecomeFirstResponder: Bool {
        textField.canBecomeFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
    
    override var canResignFirstResponder: Bool {
        textField.canResignFirstResponder
    }
    
    override var isFirstResponder: Bool {
        textField.isFirstResponder
    }
    
    var isEnabled: Bool {
        get {
            textField.isEnabled
        }
        set {
            textField.isEnabled = newValue
            textField.textColor = newValue ? .awxTextPrimary : .awxTextPlaceholder
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var viewModel: T?
    
    func setup(_ viewModel: T) {
        self.viewModel = viewModel
        textField.update(for: viewModel.textFieldType ?? .default)
        if let attributedText = viewModel.attributedText {
            textField.attributedText = attributedText
        } else if let text = viewModel.text {
            textField.text = text
        } else {
            textField.text = nil
        }
        
        if let placeholder = viewModel.placeholder, !placeholder.isEmpty {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor: UIColor.awxTextPlaceholder,
                    .font: UIFont.awxBody
                ]
            )
        } else {
            textField.attributedPlaceholder = nil
        }
        isEnabled = viewModel.isEnabled
        
        updateBorderAppearance()
    }
    
    func updateBorderAppearance() {
        guard let viewModel else { return }
        if textField.isFirstResponder {
            box.layer.borderColor = UIColor.awxBorderInterative.cgColor
            box.layer.borderWidth = 2
        } else {
            box.layer.borderColor = viewModel.isValid ? UIColor.awxBorderDecorative.cgColor : UIColor.awxBorderError.cgColor
            box.layer.borderWidth = 1
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField  {
            nextField.becomeFirstResponder()
        } else {
            resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let viewModel else { return }
        viewModel.handleDidEndEditing()
        textField.updateWithoutDelegate { tf in
            setup(viewModel)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateBorderAppearance()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        if let range = Range(range, in: currentText) {
            let text = currentText.replacingCharacters(in: range, with: string)
            guard let viewModel else { return false }
            let moveToNextField = viewModel.handleTextDidUpdate(to: text)
            setup(viewModel)
            if textField.isFirstResponder && moveToNextField {
                nextField?.becomeFirstResponder()
            }
        }
        return false
    }
}

extension BaseTextField {
    
    var textDidBeginEditingPublisher: AnyPublisher<UITextField, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification, object: textField)
            .compactMap { [weak self] _ in self?.textField }
            .eraseToAnyPublisher()
    }
    
    var textDidEndEditingPublisher: AnyPublisher<UITextField, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification, object: textField)
            .compactMap { [weak self] _ in self?.textField }
            .eraseToAnyPublisher()
    }
    
    var textDidChangePublisher: AnyPublisher<UITextField, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: textField)
            .compactMap { [weak self] _ in self?.textField }
            .eraseToAnyPublisher()
    }
}


class ContentInsetableTextField: UITextField {
    
    var textInsets: UIEdgeInsets

    init(textInsets: UIEdgeInsets = .zero) {
        self.textInsets = textInsets
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Rect for text already in the field
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    // Rect for text when editing
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    // Optionally adjust the placeholder's rectangle
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
}
