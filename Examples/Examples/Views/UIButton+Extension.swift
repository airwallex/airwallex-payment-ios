//
//  UIButton+Extension.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/20.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import Airwallex

class AWXButton: UIButton {
    
    enum AWXButtonStyle {
        case primary
        case secondary
        case mini
    }
    
    private let style: AWXButtonStyle
    
    /// create a button for primary action usually at the bottom of the page
    /// - Parameter title: button title
    /// - Returns: customized button
    init(style: AWXButtonStyle, title: String? = nil, icon: UIImage? = nil) {
        self.style = style
        super.init(frame: .zero)
        switch style {
        case .primary:
            backgroundColor = .awxColor(.backgroundInteractive)
            layer.cornerRadius = 8
            titleLabel?.font = .awxFont(.headline1, weight: .bold)
            
            setTitle(title, for: .normal)
            setTitleColor(.white, for: .normal)
        case .secondary:
            contentEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
            backgroundColor = .awxColor(.backgroundPrimary)
            layer.borderColor = .awxCGColor(.borderDecorative)
            layer.cornerRadius = 8
            layer.borderWidth = 1
            titleLabel?.font = .awxFont(.headline1, weight: .bold)
            
            setTitle(title, for: .normal)
            setTitleColor(.awxColor(.textLink), for: .normal)
        case .mini:
            contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
            backgroundColor = .awxColor(.backgroundPrimary)
            layer.borderColor = .awxCGColor(.borderDecorative)
            layer.cornerRadius = 8
            layer.borderWidth = 1
            titleLabel?.font = .awxFont(.headline2, weight: .bold)
            
            setTitle(title, for: .normal)
            setImage(icon, for: .normal)
            setTitleColor(.awxColor(.iconLink), for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            switch style {
            case .secondary:
                layer.borderColor = .awxCGColor(.borderDecorative)
            case .mini:
                layer.borderColor = .awxCGColor(.borderDecorative)
            default: break
            }
        }
    }
}
