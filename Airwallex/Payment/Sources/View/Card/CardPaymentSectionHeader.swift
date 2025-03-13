//
//  CardPaymentSectionHeader.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/17.
//  Copyright © 2024 Airwallex. All rights reserved.
//


struct CardPaymentSectionHeaderViewModel {
    let title: String
    let actionTitle: String
    let buttonAction: () -> Void
}

class CardPaymentSectionHeader: UICollectionReusableView, ViewReusable, ViewConfigurable {
    
    private let label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxFont(.body2, weight: .bold)
        view.textColor = .awxColor(.textPrimary)
        return view
    }()
    
    private lazy var actionButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .awxFont(.headline2, weight: .bold)
        view.setTitleColor(.awxColor(.textLink), for: .normal)
        view.addTarget(self, action: #selector(onRightButtonTapped), for: .touchUpInside)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        addSubview(actionButton)
        
        let constraints = [
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            actionButton.topAnchor.constraint(equalTo: topAnchor),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            actionButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var viewModel: CardPaymentSectionHeaderViewModel?
    
    func setup(_ viewModel: CardPaymentSectionHeaderViewModel) {
        self.viewModel = viewModel
        label.text = viewModel.title
        actionButton.setTitle(viewModel.actionTitle, for: .normal)
    }
    
    // Actions
    @objc func onRightButtonTapped() {
        viewModel?.buttonAction()
    }
}
