//
//  AWXColorsTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/1/23.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@_spi(AWX) @testable import AirwallexPayment
import UIKit
import XCTest

@MainActor
class AWXColorsTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        // Reset to nil after each test
        AWXColors.current = nil
        AWXTheme.shared().tintColor = nil
    }

    func testDefaultColorsMatchPalette() {
        let colors = AWXColors()
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)

        // Compare resolved colors since dynamic colors are different objects
        XCTAssertEqual(colors.theme.resolvedColor(with: lightTraits), Palette.SemanticColor.theme.color.resolvedColor(with: lightTraits))
        XCTAssertEqual(colors.theme.resolvedColor(with: darkTraits), Palette.SemanticColor.theme.color.resolvedColor(with: darkTraits))
        XCTAssertEqual(colors.backgroundPrimary.resolvedColor(with: lightTraits), Palette.SemanticColor.backgroundPrimary.color.resolvedColor(with: lightTraits))
        XCTAssertEqual(colors.textPrimary.resolvedColor(with: lightTraits), Palette.SemanticColor.textPrimary.color.resolvedColor(with: lightTraits))
        XCTAssertEqual(colors.borderError.resolvedColor(with: lightTraits), Palette.SemanticColor.borderError.color.resolvedColor(with: lightTraits))
    }

    func testColorForSemanticColor() {
        let colors = AWXColors()

        // These should be the same object references
        XCTAssertTrue(colors.color(for: .theme) === colors.theme)
        XCTAssertTrue(colors.color(for: .backgroundPrimary) === colors.backgroundPrimary)
        XCTAssertTrue(colors.color(for: .textPrimary) === colors.textPrimary)
        XCTAssertTrue(colors.color(for: .borderError) === colors.borderError)
        XCTAssertTrue(colors.color(for: .iconPrimary) === colors.iconPrimary)
    }

    func testAwxColorUsesCurrentWhenSet() {
        let customColor = UIColor.systemRed
        let colors = AWXColors()
        colors.backgroundPrimary = customColor
        AWXColors.current = colors

        let result = UIColor.awxColor(.backgroundPrimary)
        XCTAssertEqual(result, customColor)
    }

    func testAwxColorFallsBackToPaletteWhenCurrentIsNil() {
        AWXColors.current = nil

        let result = UIColor.awxColor(.backgroundPrimary)
        let expected = Palette.SemanticColor.backgroundPrimary.color
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        XCTAssertEqual(result.resolvedColor(with: lightTraits), expected.resolvedColor(with: lightTraits))
    }

    func testAwxCGColorUsesCurrentWhenSet() {
        let customColor = UIColor.systemBlue
        let colors = AWXColors()
        colors.textPrimary = customColor
        AWXColors.current = colors

        let result = CGColor.awxCGColor(.textPrimary)
        XCTAssertEqual(result, customColor.cgColor)
    }

    func testAwxCGColorFallsBackToPaletteWhenCurrentIsNil() {
        AWXColors.current = nil

        let resultColor = UIColor.awxColor(.textPrimary)
        let expectedColor = Palette.SemanticColor.textPrimary.color
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        XCTAssertEqual(resultColor.resolvedColor(with: lightTraits), expectedColor.resolvedColor(with: lightTraits))
    }

    func testCustomColorsArePreserved() {
        let colors = AWXColors()

        colors.theme = .systemPink
        colors.backgroundPrimary = .systemYellow
        colors.textError = .systemOrange

        XCTAssertEqual(colors.theme, .systemPink)
        XCTAssertEqual(colors.backgroundPrimary, .systemYellow)
        XCTAssertEqual(colors.textError, .systemOrange)
    }

    func testAllSemanticColorsAreMapped() {
        let colors = AWXColors()

        // Test that all semantic colors return the corresponding property (same object reference)
        let allCases: [(Palette.SemanticColor, UIColor)] = [
            (.theme, colors.theme),
            (.backgroundPrimary, colors.backgroundPrimary),
            (.backgroundSecondary, colors.backgroundSecondary),
            (.backgroundField, colors.backgroundField),
            (.backgroundHighlight, colors.backgroundHighlight),
            (.backgroundSelected, colors.backgroundSelected),
            (.backgroundInteractive, colors.backgroundInteractive),
            (.backgroundWarning, colors.backgroundWarning),
            (.borderDecorative, colors.borderDecorative),
            (.borderPerceivable, colors.borderPerceivable),
            (.borderInteractive, colors.borderInteractive),
            (.borderError, colors.borderError),
            (.iconPrimary, colors.iconPrimary),
            (.iconSecondary, colors.iconSecondary),
            (.iconLink, colors.iconLink),
            (.iconDisabled, colors.iconDisabled),
            (.iconWarning, colors.iconWarning),
            (.textLink, colors.textLink),
            (.textPrimary, colors.textPrimary),
            (.textSecondary, colors.textSecondary),
            (.textPlaceholder, colors.textPlaceholder),
            (.textError, colors.textError),
            (.textInverse, colors.textInverse)
        ]

        for (semanticColor, expectedColor) in allCases {
            XCTAssertTrue(colors.color(for: semanticColor) === expectedColor, "Mismatch for \(semanticColor)")
        }
    }
}
