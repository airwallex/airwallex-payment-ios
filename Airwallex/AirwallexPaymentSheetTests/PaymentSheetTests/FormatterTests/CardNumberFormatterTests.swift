//
//  CardNumberFormatterTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/4/1.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import AirwallexCore

class CardNumberFormatterTests: XCTestCase {
    
    private let mockVisaCardNumber = "4242424242424242"
    private var mockTextField: UITextField!
    private var formatter: CardNumberFormatter!
    
    override func setUp() {
        super.setUp()
        mockTextField = UITextField()
        formatter = CardNumberFormatter()
    }
    
    func testAutomaticTriggerReturnAction_WhenTextFieldAtEnd() {
        var attributedString = formatter.formatUserInput(
            mockTextField,
            changeCharactersIn: "".startIndex..<"".endIndex,
            replacementString: String(mockVisaCardNumber.prefix(5))
        )
        mockTextField.updateContentAndCursor(attributedText: attributedString)
        XCTAssertFalse(formatter.shouldAutomaticTriggerReturnAction(textField: mockTextField))
        
        attributedString = formatter.formatUserInput(
            mockTextField,
            changeCharactersIn: attributedString.string.endIndex..<attributedString.string.endIndex,
            replacementString: String(mockVisaCardNumber.dropFirst(5))
        )
        mockTextField.updateContentAndCursor(attributedText: attributedString)
        XCTAssertTrue(formatter.shouldAutomaticTriggerReturnAction(textField: mockTextField))
    }
    
    func testAutomaticTriggerReturnAction_notAtEnd() {
        mockTextField.text = String(mockVisaCardNumber.dropFirst(5))
        mockTextField.selectedTextRange = mockTextField.textRange(
            from: mockTextField.beginningOfDocument,
            to: mockTextField.beginningOfDocument
        )
        let attributedString = formatter.formatUserInput(
            mockTextField,
            changeCharactersIn: "".startIndex..<"".endIndex,
            replacementString: String(mockVisaCardNumber.prefix(5))
        )
        mockTextField.updateContentAndCursor(attributedText: attributedString)
        XCTAssertFalse(formatter.shouldAutomaticTriggerReturnAction(textField: mockTextField))
    }
    
    func testMaxLengthAndCurrentBrandForVisa() {
        _ = formatter.formatUserInput(
            mockTextField,
            changeCharactersIn: "".startIndex..<"".endIndex,
            replacementString: mockVisaCardNumber
        )
        XCTAssertEqual(formatter.currentBrand, .visa)
        XCTAssertEqual(formatter.maxLength, AWXCardValidator.shared().maxLength(forCardNumber: mockVisaCardNumber))
    }
    
    func testMaxLengthAndCurrentBrandForAmex() {
        let amexCardNumber = "378282246310005"
        _ = formatter.formatUserInput(
            mockTextField,
            changeCharactersIn: "".startIndex..<"".endIndex,
            replacementString: amexCardNumber
        )
        XCTAssertEqual(formatter.currentBrand, .amex)
        XCTAssertEqual(formatter.maxLength, AWXCardValidator.shared().maxLength(forCardNumber: amexCardNumber))
    }
    
    func testFormatCardNumberLongerThanMaxLength() {
        let longCardNumber = mockVisaCardNumber + "1234"
        let attributedString = formatter.formatUserInput(
            mockTextField,
            changeCharactersIn: "".startIndex..<"".endIndex,
            replacementString: longCardNumber
        )
        mockTextField.updateContentAndCursor(attributedText: attributedString)
        XCTAssertEqual(attributedString.string, String(longCardNumber.prefix(formatter.maxLength)))
        
        XCTAssertTrue(formatter.shouldAutomaticTriggerReturnAction(textField: mockTextField))
    }
    
    func testKernForVisaCardNumber() {
        let formattedString = formatter.formatUserInput(
            mockTextField,
            changeCharactersIn: "".startIndex..<"".endIndex,
            replacementString: mockVisaCardNumber
        )
        
        let format = AWXCardValidator.cardNumberFormat(for: .visa)
        mockTextField.updateContentAndCursor(attributedText: formattedString)
        _ = format.reduce(-1) { partialResult, number in
            let position = partialResult + number.intValue
            if position < formattedString.length - 1 {
                let attributes = formattedString.attributes(at: position, effectiveRange: nil)
                let kernValue = attributes[.kern] as? CGFloat
                
                XCTAssertNotNil(kernValue)
                XCTAssertEqual(kernValue, 5) // Assuming a kern value of 4.0 is expected
            }
            return position
        }
    }
    
    func testKernForAmexCardNumber() {
        let formattedString = formatter.formatUserInput(
            mockTextField,
            changeCharactersIn: "".startIndex..<"".endIndex,
            replacementString: "378282246310005"
        )
        
        let format = AWXCardValidator.cardNumberFormat(for: .amex)
        mockTextField.updateContentAndCursor(attributedText: formattedString)
        _ = format.reduce(-1) { partialResult, number in
            let position = partialResult + number.intValue
            if position < formattedString.length - 1 {
                let attributes = formattedString.attributes(at: position, effectiveRange: nil)
                let kernValue = attributes[.kern] as? CGFloat
                
                XCTAssertNotNil(kernValue)
                XCTAssertEqual(kernValue, 5) // Assuming a kern value of 4.0 is expected
            }
            return position
        }
    }
    
    func testKernForDinersClubCardNumber() {
        let formattedString = formatter.formatUserInput(
            mockTextField,
            changeCharactersIn: "".startIndex..<"".endIndex,
            replacementString: "3056_930009_020004000"
        )
        
        let format = AWXCardValidator.cardNumberFormat(for: .dinersClub)
        mockTextField.updateContentAndCursor(attributedText: formattedString)
        _ = format.reduce(-1) { partialResult, number in
            let position = partialResult + number.intValue
            if position < formattedString.length - 1 {
                let attributes = formattedString.attributes(at: position, effectiveRange: nil)
                let kernValue = attributes[.kern] as? CGFloat
                
                XCTAssertNotNil(kernValue)
                XCTAssertEqual(kernValue, 5) // Assuming a kern value of 4.0 is expected
            }
            return position
        }
    }
}
