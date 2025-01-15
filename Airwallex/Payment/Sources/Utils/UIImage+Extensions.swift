//
//  UIImage+extension.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/18.
//  Copyright © 2024 Airwallex. All rights reserved.
//


extension UIImage {
    
    static func image(for brand: AWXBrandType) -> UIImage? {
        var imageName: String? = nil
        switch brand {
        case .visa:
            imageName = "visa"
        case .amex:
            imageName = "amex"
        case .mastercard:
            imageName = "mastercard"
        case .unionPay:
            imageName = "unionpay"
        case .JCB:
            imageName = "jcb"
        case .dinersClub:
            imageName = "diners"
        case .discover:
            imageName = "discover"
        default:
            imageName = nil
        }
        guard let imageName else { return nil }
        return UIImage(named: imageName, in: Bundle.resource(), compatibleWith: nil)
    }
}
