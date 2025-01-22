//
//  Font+Extensions.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/20.
//  Copyright © 2025 Airwallex. All rights reserved.
//

extension UIFont {
    static func preferredBoldFont(withTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        let boldDescriptor = descriptor.withSymbolicTraits(.traitBold) ?? descriptor
        let boldFont = UIFont(descriptor: boldDescriptor, size: 0)
        return boldFont
    }
    
    enum AWXFont {
        case title1, title2, title3
        case headline1, headline2
        case subtitle1
        case caption1, caption2, caption3
        case body1, body2
        case optional1, optional2
        case error1, error2
        
        var size: CGFloat {
            switch self {
            case .title1: return 28// Full page takeovers (eg. alerts, onboarding)
            case .title2: return 22// PageHeader component header, Primary headers
            case .title3: return 20// Section headers
            case .headline1: return 17// Button text
            case .headline2: return 15// small buttons
            case .subtitle1: return 15// tip, label, checkbox, radio button, date picker
            case .caption1: return 14
            case .caption2: return 12
            case .caption3: return 11
            case .body1: return 17
            case .body2: return 15
            case .optional1: return 14
            case .optional2: return 12
            case .error1: return 14
            case .error2: return 12
            }
        }
    }
    
    /// return UIFont by semantic and weight
    /// - Parameters:
    ///   - font: Defined by UI
    ///   - weight: weight of font
    /// - Returns: UIFont
    static func awxFont(_ font: AWXFont, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.systemFont(ofSize: font.size, weight: weight)
    }
}
