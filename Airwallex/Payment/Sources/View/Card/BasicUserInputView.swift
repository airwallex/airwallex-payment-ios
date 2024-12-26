//
//  BasicUserInputView.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Combine

protocol BasicUserInputViewConfiguring: AnyObject {
    var text: String? { get }
    var attributedText: NSAttributedString? { get }
    var isValid: Bool { get }
    var textFieldType: AWXTextFieldType? { get }
    var placeholder: String? { get }
    
    func update(for userInput: String)
    func updateForEndEditing()
}

class BasicUserInputView: UIView, ViewConfigurable {
    
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
    
    let stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = .spacing_8
        stack.alignment = .center
        return stack
    }()
    
    weak var nextInputView: UIResponder? {
        didSet {
            if nextInputView != nil {
                textField.returnKeyType = .next
            } else {
                textField.returnKeyType = .default
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //  border
        layer.borderWidth = 1
        layer.cornerRadius = .radius_l
        layer.borderColor = UIColor.awxBorderDecorative.cgColor
        backgroundColor = .awxBackgroundField
        
        addSubview(stack)
        stack.addArrangedSubview(textField)
        
        textField.delegate = self
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacing_16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override var canBecomeFirstResponder: Bool {
        return textField.canBecomeFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: (any BasicUserInputViewConfiguring)?
    
    func setup(_ viewModel: BasicUserInputViewConfiguring) {
        self.viewModel = viewModel
        textField.update(for: viewModel.textFieldType ?? .default)
        if let attributedText = viewModel.attributedText {
            textField.attributedText = attributedText
        } else if let text = viewModel.text {
            textField.text = text
        } else {
            textField.text = nil
        }
        textField.placeholder = viewModel.placeholder
        
        updateBorderAppearance()
    }
    
    func updateBorderAppearance() {
        guard let viewModel else { return }
        if textField.isFirstResponder {
            layer.borderColor = UIColor.awxBorderInterative.cgColor
            layer.borderWidth = 2
        } else {
            layer.borderColor = viewModel.isValid ? UIColor.awxBorderDecorative.cgColor : UIColor.awxBorderError.cgColor
            layer.borderWidth = 1
        }
    }
}

extension BasicUserInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextInputView  {
            nextInputView.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel?.updateForEndEditing()
        updateBorderAppearance()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateBorderAppearance()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        if let range = Range(range, in: currentText) {
            let text = currentText.replacingCharacters(in: range, with: string)
            guard let viewModel else { return false }
            viewModel.update(for: text)
            setup(viewModel)
        }
        return false
    }
}

extension BasicUserInputView {
    
    var textDidBeginEditingPublisher: AnyPublisher<UITextField, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification, object: textField)
            .compactMap { $0.object as? UITextField }
            .eraseToAnyPublisher()
    }
    
    var textDidEndEditingPublisher: AnyPublisher<UITextField, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification, object: textField)
            .compactMap { $0.object as? UITextField }
            .eraseToAnyPublisher()
    }
    
    var textDidChangePublisher: AnyPublisher<UITextField, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: textField)
            .compactMap { $0.object as? UITextField }
            .eraseToAnyPublisher()
    }
}


class ContentInsetableTextField: UITextField {
    
    init(textInsets: UIEdgeInsets = .zero) {
        self.textInsets = textInsets
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var textInsets: UIEdgeInsets
    
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
