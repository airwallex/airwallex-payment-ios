//
//  Colors.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

public extension UIColor {
    
    public enum AWXColor {
        // Background colors
        case backgroundPrimary
        case backgroundSecondary
        case backgroundField
        case backgroundHighlight
        case backgroundSelected
        case backgroundInteractive
        case backgroundWarning
        
        // Border colors
        case borderDecorative
        case borderPerceivable
        case borderInteractive
        case borderError
        
        // Icon colors
        case iconPrimary
        case iconSecondary
        case iconLink
        case iconDisabled
        
        // Text colors
        case textLink
        case textPrimary
        case textSecondary
        case textPlaceholder
        case textError
        case textInverse
    }
    
    static func awxColor(_ color: AWXColor) -> UIColor {
        switch color {
            // Background Colors
        case .backgroundPrimary: return UIColor(dynamicLightColor: .awxWhite, darkColor: .awxGray100)
        case .backgroundSecondary: return UIColor(dynamicLightColor: .awxGray10, darkColor: .awxGray90)
        case .backgroundField: return UIColor(dynamicLightColor: .awxGray5, darkColor: .awxGray90)
        case .backgroundHighlight: return UIColor(dynamicLightColor: .awxPurple5, darkColor: .awxPurple90)
        case .backgroundSelected: return UIColor(dynamicLightColor: .awxPurple20, darkColor: .awxPurple80)
        case .backgroundInteractive: return UIColor(dynamicLightColor: .awxPurple70, darkColor: .awxPurple40)
        case .backgroundWarning: return .awxYello10
            
            // Border Colors
        case .borderDecorative: return UIColor(dynamicLightColor: .awxGray20, darkColor: .awxGray80)
        case .borderPerceivable: return UIColor(dynamicLightColor: .awxGray50, darkColor: .awxGray60)
        case .borderInteractive: return UIColor(dynamicLightColor: .awxPurple70, darkColor: .awxPurple40)
        case .borderError: return UIColor(dynamicLightColor: .awxRed50, darkColor: .awxRed60)
            
            // Icon Colors
        case .iconPrimary: return UIColor(dynamicLightColor: .awxGray80, darkColor: .awxGray30)
        case .iconSecondary: return UIColor(dynamicLightColor: .awxGray50, darkColor: .awxGray50)
        case .iconLink: return UIColor(dynamicLightColor: .awxPurple70, darkColor: .awxPurple40)
        case .iconDisabled: return UIColor(dynamicLightColor: .awxGray40, darkColor: .awxGray70)
            
            // Text Colors
        case .textLink: return UIColor(dynamicLightColor: .awxPurple70, darkColor: .awxPurple40)
        case .textPrimary: return UIColor(dynamicLightColor: .awxGray100, darkColor: .awxGray10)
        case .textSecondary: return UIColor(dynamicLightColor: .awxGray60, darkColor: .awxGray50)
        case .textPlaceholder: return UIColor(dynamicLightColor: .awxGray50, darkColor: .awxGray60)
        case .textError: return UIColor(dynamicLightColor: .awxRed60, darkColor: .awxRed40)
        case .textInverse: return UIColor(dynamicLightColor: .awxWhite, darkColor: .awxGray100)
        }
    }
}

extension UIColor {
    
    static var awxWhite: UIColor { UIColor.white }
    
    static var awxGray5: UIColor { UIColor(hex: 0xFAFAFB) }
    static var awxGray10: UIColor { UIColor(hex: 0xF5F6F7) }
    static var awxGray20: UIColor { UIColor(hex: 0xE8EAED) }
    static var awxGray30: UIColor { UIColor(hex: 0xD0D4D9) }
    static var awxGray40: UIColor { UIColor(hex: 0xB0B6BF) }
    static var awxGray50: UIColor { UIColor(hex: 0x878E99) }
    static var awxGray60: UIColor { UIColor(hex: 0x68707A) }
    static var awxGray70: UIColor { UIColor(hex: 0x4C5259) }
    static var awxGray80: UIColor { UIColor(hex: 0x2B2F33) }
    static var awxGray90: UIColor { UIColor(hex: 0x1B1F21) }
    static var awxGray100: UIColor { UIColor(hex: 0x14171A) }
    
    static var awxPurple5: UIColor { UIColor(hex: 0xF7F7FF) }
    static var awxPurple20: UIColor { UIColor(hex: 0xDFDEFF) }
    static var awxPurple40: UIColor { UIColor(hex: 0xABA8FF) }
    static var awxPurple70: UIColor { UIColor(hex: 0x612FFF) }
    static var awxPurple80: UIColor { UIColor(hex: 0x5500E5) }
    static var awxPurple90: UIColor { UIColor(hex: 0x320094) }
    
    static var awxRed40: UIColor { UIColor(hex: 0xFC796D) }
    static var awxRed50: UIColor { UIColor(hex: 0xFF4F42) }
    static var awxRed60: UIColor { UIColor(hex: 0xD91807) }
    
    static var awxYello10: UIColor { UIColor(hex: 0xFFF6CC) }
    
    static var awxOrange50: UIColor { UIColor(hex: 0xE56820) }

    convenience init(hex: UInt) {
        let red = CGFloat((hex >> 16) & 0xFF) / 0xFF
        let green = CGFloat((hex >> 8) & 0xFF) / 0xFF
        let blue = CGFloat((hex >> 0) & 0xFF) / 0xFF
        let alpha = hex > 0xFFFFFF ? CGFloat((hex >> 24) & 0xFF) / 0xFF : 1
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
