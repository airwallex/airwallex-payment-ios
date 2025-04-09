//
//  UIImageExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import Payment

class UIImageExtensionTests: XCTestCase {

    func testImageForBrand() {
        let visaImage = UIImage.image(for: .visa)
        XCTAssertNotNil(visaImage, "Visa image should not be nil")
        
        let amexImage = UIImage.image(for: .amex)
        XCTAssertNotNil(amexImage, "Amex image should not be nil")
        
        let mastercardImage = UIImage.image(for: .mastercard)
        XCTAssertNotNil(mastercardImage, "Mastercard image should not be nil")
        
        let unionPayImage = UIImage.image(for: .unionPay)
        XCTAssertNotNil(unionPayImage, "UnionPay image should not be nil")
        
        let jcbImage = UIImage.image(for: .JCB)
        XCTAssertNotNil(jcbImage, "JCB image should not be nil")
        
        let dinersClubImage = UIImage.image(for: .dinersClub)
        XCTAssertNotNil(dinersClubImage, "Diners Club image should not be nil")
        
        let discoverImage = UIImage.image(for: .discover)
        XCTAssertNotNil(discoverImage, "Discover image should not be nil")
        
        let unknownImage = UIImage.image(for: .unknown)
        XCTAssertNil(unknownImage, "Unknown brand image should be nil")
    }

    func testRotateImage() {
        let originalImage = UIImage.image(for: .visa)
        XCTAssertNotNil(originalImage, "Original image should not be nil")
        
        let rotatedImage = originalImage?.rotate(degrees: 90)
        XCTAssertNotNil(rotatedImage, "Rotated image should not be nil")
        
        XCTAssertEqual(rotatedImage?.size.width, originalImage?.size.height, "Rotated image width should be equal to original image height")
        XCTAssertEqual(rotatedImage?.size.height, originalImage?.size.width, "Rotated image height should be equal to original image width")
    }
}
