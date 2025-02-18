//
//  UIButton+Extension.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/20.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(Airwallex)
import Airwallex
#else
import AirwallexPayment
#endif

extension UIButton {
    
    enum AWXButtonStyle {
        case primary
        case secondary
        case mini
    }
    /// create a button for primary action usually at the bottom of the page
    /// - Parameter title: button title
    /// - Returns: customized button
    convenience init(style: AWXButtonStyle, title: String? = nil, icon: UIImage? = nil) {
        self.init(type: .custom)
        switch style {
        case .primary:
            backgroundColor = .awxBackgroundInteractive
            layer.cornerRadius = 8
            titleLabel?.font = .awxFont(.headline1, weight: .bold)
            
            setTitle(title, for: .normal)
            setTitleColor(.white, for: .normal)
        case .secondary:
            contentEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
            backgroundColor = .awxBackgroundPrimary
            layer.borderColor = UIColor.awxBorderDecorative.cgColor
            layer.cornerRadius = 8
            layer.borderWidth = 1
            titleLabel?.font = .awxFont(.headline1, weight: .bold)
            
            setTitle(title, for: .normal)
            setTitleColor(.awxTextLink, for: .normal)
        case .mini:
            contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
            backgroundColor = .awxBackgroundPrimary
            layer.borderColor = UIColor.awxBorderDecorative.cgColor
            layer.cornerRadius = 8
            layer.borderWidth = 1
            titleLabel?.font = .awxFont(.headline2, weight: .bold)
            
            setTitle(title, for: .normal)
            setImage(icon, for: .normal)
            setTitleColor(.awxIconLink, for: .normal)
        }
        
    }
}
