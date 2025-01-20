//
//  Colors.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

public extension UIColor {
    // background
    static var awxBackgroundPrimary: UIColor { UIColor(dynamicLightColor: awxWhite, darkColor: awxGray100) }
    static var awxBackgroundSecondary: UIColor { UIColor(dynamicLightColor: awxGray10, darkColor: awxGray90) }
    static var awxBackgroundField: UIColor { UIColor(dynamicLightColor: awxGray5, darkColor: awxGray90) }
    static var awxBackgroundHighlight: UIColor { UIColor(dynamicLightColor: awxPurple5, darkColor: awxPurple90) }
    static var awxBackgroundSelected: UIColor { UIColor(dynamicLightColor: awxPurple20, darkColor: awxPurple80) }
    static var awxBackgroundInteractive: UIColor { UIColor(dynamicLightColor: awxPurple70, darkColor: awxPurple40) }
    
    // border
    static var awxBorderDecorative: UIColor { UIColor(dynamicLightColor: awxGray20, darkColor: awxGray80) }
    static var awxBorderPerceivable: UIColor { UIColor(dynamicLightColor: awxGray50, darkColor: awxGray60) }
    static var awxBorderInterative: UIColor { UIColor(dynamicLightColor: awxPurple70, darkColor: awxPurple40) }
    static var awxBorderError: UIColor { UIColor(dynamicLightColor: awxRed50, darkColor: awxRed60) }
    
    // Icon
    static var awxIconPrimary: UIColor { UIColor(dynamicLightColor: awxGray80, darkColor: awxGray30) }
    static var awxIconSecondary: UIColor { UIColor(dynamicLightColor: awxGray60, darkColor: awxGray50) }
    static var awxIconLink: UIColor { UIColor(dynamicLightColor: awxPurple70, darkColor: awxPurple40) }
    static var awxIconDisabled: UIColor { UIColor(dynamicLightColor: awxGray40, darkColor: awxGray70) }
    
    // text
    static var awxTextLink: UIColor { UIColor(dynamicLightColor: awxPurple70, darkColor: awxPurple40) }
    static var awxTextPrimary: UIColor { UIColor(dynamicLightColor: awxGray100, darkColor: awxGray10) }
    static var awxTextSecondary: UIColor { UIColor(dynamicLightColor: awxGray60, darkColor: awxGray50) }
    static var awxTextPlaceholder: UIColor { UIColor(dynamicLightColor: awxGray50, darkColor: awxGray60) }
    static var awxTextError: UIColor { UIColor(dynamicLightColor: awxRed60, darkColor: awxRed40) }
    static var awxTextInverse: UIColor { UIColor(dynamicLightColor: awxWhite, darkColor: awxGray100) }
}

fileprivate extension UIColor {
    
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
}
