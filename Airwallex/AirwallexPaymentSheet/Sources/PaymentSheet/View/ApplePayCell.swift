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
    var buttonType: PKPaymentButtonType
    var disableCardArt: Bool = true
    var onPaymentButtonTapped: () -> Void
}

class ApplePayCell: UICollectionViewCell, ViewReusable, ViewConfigurable {

    private func setupPaymentButton(_ type: PKPaymentButtonType, disableCardArt: Bool = true) {
        contentView.subviews.forEach { view in
            view.removeFromSuperview()
        }

        let view: PKPaymentButton
        #if compiler(>=6.2)
        if #available(iOS 26, *) {
            view = PKPaymentButton(type: type, style: .automatic, disableCardArt: disableCardArt)
        } else if #available(iOS 14, *) {
            view = PKPaymentButton(paymentButtonType: type, paymentButtonStyle: .automatic)
        } else {
            view = PKPaymentButton(
                paymentButtonType: type,
                paymentButtonStyle: traitCollection.userInterfaceStyle == .dark ? .white : .black
            )
        }
        #else
        if #available(iOS 14, *) {
            view = PKPaymentButton(paymentButtonType: type, paymentButtonStyle: .automatic)
        } else {
            view = PKPaymentButton(
                paymentButtonType: type,
                paymentButtonStyle: traitCollection.userInterfaceStyle == .dark ? .white : .black
            )
        }
        #endif
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onPaymentButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(view)
        let constraints = [
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    var viewModel: ApplePayViewModel?
    
    func setup(_ viewModel: ApplePayViewModel) {
        if self.viewModel?.buttonType != viewModel.buttonType
            || self.viewModel?.disableCardArt != viewModel.disableCardArt {
            setupPaymentButton(viewModel.buttonType, disableCardArt: viewModel.disableCardArt)
        }
        self.viewModel = viewModel
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 14, *) { return }
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setupPaymentButton(viewModel?.buttonType ?? .plain)
        }
    }
    
    @objc func onPaymentButtonTapped() {
        viewModel?.onPaymentButtonTapped()
    }
}
