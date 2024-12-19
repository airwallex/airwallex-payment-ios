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
        case AWXBrandTypeVisa:
            imageName = "visa"
        case AWXBrandTypeAmex:
            imageName = "amex"
        case AWXBrandTypeMastercard:
            imageName = "mastercard"
        case AWXBrandTypeUnionPay:
            imageName = "unionpay"
        case AWXBrandTypeJCB:
            imageName = "jcb"
        case AWXBrandTypeDinersClub:
            imageName = "diners"
        case AWXBrandTypeDiscover:
            imageName = "discover"
        default:
            imageName = nil
        }
        guard let imageName else { return nil }
        return UIImage(named: imageName, in: Bundle.resource(), compatibleWith: nil)
    }
}
