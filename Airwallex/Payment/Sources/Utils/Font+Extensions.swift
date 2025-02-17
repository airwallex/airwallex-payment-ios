//
//  Fonts.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/16.
//  Copyright © 2024 Airwallex. All rights reserved.
//
//
//UltraLight: [100] (approximation)
//Thin: [200] (approximation)
//Light: [300]
//Regular: [400]
//Medium: [500]
//Semibold: [600]
//Bold: [700]
//Heavy/Black: [800] (both can map to higher numeric values)

extension UIFont {
    
    /// 20
    static var awxHeadline100: UIFont { UIFont.boldSystemFont(ofSize: 20)}
    /// 14
    static var awxHeadline400: UIFont { UIFont.boldSystemFont(ofSize: 14)}
    
    /// 14
    static var awxBody: UIFont { UIFont.systemFont(ofSize: 14) }
    /// 14
    static var awxBodyBold: UIFont { UIFont.boldSystemFont(ofSize: 14) }
    
    /// 12
    static var awxHint: UIFont { UIFont.systemFont(ofSize: 12) }
    /// 12
    static var awxHintBold: UIFont { UIFont.boldSystemFont(ofSize: 12) }
}
