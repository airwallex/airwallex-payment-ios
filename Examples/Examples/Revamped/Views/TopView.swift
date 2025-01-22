//
//  TopView.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex

struct TopViewModel {
    let title: String?
    let actionTitle: String?
    let actionIcon: UIImage?
    let actionHandler: (() -> Void)?
    
    init(title: String?,
         actionTitle: String? = nil,
         actionIcon: UIImage? = nil,
         actionHandler: (() -> Void)? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.actionIcon = actionIcon
        self.actionHandler = actionHandler
    }
}

class TopView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxFont(.headline1, weight: .bold)
        view.textColor = .awxTextPrimary
        view.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh - 10, for: .horizontal)
        return view
    }()
    
    private lazy var actionButton: UIButton = {
        let view = UIButton(style: .mini)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onActionButtonTapped), for: .touchUpInside)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(actionButton)
        
        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            actionButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            actionButton.topAnchor.constraint(equalTo: topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: TopViewModel?
    func setup(_ viewModel: TopViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        actionButton.setImage(viewModel.actionIcon, for: .normal)
        actionButton.setTitle(viewModel.actionTitle, for: .normal)
        actionButton.isHidden = viewModel.actionIcon != nil && viewModel.actionTitle == nil
    }
}

private extension TopView {
    @objc func onActionButtonTapped() {
        viewModel?.actionHandler?()
    }
}
