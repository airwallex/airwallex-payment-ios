//
//  PaymentMethodCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/16.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Combine

struct PaymentMethodCellViewModel {
    let name: String
    let imageURL: URL?
    let isSelected: Bool
}

class PaymentMethodCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    private let roundedBG: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = .radius_l
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.awxColor(.borderInteractive).cgColor
        view.backgroundColor = .awxColor(.backgroundPrimary)
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
        view.font = UIFont.awxFont(.caption2)
        view.textColor = .awxColor(.textLink)
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
    
    private(set) var viewModel: PaymentMethodCellViewModel?
    func setup(_ viewModel: PaymentMethodCellViewModel) {
        self.viewModel = viewModel
        if let URL = viewModel.imageURL {
            logo.setImageURL(URL, placeholder: nil)
        } else {
            logo.image = nil
        }
        label.text = viewModel.name
        label.font = viewModel.isSelected ? .awxFont(.caption2, weight: .bold) : .awxFont(.caption2)
        label.textColor = viewModel.isSelected ? .awxColor(.textLink) : .awxColor(.textPrimary)
        roundedBG.layer.borderColor = viewModel.isSelected ? UIColor.awxColor(.borderInteractive).cgColor : UIColor.awxColor(.borderDecorative).cgColor
        roundedBG.backgroundColor = viewModel.isSelected ? UIColor.awxColor(.backgroundHighlight) : .awxColor(.backgroundPrimary)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            roundedBG.layer.borderColor = (viewModel?.isSelected ?? false) ? UIColor.awxColor(.borderInteractive).cgColor : UIColor.awxColor(.borderDecorative).cgColor
        }
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
