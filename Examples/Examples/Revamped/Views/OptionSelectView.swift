//
//  OptionSelectView.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

struct OptionSelectViewModel {
    let displayName: String
    let selectedOption: String
    let handleSelection: () -> Void
}

class OptionSelectView: UIView {
    
    private let topLabel: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        
        view.titleLabel?.font = .awxFont(.caption2, weight: .medium)
        view.setTitleColor(.secondaryLabel, for: .normal)
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
    
    private let indicator: UIImageView = {
        let image = UIImage(systemName: "chevron.down")?
            .withTintColor(.awxIconSecondary, renderingMode: .alwaysOriginal)
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
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
    
    private(set) var viewModel: OptionSelectViewModel?
    
    func setup(_ viewModel: OptionSelectViewModel) {
        self.viewModel = viewModel
        topLabel.setTitle(viewModel.displayName, for: .normal)
        mainLabel.text = viewModel.selectedOption
    }
    
    @objc func onUserTapped() {
        viewModel?.handleSelection()
    }
}

extension OptionSelectView {
    func setupViews() {
        backgroundColor = .awxBackgroundPrimary
        addSubview(boxView)
        addSubview(topLabel)
        addSubview(mainLabel)
        addSubview(indicator)
        
        let constraints = [
            topLabel.topAnchor.constraint(equalTo: topAnchor),
            topLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            boxView.topAnchor.constraint(equalTo: topLabel.centerYAnchor),
            boxView.leadingAnchor.constraint(equalTo: leadingAnchor),
            boxView.trailingAnchor.constraint(equalTo: trailingAnchor),
            boxView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            mainLabel.topAnchor.constraint(equalTo: boxView.topAnchor, constant: 16),
            mainLabel.leadingAnchor.constraint(equalTo: boxView.leadingAnchor, constant: 16),
            mainLabel.bottomAnchor.constraint(equalTo: boxView.bottomAnchor, constant: -16),
            
            indicator.centerYAnchor.constraint(equalTo: mainLabel.centerYAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 16),
            indicator.heightAnchor.constraint(equalToConstant: 16),
            indicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            indicator.leadingAnchor.constraint(equalTo: mainLabel.trailingAnchor, constant: 8),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
