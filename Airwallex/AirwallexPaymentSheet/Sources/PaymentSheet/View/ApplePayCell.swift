//
//  ApplePayCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/11.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import PassKit
import UIKit

struct ApplePayViewModel {
    var onPaymentButtonTapped: () -> Void
}

class ApplePayCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPaymentButton()
    }
    
    private func setupPaymentButton() {
        contentView.subviews.forEach { view in
            view.removeFromSuperview()
        }

        let view = if #available(iOS 26, *) {
            PKPaymentButton(type: .plain, style: .automatic, disableCardArt: true)
        } else if #available(iOS 14, *) {
            PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .automatic)
        } else {
            PKPaymentButton(
                paymentButtonType: .plain,
                paymentButtonStyle: traitCollection.userInterfaceStyle == .dark ? .white : .black
            )
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onPaymentButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(view)
        let constraints = [
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    var viewModel: ApplePayViewModel?
    
    func setup(_ viewModel: ApplePayViewModel) {
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 14, *) { return }
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setupPaymentButton()
        }
    }
    
    @objc func onPaymentButtonTapped() {
        viewModel?.onPaymentButtonTapped()
    }
}
