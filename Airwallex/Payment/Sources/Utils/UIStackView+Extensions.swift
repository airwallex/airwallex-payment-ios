//
//  UIStackView.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/27.
//  Copyright © 2024 Airwallex. All rights reserved.
//

extension UIStackView {
    @discardableResult
    func insertSpacer(_ space: CGFloat,
                      at index: Int,
                      priority: UILayoutPriority? = nil) -> UIView {
        let spacer = spacer(space, priority: priority)
        insertArrangedSubview(spacer, at: index)
        return spacer
    }
    
    @discardableResult
    func addSpacer(_ space: CGFloat, priority: UILayoutPriority? = nil) -> UIView {
        let spacer = spacer(space, priority: priority)
        addArrangedSubview(spacer)
        return spacer
    }
    
    private func spacer(_ space: CGFloat, priority: UILayoutPriority? = nil) -> UIView {
        let spacer = UIView()
        switch axis {
        case .horizontal:
            let hConstraint = spacer.widthAnchor.constraint(equalToConstant: space)
            hConstraint.priority = priority ?? .required - 1
            hConstraint.isActive = true
            
            let vConstraint = spacer.heightAnchor.constraint(equalToConstant: space)
            vConstraint.priority = .fittingSizeLevel + 10
            vConstraint.isActive = true
        case .vertical:
            let hConstraint = spacer.widthAnchor.constraint(equalToConstant: space)
            hConstraint.priority = .fittingSizeLevel + 10
            hConstraint.isActive = true
            
            let vConstraint = spacer.heightAnchor.constraint(equalToConstant: space)
            vConstraint.priority = priority ?? .required - 1
            vConstraint.isActive = true
        }
        return spacer
    }
}
