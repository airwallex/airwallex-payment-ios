//
//  UIColorUtilsTests.swift
//  CoreTests
//
//  Created by Tony He (CTR) on 2024/7/30.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import XCTest
@testable import Core

class UIColorUtilsTests: XCTestCase {

    func testColorWithHex() {
        // Testing fixed known color values

        let color1 = UIColor.colorWithHex(0xFFFFFF)
        let expectedColor1 = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        XCTAssertEqual(color1, expectedColor1, "Expected color to be white")

        let color2 = UIColor.colorWithHex(0x000000)
        let expectedColor2 = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        XCTAssertEqual(color2, expectedColor2, "Expected color to be black")

        let color3 = UIColor.colorWithHex(0xFF0000)
        let expectedColor3 = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        XCTAssertEqual(color3, expectedColor3, "Expected color to be red")
    }

    func testDynamicColor() {
        if #available(iOS 13.0, *) {
            let lightColor = UIColor.white
            let darkColor = UIColor.black
            let dynamicColor = UIColor.colorWithDynamicLightColor(lightColor, darkColor: darkColor)
            
            // Simulate light mode
            let lightModeTrait = UITraitCollection(userInterfaceStyle: .light)
            XCTAssertEqual(dynamicColor.resolvedColor(with: lightModeTrait), lightColor, "Expected light color to be white in light mode")
            
            // Simulate dark mode
            let darkModeTrait = UITraitCollection(userInterfaceStyle: .dark)
            XCTAssertEqual(dynamicColor.resolvedColor(with: darkModeTrait), darkColor, "Expected dark color to be black in dark mode")
        }
    }

    func testPredefinedColors() {
        // Check if predefined colors match the expected values
        XCTAssertEqual(UIColor.airwallexGray10Color, UIColor.colorWithHex(0xF6F7F8))
        XCTAssertEqual(UIColor.airwallexGray30Color, UIColor.colorWithHex(0xD7DBE0))
        XCTAssertEqual(UIColor.airwallexGray50Color, UIColor.colorWithHex(0x868E98))
        XCTAssertEqual(UIColor.airwallexGray70Color, UIColor.colorWithHex(0x545B63))
        XCTAssertEqual(UIColor.airwallexGray80Color, UIColor.colorWithHex(0x42474D))
        XCTAssertEqual(UIColor.airwallexGray90Color, UIColor.colorWithHex(0x2F3237))
        XCTAssertEqual(UIColor.airwallexGray100Color, UIColor.colorWithHex(0x1A1D21))
        XCTAssertEqual(UIColor.airwallexUltraviolet40Color, UIColor.colorWithHex(0xB3AEFF))
        XCTAssertEqual(UIColor.airwallexUltraviolet70Color, UIColor.colorWithHex(0x612FFF))
        XCTAssertEqual(UIColor.airwallexRed50Color, UIColor.colorWithHex(0xFF4F42))
        XCTAssertEqual(UIColor.airwallexOrange50Color, UIColor.colorWithHex(0xFF8E3C))
        XCTAssertEqual(UIColor.airwallexYellow10Color, UIColor.colorWithHex(0xFFF8E0))
    }

    func testAirwallexToolbarColor() {
        if #available(iOS 13.0, *) {
            let lightModeTrait = UITraitCollection(userInterfaceStyle: .light)
            let darkModeTrait = UITraitCollection(userInterfaceStyle: .dark)

            XCTAssertEqual(UIColor.airwallexToolbar.resolvedColor(with: lightModeTrait), .white)
            XCTAssertEqual(UIColor.airwallexToolbar.resolvedColor(with: darkModeTrait), UIColor.airwallexGray100Color)
        } else {
            XCTAssertEqual(UIColor.airwallexToolbar, .white)
        }
       }
       
       func testAirwallexPrimaryBackgroundColor() {
           if #available(iOS 13.0, *) {
               let lightModeTrait = UITraitCollection(userInterfaceStyle: .light)
               let darkModeTrait = UITraitCollection(userInterfaceStyle: .dark)

               XCTAssertEqual(UIColor.airwallexPrimaryBackground.resolvedColor(with: lightModeTrait), .white)
               XCTAssertEqual(UIColor.airwallexPrimaryBackground.resolvedColor(with: darkModeTrait), UIColor.airwallexGray100Color)
           } else {
               XCTAssertEqual(UIColor.airwallexPrimaryBackground, .white)
           }
       }
       
       func testAirwallexSurfaceBackgroundColor() {
           if #available(iOS 13.0, *) {
               let lightModeTrait = UITraitCollection(userInterfaceStyle: .light)
               let darkModeTrait = UITraitCollection(userInterfaceStyle: .dark)
               
               XCTAssertEqual(UIColor.airwallexSurfaceBackground.resolvedColor(with: lightModeTrait), .white)
               XCTAssertEqual(UIColor.airwallexSurfaceBackground.resolvedColor(with: darkModeTrait), UIColor.airwallexGray90Color)
           } else {
               XCTAssertEqual(UIColor.airwallexSurfaceBackground, .white)
           }
       }
       
       func testAirwallexPrimaryTextColor() {
           if #available(iOS 13.0, *) {
               let lightModeTrait = UITraitCollection(userInterfaceStyle: .light)
               let darkModeTrait = UITraitCollection(userInterfaceStyle: .dark)
               
               XCTAssertEqual(UIColor.airwallexPrimaryText.resolvedColor(with: lightModeTrait), UIColor.airwallexGray100Color)
               XCTAssertEqual(UIColor.airwallexPrimaryText.resolvedColor(with: darkModeTrait), .white)
           } else {
               XCTAssertEqual(UIColor.airwallexPrimaryText, UIColor.airwallexGray100Color)
           }
       }
       
       func testAirwallexSecondaryTextColor() {
           XCTAssertEqual(UIColor.airwallexSecondaryText, UIColor.airwallexGray50Color)
       }
       
       func testAirwallexDisabledButtonColor() {
           if #available(iOS 13.0, *) {
               let lightModeTrait = UITraitCollection(userInterfaceStyle: .light)
               let darkModeTrait = UITraitCollection(userInterfaceStyle: .dark)
               
               XCTAssertEqual(UIColor.airwallexDisabledButton.resolvedColor(with: lightModeTrait), UIColor.airwallexGray30Color)
               XCTAssertEqual(UIColor.airwallexDisabledButton.resolvedColor(with: darkModeTrait), UIColor.airwallexGray80Color)
           } else {
               XCTAssertEqual(UIColor.airwallexDisabledButton, UIColor.airwallexGray30Color)
           }
       }
       
       func testAirwallexPrimaryButtonTextColor() {
           if #available(iOS 13.0, *) {
               let lightModeTrait = UITraitCollection(userInterfaceStyle: .light)
               let darkModeTrait = UITraitCollection(userInterfaceStyle: .dark)
               
               XCTAssertEqual(UIColor.airwallexPrimaryButtonText.resolvedColor(with: lightModeTrait), .white)
               XCTAssertEqual(UIColor.airwallexPrimaryButtonText.resolvedColor(with: darkModeTrait), UIColor.airwallexGray100Color)
           } else {
               XCTAssertEqual(UIColor.airwallexPrimaryButtonText, .white)
           }
       }
       
       func testAirwallexLineColor() {
           if #available(iOS 13.0, *) {
               let lightModeTrait = UITraitCollection(userInterfaceStyle: .light)
               let darkModeTrait = UITraitCollection(userInterfaceStyle: .dark)
               
               XCTAssertEqual(UIColor.airwallexLine.resolvedColor(with: lightModeTrait), UIColor.airwallexGray30Color)
               XCTAssertEqual(UIColor.airwallexLine.resolvedColor(with: darkModeTrait), UIColor.airwallexGray80Color)
           } else {
               XCTAssertEqual(UIColor.airwallexLine, UIColor.airwallexGray30Color)
           }
       }
       
       func testAirwallexGlyphColor() {
           XCTAssertEqual(UIColor.airwallexGlyph, UIColor.airwallexGray70Color)
       }
       
       func testAirwallexErrorColor() {
           XCTAssertEqual(UIColor.airwallexError, UIColor.airwallexRed50Color)
       }
       
    func testAirwallexTintColor() {
           if #available(iOS 13.0, *) {
               let lightModeTrait = UITraitCollection(userInterfaceStyle: .light)
               let darkModeTrait = UITraitCollection(userInterfaceStyle: .dark)
               
               XCTAssertEqual(UIColor.airwallexTint.resolvedColor(with: lightModeTrait), UIColor.airwallexGray70Color)
               XCTAssertEqual(UIColor.airwallexTint.resolvedColor(with: darkModeTrait), UIColor.airwallexUltraviolet40Color)
           } else {
               XCTAssertEqual(UIColor.airwallexTint, UIColor.airwallexGray70Color)
           }
       }
       
       func testAirwallexShadowColor() {
           XCTAssertEqual(UIColor.airwallexShadow, UIColor.black.withAlphaComponent(0.08))
       }
}
