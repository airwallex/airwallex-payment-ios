//
//  BasicUserInputView.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//  Copyright © 2024 Airwallex. All rights reserved.
//

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
    
    let textField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxTextPrimary
        view.font = .awxBody
        view.enablesReturnKeyAutomatically = true
        view.setContentHuggingPriority(.defaultLow - 50, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh - 50, for: .horizontal)
        return view
    }()
    
    let stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = .spacing_8
        stack.alignment = .center
        return stack
    }()
    
    weak var nextInputView: UIResponder?
    
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
            stack.topAnchor.constraint(equalTo: topAnchor, constant: .spacing_12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacing_16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacing_16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.spacing_12),
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
        
        updateBorderColor()
    }
    
    func updateBorderColor() {
        guard let viewModel else { return }
        if textField.isFirstResponder {
            layer.borderColor = UIColor.awxBorderPerceivable.cgColor
        } else {
            layer.borderColor = viewModel.isValid ? UIColor.awxBorderDecorative.cgColor : UIColor.awxBorderError.cgColor
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
        updateBorderColor()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateBorderColor()
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
