//
//  UIStackView.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/27.
//  Copyright © 2024 Airwallex. All rights reserved.
//
import UIKit

extension UIStackView {
    func addSpacer(_ space: CGFloat) {
        let spacer = UIView()
        switch axis {
        case .horizontal:
            let hConstraint = spacer.widthAnchor.constraint(equalToConstant: space)
            hConstraint.priority = .required - 1
            hConstraint.isActive = true
            
            let vConstraint = spacer.heightAnchor.constraint(equalToConstant: space)
            vConstraint.priority = .fittingSizeLevel + 10
            vConstraint.isActive = true
        case .vertical:
            let hConstraint = spacer.widthAnchor.constraint(equalToConstant: space)
            hConstraint.priority = .fittingSizeLevel + 10
            hConstraint.isActive = true
            
            let vConstraint = spacer.heightAnchor.constraint(equalToConstant: space)
            vConstraint.priority = .required - 1
            vConstraint.isActive = true
        @unknown default:
            assert(false, "unexpected axis")
            return
        }
        addArrangedSubview(spacer)
    }
}
