//
//  CardConsentCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/18.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

struct CardConsentCellViewModel {
    let image: UIImage?
    let text: String
    let highlightable: Bool
    let actionTitle: String?
    let actionIcon: UIImage?
    let buttonAction: () -> Void
}

class CardConsentCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    private let roundedBG: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = .radius_l
        view.clipsToBounds = true
        view.backgroundColor = .awxColor(.backgroundPrimary)
        return view
    }()
    
    private let logo: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = .radius_m
        view.clipsToBounds = true
        return view
    }()
    
    private let label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxFont(.body2)
        view.textColor = .awxColor(.textPrimary)
        return view
    }()
    
    private lazy var button: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .awxColor(.iconLink)
        view.setTitleColor(.awxColor(.iconLink), for: .normal)
        view.titleLabel?.font = .awxFont(.headline2, weight: .bold)
        view.addTarget(self, action: #selector(onActionButtonTapped), for: .touchUpInside)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard let viewModel, viewModel.highlightable else {
                roundedBG.backgroundColor = .awxColor(.backgroundPrimary)
                return
            }
            if isHighlighted {
                roundedBG.backgroundColor = .awxColor(.backgroundHighlight)
            } else {
                roundedBG.backgroundColor = .awxColor(.backgroundPrimary)
            }
        }
    }
    
    private(set) var viewModel: CardConsentCellViewModel?
    
    func setup(_ viewModel: CardConsentCellViewModel) {
        self.viewModel = viewModel
        logo.image = viewModel.image
        label.text = viewModel.text
        button.setTitle(viewModel.actionTitle, for: .normal)
        button.setImage(viewModel.actionIcon, for: .normal)
    }
    
    // Action
    @objc func onActionButtonTapped() {
        viewModel?.buttonAction()
    }
}

private extension CardConsentCell {
    func setupViews() {
        backgroundView = roundedBG
        contentView.addSubview(logo)
        contentView.addSubview(label)
        contentView.addSubview(button)
        
        label.setContentCompressionResistancePriority(.defaultHigh - 10, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        
        let constraints = [
            logo.widthAnchor.constraint(equalToConstant: 30),
            logo.heightAnchor.constraint(equalToConstant: 20),
            logo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .spacing_16),
            logo.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: .spacing_16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: button.leadingAnchor),
            
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            button.widthAnchor.constraint(greaterThanOrEqualTo: button.heightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

