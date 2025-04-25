//
//  FontExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

class FontExtensionTests: XCTestCase {
    
    func testAWXFontLargeTitle() {
        let font = UIFont.awxFont(.largeTitle, weight: .bold)
        XCTAssertEqual(font.pointSize, 34)
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 34, weight: .bold).fontName)
        XCTAssertEqual(getFontWeight(font), .bold)
    }
    
    func testAWXFontTitle1() {
        let font = UIFont.awxFont(.title1)
        XCTAssertEqual(font.pointSize, 28)
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 28, weight: .regular).fontName)
        XCTAssertEqual(getFontWeight(font), .regular)
    }
    
    func testAWXFontTitle2() {
        let font = UIFont.awxFont(.title2, weight: .light)
        XCTAssertEqual(font.pointSize, 22)
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 22, weight: .light).fontName)
        XCTAssertEqual(getFontWeight(font), .light)
    }
    
    private func getFontWeight(_ font: UIFont) -> UIFont.Weight {
        let weightNumber = font.fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any]
        let weight = weightNumber?[.weight] as? CGFloat ?? UIFont.Weight.regular.rawValue
        return UIFont.Weight(rawValue: weight)
    }
}
