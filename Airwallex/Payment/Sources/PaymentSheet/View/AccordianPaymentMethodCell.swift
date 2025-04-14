//
//  AccordionPaymentMethodCell.swift
//  Payment
//
//  Created by Weiping Li on 2025/4/3.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class AccordionPaymentMethodCell: UICollectionViewCell, ViewConfigurable, ViewReusable {
    
    let icon: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(systemName: "circle")?
            .withTintColor(.awxColor(.borderDecorative), renderingMode: .alwaysOriginal)
        return view
    }()
    
    let logo: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let label: UILabel = {
        let view = UILabel()
        view.textColor = .awxColor(.textPrimary)
        view.font = .awxFont(.body2, weight: .bold)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .center
        view.spacing = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: PaymentMethodCellViewModel?
    
    func setup(_ viewModel: PaymentMethodCellViewModel) {
        self.viewModel = viewModel
        
        label.text = viewModel.name
        if let imageURL = viewModel.imageURL {
            logo.loadImage(
                imageURL,
                imageLoader: viewModel.imageLoader,
                placeholder: nil
            )
        } else {
            logo.image = nil
        }
        if viewModel.isSelected {
            icon.image = UIImage(systemName: "largecircle.fill.circle")?
                .withTintColor(.awxColor(.borderInteractive), renderingMode: .alwaysOriginal)
            label.textColor = .awxColor(.textLink)
        } else {
            icon.image = UIImage(systemName: "circle")?
                .withTintColor(.awxColor(.borderDecorative), renderingMode: .alwaysOriginal)
            label.textColor = .awxColor(.textPrimary)
        }
    }
    
    func setupViews() {
        contentView.addSubview(stack)
        stack.batchAddArrangedSubView([icon, logo, label])
        stack.setCustomSpacing(16, after: icon)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).priority(.required - 1),
            
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16),
            
            logo.widthAnchor.constraint(equalToConstant: 35),
            logo.heightAnchor.constraint(equalToConstant: 24),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

class AccordionSelectedMethodCell: AccordionPaymentMethodCell {
    override func setupViews() {
        contentView.addSubview(stack)
        stack.batchAddArrangedSubView([icon, logo, label])
        stack.setCustomSpacing(16, after: icon)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).priority(.required - 1),
            
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16),
            
            logo.widthAnchor.constraint(equalToConstant: 35),
            logo.heightAnchor.constraint(equalToConstant: 24),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

class AccordionCardMethodCell: AccordionPaymentMethodCell {
    
    let cardBrandView: CardBrandView = {
        let view = CardBrandView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func setupViews() {
        contentView.addSubview(stack)
        stack.batchAddArrangedSubView([icon, logo, label, cardBrandView])
        stack.setCustomSpacing(16, after: icon)
        label.setContentHuggingPriority(.defaultLow - 50, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh - 50, for: .horizontal)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).priority(.required - 1),
            
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16),
            
            logo.widthAnchor.constraint(equalToConstant: 35),
            logo.heightAnchor.constraint(equalToConstant: 24),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func setup(_ viewModel: PaymentMethodCellViewModel) {
        super.setup(viewModel)
        cardBrandView.setup(viewModel)
    }
}
