//
//  ConfigActionView.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex

struct ConfigActionViewModel {
    let configName: String
    let configValue: String?
    let caption: String?
    
    let secondaryActionIcon: UIImage?
    let secondaryActionTitle: String?
    
    let primaryAction: ((UIView) -> Void)?
    let secondaryAction: ((UIView) -> Void)?
    
    init(configName: String,
         configValue: String?,
         caption: String? = nil,
         secondaryActionIcon: UIImage? = UIImage(systemName: "chevron.down")!.withTintColor(.awxIconSecondary, renderingMode: .alwaysOriginal),
         secondaryActionTitle: String? = nil,
         primaryAction: ((UIView) -> Void)? = nil,
         secondaryAction: ((UIView) -> Void)? = nil) {
        self.configName = configName
        self.configValue = configValue
        self.caption = caption
        self.secondaryActionIcon = secondaryActionIcon
        self.secondaryActionTitle = secondaryActionTitle
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
}

class ConfigActionView: UIView {
    
    private let topLabel: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        
        view.titleLabel?.font = .awxFont(.caption2, weight: .medium)
        view.setTitleColor(.awxTextSecondary, for: .normal)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .awxBackgroundPrimary
        return view
    }()
    
    private let boxView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.cgColor
        return view
    }()
    
    private let mainLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxFont(.body1)
        view.textColor = .awxTextPrimary
        view.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh - 10, for: .horizontal)
        return view
    }()
    
    private lazy var actionButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsImageWhenHighlighted = false
        view.setTitleColor(.awxIconLink, for: .normal)
        view.titleLabel?.font = .awxFont(.body1, weight: .medium)
        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        view.addTarget(self, action: #selector(onActionButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 8
        return view
    }()
    
    private(set) var captionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxFont(.caption2)
        view.textColor = .awxTextPlaceholder
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        UITapGestureRecognizer(target: self, action: #selector(onUserTapped))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var viewModel: ConfigActionViewModel?
    
    func setup(_ viewModel: ConfigActionViewModel) {
        self.viewModel = viewModel
        topLabel.setTitle(viewModel.configName, for: .normal)
        if let value = viewModel.configValue {
            mainLabel.text = value
            mainLabel.textColor = .awxTextPrimary
        } else {
            mainLabel.text = viewModel.configName
            mainLabel.textColor = .awxTextPlaceholder
        }
        captionLabel.text = viewModel.caption
        captionLabel.isHidden = (viewModel.caption ?? "").isEmpty
        actionButton.setImage(viewModel.secondaryActionIcon, for: .normal)
        actionButton.setTitle(viewModel.secondaryActionTitle, for: .normal)
        
        let actionEnabled = viewModel.primaryAction != nil
        tapGesture.isEnabled = actionEnabled
        mainLabel.textColor =  actionEnabled ? .awxTextPrimary : .awxTextPlaceholder
        actionButton.isEnabled = viewModel.secondaryAction != nil
    }
    
    @objc func onUserTapped() {
        viewModel?.primaryAction?(self)
    }
    
    @objc func onActionButtonTapped() {
        viewModel?.secondaryAction?(self)
    }
}

extension ConfigActionView {
    func setupViews() {
        backgroundColor = .awxBackgroundPrimary
        addSubview(stack)
        do {
            container.addSubview(boxView)
            container.addSubview(topLabel)
            container.addSubview(mainLabel)
            container.addSubview(actionButton)
            stack.addArrangedSubview(container)
        }
        stack.addArrangedSubview(captionLabel)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            topLabel.topAnchor.constraint(equalTo: container.topAnchor),
            topLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            boxView.topAnchor.constraint(equalTo: topLabel.centerYAnchor),
            boxView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            boxView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            boxView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            mainLabel.topAnchor.constraint(equalTo: boxView.topAnchor, constant: 16),
            mainLabel.leadingAnchor.constraint(equalTo: boxView.leadingAnchor, constant: 16),
            mainLabel.bottomAnchor.constraint(equalTo: boxView.bottomAnchor, constant: -16),
            
            actionButton.centerYAnchor.constraint(equalTo: mainLabel.centerYAnchor),
            actionButton.heightAnchor.constraint(equalTo: boxView.heightAnchor),
            actionButton.trailingAnchor.constraint(equalTo: boxView.trailingAnchor),
            actionButton.leadingAnchor.constraint(equalTo: mainLabel.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
