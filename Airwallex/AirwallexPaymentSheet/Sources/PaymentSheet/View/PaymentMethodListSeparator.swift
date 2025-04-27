//
//  PaymentMethodListSeparator.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/17.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

class PaymentMethodListSeparator: UICollectionReusableView, ViewReusable {
    
    private let lineL: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .awxColor(.borderDecorative)
        view.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        return view
    }()
    
    private let lineR: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .awxColor(.borderDecorative)
        view.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        return view
    }()
    
    private let label: UIView = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxColor(.textSecondary)
        view.font = .awxFont(.body2)
        view.text = NSLocalizedString("Or pay with", bundle: .paymentSheet, comment: "payment section separator")
        return view
    }()
    
    private let stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 8
        view.alignment = .center
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension PaymentMethodListSeparator {
    
    func setupViews() {
        addSubview(stack)
        stack.addArrangedSubview(lineL)
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(lineR)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            lineL.heightAnchor.constraint(equalToConstant: 1),
            lineR.heightAnchor.constraint(equalToConstant: 1),
            lineL.widthAnchor.constraint(equalTo: lineR.widthAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
