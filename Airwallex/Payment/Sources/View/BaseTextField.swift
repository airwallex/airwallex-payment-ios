//
//  BaseTextField.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Combine

protocol BaseTextFieldConfiguring: AnyObject {
    /// If user editing is enabled, the text color will change based on this setting.
    var isEnabled: Bool { get }
    /// The text displayed in the embedded text field.
    var text: String? { get }
    /// If this value is not nil, it will be displayed instead of  `text`.
    var attributedText: NSAttributedString? { get }
    /// if the input text is valid
    var isValid: Bool { get }
    /// error message for invalid input (will not displayed in `BaseTextField` but may be displayed in subclass)
    var errorHint: String? { get }
    /// type of the text field
    var textFieldType: AWXTextFieldType? { get }
    /// placeholder for text field
    var placeholder: String? { get }
    /// return key type of the text field
    var returnKeyType: UIReturnKeyType { get set }
    /// This will be called in `textFieldShouldReturn` and is intended to customize the return key action.
    var returnActionHandler: ((UITextField) -> Void)? { get set }
    /// Called in `textField(_:shouldChangeCharactersIn:replacementString:)`
    /// - Parameters:
    ///   - textField: The text field being edited.
    ///   - range: The range of characters to be replaced, converted from `NSRange` to `Range<String.Index>`.
    ///   - string: The replacement string entered by the user.
    /// - Returns: A Boolean value indicating whether the user input should be updated naturally.
    ///   If `false`, `BaseTextField` will be setup with the updated view model again.
    func handleTextShouldChange(textField: UITextField, range: Range<String.Index>, replacementString string: String) -> Bool
    /// will be called in `textFieldDidEndEditing`
    func handleDidEndEditing()
}

class BaseTextField<T: BaseTextFieldConfiguring>: UIView, ViewConfigurable, UITextFieldDelegate {
    
    let textField: ContentInsetableTextField = {
        let view = ContentInsetableTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxTextPrimary
        view.font = .awxFont(.body2)
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
                    .font: UIFont.awxFont(.body2)
                ]
            )
        } else {
            textField.attributedPlaceholder = nil
        }
        isEnabled = viewModel.isEnabled
        textField.returnKeyType = viewModel.returnKeyType
        
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

    //  MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let returnHandler = viewModel?.returnActionHandler  {
            returnHandler(textField)
            return false
        } else {
            resignFirstResponder()
            return true
        }
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
        guard let viewModel,
              let range = Range(range, in: textField.text ?? "") else {
            return false
        }
        let shouldChange = viewModel.handleTextShouldChange(
            textField: textField,
            range: range,
            replacementString: string
        )
        if shouldChange {
            // text input not modified in viewModel
            return true
        }
        // text or attributedText is changed
        setup(viewModel)
        return false
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
