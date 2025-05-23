//
//  ConfigTextField.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/20.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex

class ConfigTextField: UIView {
    
    let topLabel: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        view.titleLabel?.font = .awxFont(.caption2, weight: .medium)
        view.setTitleColor(.secondaryLabel, for: .normal)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .awxColor(.backgroundPrimary)
        view.isHidden = true
        return view
    }()
    
    private(set) lazy var textField: ContentInsetableTextField = {
        let view = ContentInsetableTextField(textInsets: .init(top: 16, left: 16, bottom: 16, right: 16))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.textColor = .label
        view.font = .awxFont(.body1)
        view.addTarget(self, action: #selector(textDidchange(_:)), for: .editingChanged)
        view.delegate = self
        view.returnKeyType = .done
        view.clearButtonMode = .whileEditing
        return view
    }()
    
    private(set) var hintLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxFont(.caption2)
        view.textColor = UIColor.tertiaryLabel
        return view
    }()
    
    private let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let boxView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = .awxCGColor(.borderDecorative)
        return view
    }()
    
    private let stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private(set) var viewModel: ConfigTextFieldViewModel?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ viewModel: ConfigTextFieldViewModel) {
        self.viewModel = viewModel
        topLabel.setTitle(viewModel.displayName, for: .normal)
        textField.placeholder = viewModel.displayName
        textField.text = viewModel.text
        hintLabel.text = viewModel.caption
        
        topLabel.isHidden = (textField.text ?? "").isEmpty
        hintLabel.isHidden = (viewModel.caption ?? "").isEmpty
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            boxView.layer.borderColor = .awxCGColor(.borderDecorative)
        }
    }
}

private extension ConfigTextField {
    func setupViews() {
        backgroundColor = .awxColor(.backgroundPrimary)
        addSubview(stack)
        stack.addArrangedSubview(container)
        do {
            container.addSubview(boxView)
            container.addSubview(topLabel)
            container.addSubview(textField)
        }
        stack.addArrangedSubview(hintLabel)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            topLabel.topAnchor.constraint(equalTo: container.topAnchor),
            topLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            boxView.topAnchor.constraint(equalTo: topLabel.centerYAnchor),
            boxView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            boxView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            boxView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            textField.topAnchor.constraint(equalTo: boxView.topAnchor),
            textField.leadingAnchor.constraint(equalTo: boxView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: boxView.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: boxView.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

extension ConfigTextField: UITextFieldDelegate {
    @objc func textDidchange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            topLabel.isHidden = false
        } else {
            topLabel.isHidden = true
        }
        viewModel?.text = textField.text
        viewModel?.textDidChange?(textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel?.textDidEndEditing?(textField.text)
    }
}

class ContentInsetableTextField: UITextField {
    
    var textInsets: UIEdgeInsets {
        didSet {
            setNeedsLayout()
        }
    }
    
    init(textInsets: UIEdgeInsets = .zero) {
        self.textInsets = textInsets
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Rect for text already in the field
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let textRect = super.textRect(forBounds: bounds)
        let rect = bounds.inset(by: textInsets)
        let result = textRect.intersection(rect)
        guard !(result.isEmpty || result.isEmpty || result.isInfinite) else {
            return rect
        }
        return result
    }
    
    // Rect for text when editing
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let editingRect = super.editingRect(forBounds: bounds)
        let rect = bounds.inset(by: textInsets)
        let result = editingRect.intersection(rect)
        guard !(result.isEmpty || result.isEmpty || result.isInfinite) else {
            return rect
        }
        return result
    }
    
    // Optionally adjust the placeholder's rectangle
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let placeholderRect = super.placeholderRect(forBounds: bounds)
        let rect = bounds.inset(by: textInsets)
        let result = placeholderRect.intersection(rect)
        guard !(result.isEmpty || result.isEmpty || result.isInfinite) else {
            return rect
        }
        return result
    }
}
