//
//  OptionSelectionView.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/8.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

protocol OptionSelectionViewConfiguring: InfoCollectorTextFieldConfiguring {
    /// The icon displayed at the leading edge of the user input field.
    var icon: UIImage? { get }
    /// The icon displayed at the trailing edge of the user input field.
    /// By default, a down arrow will be shown.
    var indicator: UIImage? { get }
    /// Callback triggered when the user interacts with the input field.
    var handleUserInteraction: () -> Void { get }
}

class OptionSelectionView<T: OptionSelectionViewConfiguring>: InfoCollectorTextField<T> {
    
    private let iconWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let icon: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 28).isActive = true
        view.heightAnchor.constraint(equalToConstant: 20).isActive = true
        view.layer.cornerRadius = .radius_s
        view.clipsToBounds = true
        
        return view
    }()
    
    private lazy var indicator: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "down", in: .paymentSheet)?
            .withTintColor(.awxColor(.iconSecondary), renderingMode: .alwaysOriginal)
        return view
    }()
    
    private lazy var cover: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onUserTapped))
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup(_ viewModel: T) {
        super.setup(viewModel)
        iconWrapper.isHidden = viewModel.icon == nil
        icon.image = viewModel.icon
        indicator.image = viewModel.indicator
    }
    
    @objc func onUserTapped() {
        guard let viewModel else {
            assert(false, "invalid view model")
            return
        }
        if viewModel.isEnabled == true {
            viewModel.handleUserInteraction()
        }
    }
}

private extension OptionSelectionView {
    
    func setupViews() {
        iconWrapper.addSubview(icon)
        horizontalStack.insertSpacer(12, at: 0)
        horizontalStack.insertArrangedSubview(iconWrapper, at: 1)
        var insets = textField.textInsets
        insets.left = 0
        insets.right = 0
        textField.textInsets = insets
        horizontalStack.addArrangedSubview(indicator)
        horizontalStack.addSpacer(12)

        addSubview(cover)
        let constraints = [
            cover.topAnchor.constraint(equalTo: topAnchor),
            cover.leadingAnchor.constraint(equalTo: leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: trailingAnchor),
            cover.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            icon.topAnchor.constraint(equalTo: iconWrapper.topAnchor),
            icon.leadingAnchor.constraint(equalTo: iconWrapper.leadingAnchor),
            icon.trailingAnchor.constraint(equalTo: iconWrapper.trailingAnchor, constant: -8),
            icon.bottomAnchor.constraint(equalTo: iconWrapper.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
