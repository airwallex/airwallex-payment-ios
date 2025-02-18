//
//  PaymentMethodCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/16.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Combine
import UIKit

protocol PaymentMethodCellConfiguring {
    var name: String { get }
    var imageURL: URL { get }
    var isSelected: Bool { get }
}

class PaymentMethodCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    let logo: UIImageView =  {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        return view
    }()
    
    let label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.awxHint
        view.textColor = UIColor.awxTextLink
        return view
    }()
    
    let stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .center
        return view
    }()
    
    private(set) var viewModel: PaymentMethodCellConfiguring?
    func setup(_ viewModel: PaymentMethodCellConfiguring) {
        self.viewModel = viewModel
        logo.setImageURL(viewModel.imageURL, placeholder: nil)
        label.text = viewModel.name
        self.label.font = viewModel.isSelected ? .awxHintBold : .awxHint
        self.label.textColor = viewModel.isSelected ? .awxTextLink : .awxTextPrimary
        self.contentView.layer.borderColor = viewModel.isSelected ? UIColor.awxBorderInterative.cgColor : UIColor.awxBorderDecorative.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PaymentMethodCell {
    func setupViews() {
        contentView.layer.cornerRadius = .radius_l
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.awxBorderInterative.cgColor
        
        contentView.addSubview(stack)
        stack.addArrangedSubview(logo)
        stack.addArrangedSubview(label)
        
        let constraints = [
            logo.widthAnchor.constraint(equalToConstant: 30),
            logo.heightAnchor.constraint(equalToConstant: 20),
            
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: .spacing_4),
            stack.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: -.spacing_16),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
