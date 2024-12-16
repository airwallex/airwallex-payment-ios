//
//  Colors.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

extension UIColor {
    static var awxBackgroundHighlight: UIColor { UIColor(dynamicLightColor: awxPurple5, darkColor: awxPurple90) }
    
    static var awxBorderDecorative: UIColor { UIColor(dynamicLightColor: awxGray20, darkColor: awxGray80) }
    
    
    static var awxIconPrimary: UIColor { UIColor(dynamicLightColor: awxGray80, darkColor: awxGray30) }
}

fileprivate extension UIColor {
    
    static var awxGray20: UIColor { UIColor(hex: 0xE8EAED) }
    static var awxGray30: UIColor { UIColor(hex: 0xD0D4D9) }
    static var awxGray80: UIColor { UIColor(hex: 0x2B2F33) }
    
    static var awxPurple5: UIColor { UIColor(hex: 0xF7F7FF) }
    static var awxPurple90: UIColor { UIColor(hex: 0x320094) }
}
