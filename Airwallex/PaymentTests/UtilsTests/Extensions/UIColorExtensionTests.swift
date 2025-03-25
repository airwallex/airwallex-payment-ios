//
//  UIColorExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import Payment

class UIColorExtensionTests: XCTestCase {
    
    func testAwxColor() {
        let primaryColor = UIColor.awxColor(.theme)
        XCTAssertEqual(primaryColor.resolvedColor(with: .init(userInterfaceStyle: .light)), UIColor(hex: "#612FFF"))
        XCTAssertEqual(primaryColor.resolvedColor(with: .init(userInterfaceStyle: .dark)), UIColor(hex: "#ABA8FF"))
        
        let backgroundPrimaryColor = UIColor.awxColor(.backgroundPrimary)
        XCTAssertEqual(backgroundPrimaryColor.resolvedColor(with: .init(userInterfaceStyle: .light)), UIColor.white)
        XCTAssertEqual(backgroundPrimaryColor.resolvedColor(with: .init(userInterfaceStyle: .dark)), UIColor(hex: "#14171A"))
        
        let backgroundSecondaryColor = UIColor.awxColor(.backgroundSecondary)
        XCTAssertEqual(backgroundSecondaryColor.resolvedColor(with: .init(userInterfaceStyle: .light)), UIColor(hex: "#F5F6F7"))
        XCTAssertEqual(backgroundSecondaryColor.resolvedColor(with: .init(userInterfaceStyle: .dark)), UIColor(hex: "#1B1F21"))
        
        let textPrimaryColor = UIColor.awxColor(.textPrimary)
        XCTAssertEqual(textPrimaryColor.resolvedColor(with: .init(userInterfaceStyle: .light)), UIColor(hex: "#14171A"))
        XCTAssertEqual(textPrimaryColor.resolvedColor(with: .init(userInterfaceStyle: .dark)), UIColor(hex: "#F5F6F7"))
    }
    
    func testAwxCGColor() {
        let primaryCGColor = UIColor.awxColor(.theme).cgColor
        XCTAssertEqual(primaryCGColor, UIColor.awxColor(.theme).cgColor)
        
        let backgroundPrimaryCGColor = UIColor.awxColor(.backgroundPrimary).cgColor
        XCTAssertEqual(backgroundPrimaryCGColor, UIColor.awxColor(.backgroundPrimary).cgColor)
        
        let backgroundSecondaryCGColor = UIColor.awxColor(.backgroundSecondary).cgColor
        XCTAssertEqual(backgroundSecondaryCGColor, UIColor.awxColor(.backgroundSecondary).cgColor)
        
        let textPrimaryCGColor = UIColor.awxColor(.textPrimary).cgColor
        XCTAssertEqual(textPrimaryCGColor, UIColor.awxColor(.textPrimary).cgColor)
    }
    
    func testUIColorHexUInt() {
        let color = UIColor(hex: 0x612FFF)
        XCTAssertEqual(color, UIColor(red: 97/255, green: 47/255, blue: 255/255, alpha: 1.0))
    }
    
    func testUIColorHexString() {
        let color = UIColor(hex: "#612FFF")
        XCTAssertEqual(color, UIColor(red: 97/255, green: 47/255, blue: 255/255, alpha: 1.0))
    }
    
    func testToHex() {
        let hexString = "#612FFF"
        let color = UIColor(hex: hexString)
        XCTAssertEqual(color.toHex(), hexString)
    }

    func testInterpolates() {
        let color1 = UIColor(hex: "#FF0000") // Red
        let color2 = UIColor(hex: "#0000FF") // Blue

        let interpolatedColor1 = color1.interpolates(with: color2, fraction: 0.0)
        XCTAssertEqual(interpolatedColor1, color1)

        let interpolatedColor2 = color1.interpolates(with: color2, fraction: 1.0)
        XCTAssertEqual(interpolatedColor2, color2)

        let interpolatedColor3 = color1.interpolates(with: color2, fraction: 0.5)
        print(interpolatedColor3.toHex())
        XCTAssertEqual(interpolatedColor3, UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 1))
    }
}


