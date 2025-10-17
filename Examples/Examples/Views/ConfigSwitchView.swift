//
//  ConfigSwitchView.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/24.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class ConfigSwitchViewModel {
    let title: String
    var isOn: Bool
    let action: (Bool) -> Void
    
    init(title: String, isOn: Bool, action: @escaping (Bool) -> Void) {
        self.title = title
        self.isOn = isOn
        self.action = action
    }
}

class ConfigSwitchView: UIView {

    private(set) lazy var optionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxColor(.textPrimary)
        view.font = .awxFont(.body2)
        return view
    }()
    
    private(set) lazy var optionSwitch: UISwitch = {
        let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .awxColor(.iconLink)
        view.addTarget(self, action: #selector(onSwitchToggled(_:)), for: .valueChanged)
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
        stack.addArrangedSubview(optionSwitch)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        optionLabel.setContentCompressionResistancePriority(.defaultHigh - 50, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var viewModel: ConfigSwitchViewModel?
    
    func setup(_ viewModel: ConfigSwitchViewModel) {
        self.viewModel = viewModel
        optionLabel.text = viewModel.title
        optionSwitch.isOn = viewModel.isOn
    }
    
    @objc func onSwitchToggled(_ sender: UISwitch) {
        viewModel?.isOn = sender.isOn
        viewModel?.action(sender.isOn)
    }
}
