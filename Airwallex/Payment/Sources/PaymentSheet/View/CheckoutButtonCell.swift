//
//  CheckoutButtonCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

struct CheckoutButtonCellViewModel {
    let checkoutAction: () -> Void
}

class CheckoutButtonCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    private lazy var button: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle(NSLocalizedString("Pay", comment: "checkout button"), for: .normal)
        view.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
        
        view.setTitleColor(.awxColor(.textInverse), for: .normal)
        view.titleLabel?.font = .awxFont(.headline1, weight: .bold)
        view.backgroundColor = UIColor.awxColor(.backgroundInteractive)
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(button)
        
        let constraints = [
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 52).priority(.required - 1),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var viewModel: CheckoutButtonCellViewModel?
    
    func setup(_ viewModel: CheckoutButtonCellViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func onButtonTapped() {
        viewModel?.checkoutAction()
    }
}
