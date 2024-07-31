//
//  UIFontUtilsTests.swift
//  CoreTests
//
//  Created by Tony He (CTR) on 2024/7/31.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import XCTest

@testable import Core

class UIFontUtilsTests: XCTestCase {
    func testAirwallexTitleFont() {
        let font = UIFont.airwallexTitle
        XCTAssertNotNil(font)
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 28.0, weight: .bold).fontName)
        XCTAssertEqual(font.pointSize, 28.0)
        XCTAssertEqual(font.fontDescriptor.symbolicTraits.contains(.traitBold), true)
    }

    func testAirwallexHeadlineFont() {
        let font = UIFont.airwallexHeadline
        XCTAssertNotNil(font)
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 17.0, weight: .bold).fontName)
        XCTAssertEqual(font.pointSize, 17.0)
        XCTAssertEqual(font.fontDescriptor.symbolicTraits.contains(.traitBold), true)
    }

    func testAirwallexBodyFont() {
        let font = UIFont.airwallexBody
        XCTAssertNotNil(font)
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 17.0, weight: .regular).fontName)
        XCTAssertEqual(font.pointSize, 17.0)
    }

    func testAirwallexBody2Font() {
        let font = UIFont.airwallexBody2
        XCTAssertNotNil(font)
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 14.0, weight: .regular).fontName)
        XCTAssertEqual(font.pointSize, 14.0)
    }

    func testAirwallexSubhead1Font() {
        let font = UIFont.airwallexSubhead1
        XCTAssertNotNil(font)
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 15.0, weight: .regular).fontName)
        XCTAssertEqual(font.pointSize, 15.0)
    }

    func testAirwallexSubhead2Font() {
        let font = UIFont.airwallexSubhead2
        XCTAssertNotNil(font)
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 15.0, weight: .medium).fontName)
        XCTAssertEqual(font.pointSize, 15.0)
    }

    func testAirwallexCaption1Font() {
        let font = UIFont.airwallexCaption1
        XCTAssertNotNil(font)
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 12.0, weight: .regular).fontName)
        XCTAssertEqual(font.pointSize, 12.0)
    }

    func testAirwallexCaption2Font() {
        let font = UIFont.airwallexCaption2
        XCTAssertNotNil(font)
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 12.0, weight: .semibold).fontName)
        XCTAssertEqual(font.pointSize, 12.0)
        XCTAssertEqual(font.fontDescriptor.symbolicTraits.contains(.traitBold), true)
    }
}
