//
//  CVCInputView.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

class CVCInputView: UIView {
    
    let textField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxTextPrimary
        view.font = .awxBody
        view.enablesReturnKeyAutomatically = true
        view.placeholder = "CVC"
        view.update(for: .CVC)
        return view
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "cvc", in: Bundle.resource(), compatibleWith: nil)
        
        view.setContentHuggingPriority(.defaultHigh + 10, for: .horizontal)
        view.setContentCompressionResistancePriority(.required - 10, for: .horizontal)
        return view
    }()
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = .spacing_4
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stack)
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(imageView)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: topAnchor, constant: .spacing_8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacing_16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacing_16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.spacing_8),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

