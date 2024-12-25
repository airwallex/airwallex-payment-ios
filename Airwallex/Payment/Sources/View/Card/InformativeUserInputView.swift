//
//  InformativeUserInputView.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
import Combine

protocol UserInputViewConfiguring {
    var inputType: String { get }
    var text: String { get }
    var isValid: Bool { get }
    var errorHint: String { get }
}

class InformativeUserInputView: UIView, ViewConfigurable {
    let topLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxTextSecondary
        view.font = .awxBody
        return view
    }()
    
    let boxView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.cornerRadius = .radius_l
        view.layer.borderColor = UIColor.awxBorderDecorative.cgColor
        view.backgroundColor = .awxBackgroundField
        return view
    }()
    
    let textField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxTextPrimary
        view.font = .awxBody
        view.enablesReturnKeyAutomatically = true
        return view
    }()
    
    let hintLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxTextError
        view.font = .awxHint
        view.isHidden = true
        return view
    }()
    
    let stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = .spacing_4
        return stack
    }()
    
    weak var nextInputView: UIResponder?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: (any UserInputViewConfiguring)?
    
    func setup(_ viewModel: UserInputViewConfiguring) {
        self.viewModel = viewModel
        topLabel.text = viewModel.inputType
        textField.text = viewModel.text
        hintLabel.text = viewModel.errorHint
        hintLabel.isHidden = viewModel.isValid
        boxView.layer.borderColor = viewModel.isValid ? UIColor.awxBorderDecorative.cgColor : UIColor.awxBorderError.cgColor
    }
    
    private func setupViews() {
        addSubview(stack)
        stack.addArrangedSubview(topLabel)
        stack.addArrangedSubview(boxView)
        stack.addArrangedSubview(hintLabel)
        
        boxView.addSubview(textField)
        textField.delegate = self
        
        let constraints = [
            
            textField.topAnchor.constraint(equalTo: boxView.topAnchor, constant: .spacing_8),
            textField.leadingAnchor.constraint(equalTo: boxView.leadingAnchor, constant: .spacing_16),
            textField.trailingAnchor.constraint(equalTo: boxView.trailingAnchor, constant: -.spacing_16),
            textField.bottomAnchor.constraint(equalTo: boxView.bottomAnchor, constant: -.spacing_8),
            
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
        self.boxView.layer.borderColor = (self.viewModel?.isValid ?? true) ? UIColor.awxBorderDecorative.cgColor : UIColor.awxBorderError.cgColor
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.boxView.layer.borderColor = UIColor.awxBorderPerceivable.cgColor
    }
}
