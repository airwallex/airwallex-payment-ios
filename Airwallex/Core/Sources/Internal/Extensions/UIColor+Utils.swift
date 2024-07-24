//
//  UIColor+Utils.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/**
 `AWXTheme` manages text styles.
 */

@objc
public extension UIColor {
    class var airwallexToolbar: UIColor {
        .airwallexPrimaryBackground
    }
    class var airwallexPrimaryBackground: UIColor {
        colorWithDynamicLightColor(.white, darkColor: .airwallexGray100Color)
    }
    class var airwallexSurfaceBackground: UIColor {
        colorWithDynamicLightColor(.white, darkColor: .airwallexGray90Color)
    }
    class var airwallexPrimaryText: UIColor {
        colorWithDynamicLightColor(.airwallexGray100Color, darkColor: .white)
    }
    class var airwallexSecondaryText: UIColor {
        .airwallexGray50Color
    }
    class var airwallexDisabledButton: UIColor {
        .airwallexLine
    }
    class var airwallexPrimaryButtonText: UIColor {
        .colorWithDynamicLightColor(.white, darkColor: .airwallexGray100Color)
    }
    class var airwallexLine: UIColor {
        colorWithDynamicLightColor(.airwallexGray30Color, darkColor: .airwallexGray80Color)
    }
    class var airwallexGlyph: UIColor {
        .airwallexGray70Color
    }
    class var airwallexError: UIColor {
        .airwallexRed50Color
    }
    static var airwallexTint: UIColor = .colorWithDynamicLightColor(.airwallexGray70Color, darkColor: .airwallexUltraviolet40Color)
    class var airwallexShadow: UIColor {
        .black.withAlphaComponent(0.08)
    }
    
    
    
    class var airwallexGray10Color: UIColor {
        UIColor.colorWithHex(0xF6F7F8)
    }

    class var airwallexGray30Color: UIColor {
        UIColor.colorWithHex(0xD7DBE0)
    }

    class var airwallexGray50Color: UIColor {
        UIColor.colorWithHex(0x868E98)
    }

    class var airwallexGray70Color: UIColor {
        UIColor.colorWithHex(0x545B63)
    }

    class var airwallexGray80Color: UIColor {
        UIColor.colorWithHex(0x42474D)
    }

    class var airwallexGray90Color: UIColor {
        UIColor.colorWithHex(0x2F3237)
    }

    class var airwallexGray100Color: UIColor {
        UIColor.colorWithHex(0x1A1D21)
    }

    class var airwallexUltraviolet40Color: UIColor {
        UIColor.colorWithHex(0xB3AEFF)
    }

    class var airwallexUltraviolet70Color: UIColor {
        UIColor.colorWithHex(0x612FFF)
    }

    class var airwallexRed50Color: UIColor {
        UIColor.colorWithHex(0xFF4F42)
    }

    class var airwallexOrange50Color: UIColor {
        UIColor.colorWithHex(0xFF8E3C)
    }

    class var airwallexYellow10Color: UIColor {
        UIColor.colorWithHex(0xFFF8E0)
    }

    
    
    
    class func colorWithHex(_ hex:Int) -> UIColor {
        var red, green, blue, alpha: CGFloat
        red = CGFloat((hex >> 16) & 0xff) / CGFloat(0xFF)
        green = CGFloat((hex >> 8) & 0xff) / CGFloat(0xFF)
        blue = CGFloat((hex >> 0) & 0xff) / CGFloat(0xFF)
        alpha = hex > 0xFFFFFF ? CGFloat((hex >> 24) & 0xff) / CGFloat(0xFF) : 1.0
        return .init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    class func colorWithDynamicLightColor(_ lightColor: UIColor, darkColor: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return darkColor
                default:
                    return lightColor
                }
            }
        } else {
            return lightColor
        }
    }
}
