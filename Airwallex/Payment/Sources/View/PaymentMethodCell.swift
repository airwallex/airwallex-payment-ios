//
//  PaymentMethodCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/16.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Combine

protocol PaymentMethodCellConfiguring {
    var name: String { get }
    var imageURL: URL { get }
    var isSelected: Bool { get }
}

class PaymentMethodCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    private let roundedBG: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = .radius_l
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.awxBorderInterative.cgColor
        view.backgroundColor = .awxBackgroundPrimary
        return view
    }()
    
    private let logo: UIImageView =  {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        return view
    }()
    
    private let label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.awxHint
        view.textColor = UIColor.awxTextLink
        return view
    }()
    
    private let stack: UIStackView = {
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
        roundedBG.layer.borderColor = viewModel.isSelected ? UIColor.awxBorderInterative.cgColor : UIColor.awxBorderDecorative.cgColor
        roundedBG.backgroundColor = viewModel.isSelected ? UIColor.awxBackgroundHighlight : UIColor.awxBackgroundPrimary
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
        backgroundView = roundedBG
        
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
