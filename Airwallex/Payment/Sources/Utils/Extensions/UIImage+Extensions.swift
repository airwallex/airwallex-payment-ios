//
//  UIImage+extension.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/18.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if canImport(Core)
import Core
#endif

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
    
    func rotate(degrees: CGFloat) -> UIImage? {
        // Calculate the new size for the rotated image.
        let newSize = CGSize(width: size.height, height: size.width)
        
        // Create a UIGraphicsImageRenderer with the new size.
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        // Draw and return the rotated image.
        return renderer.image { context in
            // Move the origin to the center to rotate about the center.
            context.cgContext.translateBy(x: newSize.width / 2, y: newSize.height / 2)
            
            // Rotate the context by 90 degrees counterclockwise (equivalent to 270 degrees clockwise).
            context.cgContext.rotate(by: .pi / 2)
            
            // Draw the original image centered at the new origin.
            self.draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        }
    }
}
