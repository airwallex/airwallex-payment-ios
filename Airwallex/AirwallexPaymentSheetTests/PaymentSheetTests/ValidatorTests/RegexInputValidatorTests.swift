//
//  RegexInputValidatorTests.swift
//  PaymentTests
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import XCTest

class RegexInputValidatorTests: XCTestCase {

    /// US ZIP code regex bundled in address.json: `\d{5}(-\d{4})?` (case-insensitive).
    private let zipUS = try! NSRegularExpression(pattern: "^\\d{5}(-\\d{4})?$", options: [.caseInsensitive])

    func testValid_AcceptsMatchingInput() {
        let validator = RegexInputValidator(
            regex: zipUS,
            isRequired: true,
            requiredMessage: "Postcode required",
            invalidMessage: "Invalid postcode"
        )
        XCTAssertNoThrow(try validator.validateUserInput("94110"))
        XCTAssertNoThrow(try validator.validateUserInput("94110-1234"))
    }

    func testValid_InputIsTrimmedBeforeMatching() {
        let validator = RegexInputValidator(
            regex: zipUS,
            isRequired: true,
            requiredMessage: "Postcode required",
            invalidMessage: "Invalid postcode"
        )
        XCTAssertNoThrow(try validator.validateUserInput("  94110  "))
    }

    func testInvalid_NonMatchingInputThrowsInvalidMessage() {
        let validator = RegexInputValidator(
            regex: zipUS,
            isRequired: true,
            requiredMessage: "Postcode required",
            invalidMessage: "Invalid postcode"
        )
        XCTAssertThrowsError(try validator.validateUserInput("abc")) { error in
            XCTAssertEqual(error.localizedDescription, "Invalid postcode")
        }
        XCTAssertThrowsError(try validator.validateUserInput("9411")) { error in
            XCTAssertEqual(error.localizedDescription, "Invalid postcode")
        }
    }

    func testRequired_EmptyOrNilThrowsRequiredMessage() {
        let validator = RegexInputValidator(
            regex: zipUS,
            isRequired: true,
            requiredMessage: "Postcode required",
            invalidMessage: "Invalid postcode"
        )
        for input in [nil, "", "   "] as [String?] {
            XCTAssertThrowsError(try validator.validateUserInput(input)) { error in
                XCTAssertEqual(error.localizedDescription, "Postcode required",
                               "expected required-message for input \(String(describing: input))")
            }
        }
    }

    func testOptional_EmptyInputPasses() {
        // Required = false → empty/nil short-circuits past the regex check.
        let validator = RegexInputValidator(
            regex: zipUS,
            isRequired: false,
            requiredMessage: "Postcode required",
            invalidMessage: "Invalid postcode"
        )
        XCTAssertNoThrow(try validator.validateUserInput(nil))
        XCTAssertNoThrow(try validator.validateUserInput(""))
        XCTAssertNoThrow(try validator.validateUserInput("   "))
        // But non-empty still needs to match the regex.
        XCTAssertThrowsError(try validator.validateUserInput("abc"))
    }

    func testNilRegex_OnlyEnforcesRequired() {
        // Countries without a `zip` rule (e.g. HK has no postcode in fmt anyway, but if we
        // construct a validator without a regex, presence is the only check).
        let validator = RegexInputValidator(
            regex: nil,
            isRequired: true,
            requiredMessage: "Postcode required",
            invalidMessage: "Invalid postcode"
        )
        XCTAssertNoThrow(try validator.validateUserInput("anything"))
        XCTAssertNoThrow(try validator.validateUserInput("123abc"))
        XCTAssertThrowsError(try validator.validateUserInput(nil))
        XCTAssertThrowsError(try validator.validateUserInput(""))
    }

    func testNilRegex_NotRequired_AlwaysPasses() {
        let validator = RegexInputValidator(
            regex: nil,
            isRequired: false,
            requiredMessage: "",
            invalidMessage: ""
        )
        XCTAssertNoThrow(try validator.validateUserInput(nil))
        XCTAssertNoThrow(try validator.validateUserInput(""))
        XCTAssertNoThrow(try validator.validateUserInput("anything"))
    }

    func testCaseInsensitive_MatchesPostcodeWithLetters() {
        // GB postcode regex contains letters; with .caseInsensitive a lowercase form should match.
        let gbPattern = "GIR ?0AA|(?:(?:AB|EC|EH|G|GL|GU|HA)(?:\\d[\\dA-Z]? ?\\d[ABD-HJLN-UW-Z]{2}))"
        let regex = try! NSRegularExpression(pattern: "^\(gbPattern)$", options: [.caseInsensitive])
        let validator = RegexInputValidator(
            regex: regex,
            isRequired: true,
            requiredMessage: "",
            invalidMessage: "Invalid"
        )
        XCTAssertNoThrow(try validator.validateUserInput("EC1Y 8SY"))
        XCTAssertNoThrow(try validator.validateUserInput("ec1y 8sy"))
    }
}
