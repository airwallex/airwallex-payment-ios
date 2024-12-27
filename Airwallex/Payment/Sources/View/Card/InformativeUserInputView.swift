//
//  InformativeUserInputView.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
import Combine

protocol InformativeUserInputViewConfiguring: ErrorHintableTextFieldConfiguring {
    var title: String? { get }
}

class InformativeUserInputView: UIView, ViewConfigurable {
    private let topLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxTextSecondary
        view.font = .awxBody
        return view
    }()
    
    private let textField: BasicUserInputView = {
        let view = BasicUserInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = .spacing_4
        return stack
    }()
    
    weak var nextInputView: UIResponder? {
        get {
            textField.nextInputView
        }
        set {
            textField.nextInputView = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override var canBecomeFirstResponder: Bool {
        textField.canBecomeFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
    
    override var canResignFirstResponder: Bool {
        textField.canResignFirstResponder
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: (any InformativeUserInputViewConfiguring)?
    
    func setup(_ viewModel: InformativeUserInputViewConfiguring) {
        self.viewModel = viewModel
        topLabel.text = viewModel.title
        textField.setup(viewModel)
        hintLabel.text = viewModel.errorHint
    }
    
    private func setupViews() {
        addSubview(stack)
        stack.addArrangedSubview(topLabel)
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(hintLabel)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

extension InformativeUserInputView: UITextFieldDelegate {
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
        self.textField.updateBorderAppearance()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textField.updateBorderAppearance()
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
