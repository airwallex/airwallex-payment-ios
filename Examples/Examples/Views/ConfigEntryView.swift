//
//  ConfigEntryView.swift
//  Examples
//
//  Created by Weiping Li on 2025/4/16.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

struct ConfigEntryViewModel {
    let text: String
    let action: () -> Void
}

class ConfigEntryView: UIView {
    
    private(set) lazy var optionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxColor(.textPrimary)
        view.font = .awxFont(.body2)
        return view
    }()
    
    private(set) lazy var indicator: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(systemName: "chevron.right")!
            .withTintColor(.awxColor(.iconSecondary), renderingMode: .alwaysOriginal)
        return view
    }()
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stack)
        stack.addArrangedSubview(optionLabel)
        stack.addArrangedSubview(indicator)
        optionLabel.setContentHuggingPriority(.defaultLow - 20, for: .horizontal)
        optionLabel.setContentCompressionResistancePriority(.defaultHigh - 20, for: .horizontal)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onEntryTapped))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var viewModel: ConfigEntryViewModel?
    
    func setup(_ viewModel: ConfigEntryViewModel) {
        self.viewModel = viewModel
        optionLabel.text = viewModel.text
    }
    
    @objc func onEntryTapped() {
        viewModel?.action()
    }
}
