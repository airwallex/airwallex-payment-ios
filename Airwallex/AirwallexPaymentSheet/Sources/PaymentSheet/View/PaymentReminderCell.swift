//
//  PaymentReminderCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/10.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class PaymentReminderCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    enum Style {
        case applePay
        case schema
    }

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow + 10, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh + 10, for: .horizontal)
        return view
    }()
    
    private let label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxFont(.body2)
        view.textColor = .awxColor(.textSecondary)
        view.numberOfLines = 0
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
        contentView.addSubview(stack)
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(label)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    var viewModel: Style?

    func setup(_ viewModel: Style) {
        self.viewModel = viewModel
        switch viewModel {
        case .applePay:
            imageView.image = UIImage(named: "redirectApplepay", in: .paymentSheet, compatibleWith: nil)
            label.text = NSLocalizedString("Click the Apple Pay button below to securely complete your purchase.", bundle: .paymentSheet, comment: "apple pay reminder")
        case .schema:
            imageView.image = UIImage(named: "redirect", in: .paymentSheet, compatibleWith: nil)
            label.text = NSLocalizedString("You will be redirected to complete your payment upon confirmation.", bundle: .paymentSheet, comment: "schema payment redirect reminder")
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
