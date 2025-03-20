//
//  ColorPalette.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/2/28.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

public struct Palette {
    
    public enum SemanticColor {
        case theme
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
        case iconWarning
        
        // Text colors
        case textLink
        case textPrimary
        case textSecondary
        case textPlaceholder
        case textError
        case textInverse
        
        var color: UIColor {
            switch self {
            case .theme:
                return themeColor(by: .level70)
                // Background Colors
            case .backgroundPrimary:
                return UIColor(dynamicLightColor: Palette.white, darkColor: Palette.gray100)
            case .backgroundSecondary:
                return UIColor(dynamicLightColor: Palette.gray10, darkColor: Palette.gray90)
            case .backgroundField:
                return UIColor(dynamicLightColor: Palette.gray5, darkColor: Palette.gray90)
            case .backgroundHighlight:
                return UIColor(dynamicLightColor: Palette.themeColor(by: .level5), darkColor: Palette.themeColor(by: .level90))
            case .backgroundSelected:
                return UIColor(dynamicLightColor: Palette.themeColor(by: .level20), darkColor: Palette.themeColor(by: .level80))
            case .backgroundInteractive:
                return UIColor(dynamicLightColor: Palette.themeColor(by: .level70), darkColor: Palette.themeColor(by: .level40))
            case .backgroundWarning:
                return Palette.yellow10
                
                // Border Colors
            case .borderDecorative:
                return UIColor(dynamicLightColor: Palette.gray20, darkColor: Palette.gray80)
            case .borderPerceivable:
                return UIColor(dynamicLightColor: Palette.gray50, darkColor: Palette.gray60)
            case .borderInteractive:
                return UIColor(dynamicLightColor: Palette.themeColor(by: .level70), darkColor: Palette.themeColor(by: .level40))
            case .borderError:
                return UIColor(dynamicLightColor: Palette.red50, darkColor: Palette.red60)
                
                // Icon Colors
            case .iconPrimary:
                return UIColor(dynamicLightColor: Palette.gray80, darkColor: Palette.gray30)
            case .iconSecondary:
                return UIColor(dynamicLightColor: Palette.gray50, darkColor: Palette.gray50)
            case .iconLink:
                return UIColor(dynamicLightColor: Palette.themeColor(by: .level70), darkColor: Palette.themeColor(by: .level40))
            case .iconDisabled:
                return UIColor(dynamicLightColor: Palette.gray40, darkColor: Palette.gray70)
            case .iconWarning:
                return Palette.orange50
                
                // Text Colors
            case .textLink:
                return UIColor(dynamicLightColor: Palette.themeColor(by: .level70), darkColor: Palette.themeColor(by: .level40))
            case .textPrimary:
                return UIColor(dynamicLightColor: Palette.gray100, darkColor: Palette.gray10)
            case .textSecondary:
                return UIColor(dynamicLightColor: Palette.gray60, darkColor: Palette.gray50)
            case .textPlaceholder:
                return UIColor(dynamicLightColor: Palette.gray50, darkColor: Palette.gray60)
            case .textError:
                return UIColor(dynamicLightColor: Palette.red60, darkColor: Palette.red40)
            case .textInverse:
                return UIColor(dynamicLightColor: Palette.white, darkColor: Palette.gray100)
            }
        }
        
        var cgColor: CGColor {
            color.cgColor
        }
    }
    
    enum Level: Int {
        case level5 = 5, level10 = 10, level20 = 20, level30 = 30
        case level40 = 40, level50 = 50, level60 = 60, level70 = 70
        case level80 = 80, level90 = 90, level100 = 100
    }
    
    static let black = UIColor.black
    static let white = UIColor.white
    
    static let gray5 = UIColor(hex: "#FAFAFB")
    static let gray10 = UIColor(hex: "#F5F6F7")
    static let gray20 = UIColor(hex: "#E8EAED")
    static let gray30 = UIColor(hex: "#D0D4D9")
    static let gray40 = UIColor(hex: "#B0B6BF")
    static let gray50 = UIColor(hex: "#878E99")
    static let gray60 = UIColor(hex: "#68707A")
    static let gray70 = UIColor(hex: "#4C5259")
    static let gray80 = UIColor(hex: "#2B2F33")
    static let gray90 = UIColor(hex: "#1B1F21")
    static let gray100 = UIColor(hex: "#14171A")

    static let purple5 = UIColor(hex: "#F7F7FF")
    static let purple10 = UIColor(hex: "#FOEFFF")
    static let purple20 = UIColor(hex: "#DFDEFF")
    static let purple30 = UIColor(hex: "#CBC9FF")
    static let purple40 = UIColor(hex: "#ABA8FF")
    static let purple50 = UIColor(hex: "#867DFF")
    static let purple60 = UIColor(hex: "#6B54F0")
    static let purple70 = UIColor(hex: "#612FFF")
    static let purple80 = UIColor(hex: "#5500E5")
    static let purple90 = UIColor(hex: "#320094")
    static let purple100 = UIColor(hex: "#15005C")

    static let blue5 = UIColor(hex: "#F0F2FE")
    static let blue10 = UIColor(hex: "#E0E2FE")
    static let blue20 = UIColor(hex: "#BAE6FD")
    static let blue30 = UIColor(hex: "#8AD9FF")
    static let blue40 = UIColor(hex: "#3AC0FC")
    static let blue50 = UIColor(hex: "#0096DB")
    static let blue60 = UIColor(hex: "#0074B8")
    static let blue70 = UIColor(hex: "#0F5D99")
    static let blue80 = UIColor(hex: "#0E3C78")
    static let blue90 = UIColor(hex: "#10254F")
    static let blue100 = UIColor(hex: "#0D1A33")

    static let green5 = UIColor(hex: "#EFFBF4")
    static let green10 = UIColor(hex: "#D9FCE7")
    static let green20 = UIColor(hex: "#BAF2D1")
    static let green30 = UIColor(hex: "#8EEDB4")
    static let green40 = UIColor(hex: "#49D189")
    static let green50 = UIColor(hex: "#00A156")
    static let green60 = UIColor(hex: "#008044")
    static let green70 = UIColor(hex: "#036B3B")
    static let green80 = UIColor(hex: "#054F2C")
    static let green90 = UIColor(hex: "#05361F")
    static let green100 = UIColor(hex: "#042616")

    static let yellow5 = UIColor(hex: "#FFFCED")
    static let yellow10 = UIColor(hex: "#FFF6CC")
    static let yellow20 = UIColor(hex: "#FAE891")
    static let yellow30 = UIColor(hex: "#F5D64E")
    static let yellow40 = UIColor(hex: "#E5B917")
    static let yellow50 = UIColor(hex: "#CC9814")
    static let yellow60 = UIColor(hex: "#AD7823")
    static let yellow70 = UIColor(hex: "#875C1B")
    static let yellow80 = UIColor(hex: "#634114")
    static let yellow90 = UIColor(hex: "#4D320F")
    static let yellow100 = UIColor(hex: "#38250B")

    static let orange5 = UIColor(hex: "#FFF6EF")
    static let orange10 = UIColor(hex: "#FFEDE0")
    static let orange20 = UIColor(hex: "#FFD9BD")
    static let orange30 = UIColor(hex: "#FFB27A")
    static let orange40 = UIColor(hex: "#FF8E3C")
    static let orange50 = UIColor(hex: "#E56820")
    static let orange60 = UIColor(hex: "#C4490C")
    static let orange70 = UIColor(hex: "#A3330D")
    static let orange80 = UIColor(hex: "#8C300E")
    static let orange90 = UIColor(hex: "#69200A")
    static let orange100 = UIColor(hex: "#4D1A0B")

    static let red5 = UIColor(hex: "#FFF5F5")
    static let red10 = UIColor(hex: "#FEE7E5")
    static let red20 = UIColor(hex: "#FFCECC")
    static let red30 = UIColor(hex: "#FFAAA6")
    static let red40 = UIColor(hex: "#FC796D")
    static let red50 = UIColor(hex: "#F44F42")
    static let red60 = UIColor(hex: "#D91807")
    static let red70 = UIColor(hex: "#A61202")
    static let red80 = UIColor(hex: "#801302")
    static let red90 = UIColor(hex: "#661405")
    static let red100 = UIColor(hex: "#521004")
    
    static func themeColor(by level: Level) -> UIColor {
        guard let themeColor = AWXTheme.shared().tintColor?.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)),
              themeColor != purple70 else {
            switch level {
            case .level5: return purple5
            case .level10: return purple10
            case .level20: return purple20
            case .level30: return purple30
            case .level40: return purple40
            case .level50: return purple50
            case .level60: return purple60
            case .level70: return purple70
            case .level80: return purple80
            case .level90: return purple90
            case .level100: return purple100
            }
        }
        
        let base = 70
        if level.rawValue < base {
            let color = themeColor.interpolates(
                with: .white,
                fraction: CGFloat(base - level.rawValue) / CGFloat(base)
            )
            return color
        } else if level.rawValue > base {
            return themeColor.interpolates(
                with: .black,
                fraction: CGFloat(level.rawValue - base) / 50
            )
        } else {
            return themeColor
        }
    }
}
