//
//  SubdivisionSelectionViewModelTests.swift
//  AirwallexPaymentSheetTests
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import UIKit
import XCTest

class SubdivisionSelectionViewModelTests: XCTestCase {

    private let options = [
        SubdivisionOption(value: "NSW", label: "New South Wales"),
        SubdivisionOption(value: "VIC", label: "Victoria"),
        SubdivisionOption(value: "QLD", label: "Queensland"),
    ]

    func testInit_DefaultsAndPlaceholder() {
        let viewModel = SubdivisionSelectionViewModel(
            options: options,
            selection: nil,
            placeholder: "State",
            handleUserInteraction: {},
            reconfigureHandler: { _, _ in }
        )
        XCTAssertEqual(viewModel.fieldName, "state")
        XCTAssertEqual(viewModel.placeholder, "State")
        XCTAssertEqual(viewModel.isRequired, true)
        XCTAssertEqual(viewModel.isEnabled, true)
        XCTAssertEqual(viewModel.hideErrorHintLabel, true)
        XCTAssertNil(viewModel.selection)
        XCTAssertNil(viewModel.text)
        XCTAssertNil(viewModel.icon, "Subdivision dropdown has no leading icon")
        XCTAssertNotNil(viewModel.indicator, "Should show the chevron indicator")
    }

    func testInit_WithPrefilledSelection_PopulatesText() {
        let viewModel = SubdivisionSelectionViewModel(
            options: options,
            selection: options[0],
            placeholder: nil,
            handleUserInteraction: {},
            reconfigureHandler: { _, _ in }
        )
        XCTAssertEqual(viewModel.selection?.value, "NSW")
        // text is the selection label wrapped in a Left-to-Right Isolate (U+2066) so the
        // underlying UITextField doesn't right-align bilingual labels.
        XCTAssertEqual(viewModel.text, "\u{2066}New South Wales")
    }

    func testSelectionDidSet_UpdatesTextAndFiresReconfigure() {
        var reconfigureCount = 0
        var lastRefresh: Bool?
        let viewModel = SubdivisionSelectionViewModel(
            options: options,
            selection: nil,
            placeholder: "State",
            handleUserInteraction: {},
            reconfigureHandler: { _, refresh in
                reconfigureCount += 1
                lastRefresh = refresh
            }
        )

        viewModel.selection = options[1]
        XCTAssertEqual(viewModel.text, "\u{2066}Victoria")
        XCTAssertEqual(reconfigureCount, 1, "Setting a selection should fire reconfigureHandler once via handleDidEndEditing(.always)")
        XCTAssertEqual(lastRefresh, true)

        viewModel.selection = nil
        XCTAssertNil(viewModel.text)
        XCTAssertEqual(reconfigureCount, 2)
    }

    func testText_WrapsBilingualLabelInLeftToRightIsolate() {
        // AE's labels start with Arabic ("أبو ظبي — Abu Dhabi"). Without the LRI prefix,
        // UITextField's bidi engine would right-align the field. The wrapped form keeps the
        // base writing direction LTR regardless of leading char.
        let bilingual = SubdivisionOption(value: "أبو ظبي", label: "أبو ظبي — Abu Dhabi")
        let viewModel = SubdivisionSelectionViewModel(
            options: [bilingual],
            selection: bilingual,
            placeholder: nil,
            handleUserInteraction: {},
            reconfigureHandler: { _, _ in }
        )
        XCTAssertEqual(viewModel.text?.first, "\u{2066}", "first scalar must be the LRI marker")
        XCTAssertEqual(viewModel.text, "\u{2066}\(bilingual.label)")
    }

    func testValidate_NilSelectionFails_NonNilPasses() {
        let viewModel = SubdivisionSelectionViewModel(
            options: options,
            selection: nil,
            placeholder: nil,
            handleUserInteraction: {},
            reconfigureHandler: { _, _ in }
        )

        XCTAssertThrowsError(try viewModel.validate())

        viewModel.selection = options[0]
        XCTAssertNoThrow(try viewModel.validate())
    }

    func testIsValid_FlippedByHandleDidEndEditing() {
        let viewModel = SubdivisionSelectionViewModel(
            options: options,
            selection: nil,
            placeholder: nil,
            handleUserInteraction: {},
            reconfigureHandler: { _, _ in }
        )
        // Default state — not yet validated.
        XCTAssertTrue(viewModel.isValid)

        viewModel.handleDidEndEditing(reconfigureStrategy: .never)
        XCTAssertFalse(viewModel.isValid)
        XCTAssertNotNil(viewModel.errorHint)
    }

    func testHandleUserInteraction_InvokedByCaller() {
        var fired = 0
        let viewModel = SubdivisionSelectionViewModel(
            options: options,
            selection: nil,
            placeholder: nil,
            handleUserInteraction: { fired += 1 },
            reconfigureHandler: { _, _ in }
        )
        viewModel.handleUserInteraction()
        XCTAssertEqual(fired, 1)
    }

    func testIndicator_RespondsToIsEnabled() {
        // Indicator image is the down chevron tinted differently when disabled. We can't compare
        // pixels easily, but both branches should produce a non-nil image.
        let enabled = SubdivisionSelectionViewModel(
            options: options,
            selection: nil,
            placeholder: nil,
            isEnabled: true,
            handleUserInteraction: {},
            reconfigureHandler: { _, _ in }
        )
        let disabled = SubdivisionSelectionViewModel(
            options: options,
            selection: nil,
            placeholder: nil,
            isEnabled: false,
            handleUserInteraction: {},
            reconfigureHandler: { _, _ in }
        )
        XCTAssertNotNil(enabled.indicator)
        XCTAssertNotNil(disabled.indicator)
    }

}
