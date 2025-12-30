//
//  PaletteTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
import AirwallexCore

class PaletteTests: XCTestCase {
    
    func testThemeColorUpdate() {
        let newTintColor = UIColor(hex: "#123456")
        AWXTheme.shared().tintColor = newTintColor
        
        let updatedThemeColor = Palette.SemanticColor.theme.color
        XCTAssertEqual(updatedThemeColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)), newTintColor)
        XCTAssertEqual(updatedThemeColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)),
                       newTintColor.interpolates(with: .white, fraction: 30/70.0))
    }
}
