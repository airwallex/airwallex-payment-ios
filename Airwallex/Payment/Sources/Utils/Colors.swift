//
//  Colors.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

extension UIColor {
    // background
    static var awxBackgroundPrimary: UIColor { UIColor(dynamicLightColor: awxWhite, darkColor: awxGray100) }
    static var awxBackgroundSecondary: UIColor { UIColor(dynamicLightColor: awxGray10, darkColor: awxGray90) }
    static var awxBackgroundHighlight: UIColor { UIColor(dynamicLightColor: awxPurple5, darkColor: awxPurple90) }
    static var awxBackgroundInteractive: UIColor { UIColor(dynamicLightColor: awxPurple70, darkColor: awxPurple40) }
    
    // border
    static var awxBorderDecorative: UIColor { UIColor(dynamicLightColor: awxGray20, darkColor: awxGray80) }
    static var awxBorderInterative: UIColor { UIColor(dynamicLightColor: awxPurple70, darkColor: awxPurple40) }
    
    // Icon
    static var awxIconPrimary: UIColor { UIColor(dynamicLightColor: awxGray80, darkColor: awxGray30) }
    static var awxIconLink: UIColor { UIColor(dynamicLightColor: awxPurple70, darkColor: awxPurple40) }
    
    // text
    static var awxTextLink: UIColor { UIColor(dynamicLightColor: awxPurple70, darkColor: awxPurple40) }
    static var awxTextPrimary: UIColor { UIColor(dynamicLightColor: awxGray100, darkColor: awxGray10) }
    static var awxTextSecondary: UIColor { UIColor(dynamicLightColor: awxGray60, darkColor: awxGray50) }
}

fileprivate extension UIColor {
    
    static var awxWhite: UIColor { UIColor.white }
    
    static var awxGray10: UIColor { UIColor(hex: 0xF5F6F7) }
    static var awxGray20: UIColor { UIColor(hex: 0xE8EAED) }
    static var awxGray30: UIColor { UIColor(hex: 0xD0D4D9) }
    static var awxGray50: UIColor { UIColor(hex: 0x878E99) }
    static var awxGray60: UIColor { UIColor(hex: 0x68707A) }
    static var awxGray80: UIColor { UIColor(hex: 0x2B2F33) }
    static var awxGray90: UIColor { UIColor(hex: 0x1B1F21) }
    static var awxGray100: UIColor { UIColor(hex: 0x14171A) }
    
    static var awxPurple5: UIColor { UIColor(hex: 0xF7F7FF) }
    static var awxPurple40: UIColor { UIColor(hex: 0xABA8FF) }
    static var awxPurple70: UIColor { UIColor(hex: 0x612FFF) }
    static var awxPurple90: UIColor { UIColor(hex: 0x320094) }
}
