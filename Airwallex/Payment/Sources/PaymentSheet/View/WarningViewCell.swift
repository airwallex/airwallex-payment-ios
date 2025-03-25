//
//  WarningViewCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/16.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

protocol WarningViewCellConfiguring {
    var warningMessage: String { get }
}

extension String: WarningViewCellConfiguring {
    var warningMessage: String { self }
}

class WarningViewCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    private let roundedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = .radius_l
        view.clipsToBounds = true
        view.backgroundColor = .awxColor(.backgroundWarning)
        return view
    }()
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        return stack
    }()
    
    private let icon: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(systemName: "exclamationmark.circle.fill")?
            .withTintColor(Palette.orange50, renderingMode: .alwaysOriginal)
        return view
    }()
       
    private let label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxFont(.body2)
        view.textColor = .awxColor(.textPrimary)
        view.numberOfLines = 0
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundView = roundedView
        contentView.addSubview(stack)
        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(label)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var viewModel: WarningViewCellConfiguring?
    
    func setup(_ viewModel: WarningViewCellConfiguring) {
        self.viewModel = viewModel
        label.text = viewModel.warningMessage
    }
    
}
