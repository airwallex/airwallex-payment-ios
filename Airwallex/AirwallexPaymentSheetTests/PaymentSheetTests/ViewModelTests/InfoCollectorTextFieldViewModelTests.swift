//
//  InfoCollectorTextFieldViewModelTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet
@_spi(AWX) import AirwallexPayment

class InfoCollectorTextFieldViewModelTests: XCTestCase {

    let mockReconfigureHandler: InfoCollectorTextFieldViewModel.ReconfigureHandler = { _, _ in }
    let mockReturnActionHandler: InfoCollectorTextFieldViewModel.ReturnActionHandler = { _ in true }

    func testInitialization() {
        let attributedText = NSAttributedString(string: "Attributed Text")
        let viewModel = InfoCollectorTextFieldViewModel(
            fieldName: "TestField",
            textFieldType: .default,
            title: "Test Title",
            text: "Test Text",
            attributedText: attributedText,
            placeholder: "Enter text",
            errorHint: "Error Hint",
            isRequired: false,
            isEnabled: false,
            isValid: false,
            hideErrorHintLabel: true,
            clearButtonMode: .whileEditing,
            returnKeyType: .done,
            returnActionHandler: mockReturnActionHandler,
            customInputFormatter: MaxLengthFormatter(maxLength: 1),
            customInputValidator: nil,
            editingEventObserver: BeginEditingEventObserver {},
            reconfigureHandler: mockReconfigureHandler
        )
        
        XCTAssertEqual(viewModel.fieldName, "TestField")
        XCTAssertEqual(viewModel.textFieldType, .default)
        XCTAssertEqual(viewModel.title, "Test Title")
        XCTAssertNotEqual(viewModel.text, "Test Text")
        // if you pass text and attributedText at the same time, text will be ignored
        XCTAssertEqual(viewModel.text, attributedText.string)
        XCTAssertEqual(viewModel.attributedText, attributedText)
        XCTAssertEqual(viewModel.placeholder, "Enter text")
        XCTAssertEqual(viewModel.errorHint, "Error Hint")
        XCTAssertFalse(viewModel.isRequired)
        XCTAssertFalse(viewModel.isEnabled)
        XCTAssertFalse(viewModel.isValid)
        XCTAssertTrue(viewModel.hideErrorHintLabel)
        XCTAssertEqual(viewModel.clearButtonMode, .whileEditing)
        XCTAssertEqual(viewModel.returnKeyType, .done)
        XCTAssertNotNil(viewModel.returnActionHandler)
        XCTAssert(viewModel.inputFormatter is MaxLengthFormatter)
        XCTAssert(viewModel.inputValidator is InfoCollectorDefaultValidator)
        XCTAssertNotNil(viewModel.reconfigureHandler)
        XCTAssert(viewModel.editingEventObserver is BeginEditingEventObserver)
    }
    
    func testValidate_RequiredField() {
        let viewModel = InfoCollectorTextFieldViewModel(
            fieldName: "TestField",
            isRequired: true,
            reconfigureHandler: mockReconfigureHandler
        )
        
        viewModel.handleDidEndEditing(reconfigurePolicy: .never)
        XCTAssertFalse(viewModel.isValid)
        XCTAssertNotNil(viewModel.errorHint)
        XCTAssertThrowsError(try viewModel.validate())
        
        viewModel.text = "foo"
        viewModel.handleDidEndEditing(reconfigurePolicy: .never)
        XCTAssertTrue(viewModel.isValid)
        XCTAssertNil(viewModel.errorHint)
        XCTAssertNoThrow(try viewModel.validate())
    }
    
    func testCustomValidator() {
        // setup
        let errorMessage = "error"
        let viewModel = InfoCollectorTextFieldViewModel(
            customInputValidator: BlockValidator { input in
                throw errorMessage.asError()
            },
            reconfigureHandler: mockReconfigureHandler
        )
        XCTAssert(viewModel.inputValidator is BlockValidator)
        XCTAssertTrue(viewModel.isValid)
        XCTAssertNil(viewModel.errorHint)
        // action
        XCTAssertThrowsError(try viewModel.validate())
        viewModel.handleDidEndEditing(reconfigurePolicy: .never)
        // assertion
        XCTAssertFalse(viewModel.isValid)
        XCTAssertEqual(viewModel.errorHint, errorMessage)
    }

    func testTextFormatting() {
        let mockFormatter = MaxLengthFormatter(maxLength: 10, characterSet: .decimalDigits)
        let reconfigureHandler: InfoCollectorTextFieldViewModel.ReconfigureHandler = { _, _ in }
        let viewModel = InfoCollectorTextFieldViewModel(
            customInputFormatter: mockFormatter,
            reconfigureHandler: reconfigureHandler
        )
        
        let textField = UITextField()
        textField.text = "123"
        let shouldChange = viewModel.textField(
            textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 3),
            replacementString: "456"
        )
        
        XCTAssertFalse(shouldChange)
        XCTAssertEqual(textField.attributedText?.string, "456")
        let _ = viewModel.textField(
            textField,
            shouldChangeCharactersIn: NSRange(location: 3, length: 0),
            replacementString: "789abc"
        )
        XCTAssertEqual(textField.attributedText?.string, "456789")
    }

    func testReconfigureHandlerCalledWhenEndEditing() {
        var reconfigureCalled = false
        let reconfigureHandler: InfoCollectorTextFieldViewModel.ReconfigureHandler = { _, _ in
            reconfigureCalled = true
        }
        let viewModel = InfoCollectorTextFieldViewModel(
            fieldName: "TestField",
            reconfigureHandler: reconfigureHandler
        )
        
        let textField = UITextField()
        viewModel.textFieldDidEndEditing(textField)
        
        XCTAssertTrue(reconfigureCalled, "Reconfigure handler should be called when editing ends.")
    }
    
    func testReconfigurePolicy_never() {
        var reconfigureCalled = false
        let reconfigureHandler: InfoCollectorTextFieldViewModel.ReconfigureHandler = { _, _ in
            reconfigureCalled = true
        }
        let viewModel = InfoCollectorTextFieldViewModel(
            reconfigureHandler: reconfigureHandler
        )
        XCTAssertTrue(viewModel.isValid)
        viewModel.handleDidEndEditing(reconfigurePolicy: .never)
        XCTAssertFalse(viewModel.isValid)
        XCTAssertFalse(reconfigureCalled)
        
        reconfigureCalled = false
        viewModel.handleDidEndEditing(reconfigurePolicy: .never)
        XCTAssertFalse(viewModel.isValid)
        XCTAssertFalse(reconfigureCalled)
        
        reconfigureCalled = false
        viewModel.text = "text"
        viewModel.handleDidEndEditing(reconfigurePolicy: .never)
        XCTAssertTrue(viewModel.isValid)
        XCTAssertFalse(reconfigureCalled)
    }
    
    func testReconfigurePolicy_always() {
        var reconfigureCalled = false
        let reconfigureHandler: InfoCollectorTextFieldViewModel.ReconfigureHandler = { _, _ in
            reconfigureCalled = true
        }
        let viewModel = InfoCollectorTextFieldViewModel(
            reconfigureHandler: reconfigureHandler
        )
        XCTAssertTrue(viewModel.isValid)
        viewModel.handleDidEndEditing(reconfigurePolicy: .always)
        XCTAssertFalse(viewModel.isValid)
        XCTAssertTrue(reconfigureCalled)
        
        reconfigureCalled = false
        viewModel.handleDidEndEditing(reconfigurePolicy: .always)
        XCTAssertFalse(viewModel.isValid)
        XCTAssertTrue(reconfigureCalled)
        
        reconfigureCalled = false
        viewModel.text = "text"
        viewModel.handleDidEndEditing(reconfigurePolicy: .always)
        XCTAssertTrue(viewModel.isValid)
        XCTAssertTrue(reconfigureCalled)
    }
    
    func testReconfigurePolicy_ifNeeded() {
        var reconfigureCalled = false
        let reconfigureHandler: InfoCollectorTextFieldViewModel.ReconfigureHandler = { _, _ in
            reconfigureCalled = true
        }
        let viewModel = InfoCollectorTextFieldViewModel(
            reconfigureHandler: reconfigureHandler
        )
        XCTAssertTrue(viewModel.isValid)
        viewModel.handleDidEndEditing(reconfigurePolicy: .ifNeeded)
        XCTAssertFalse(viewModel.isValid)
        XCTAssertTrue(reconfigureCalled)
        
        reconfigureCalled = false
        viewModel.handleDidEndEditing(reconfigurePolicy: .ifNeeded)
        XCTAssertFalse(viewModel.isValid)
        XCTAssertFalse(reconfigureCalled)
        
        reconfigureCalled = false
        viewModel.text = "text"
        viewModel.handleDidEndEditing(reconfigurePolicy: .ifNeeded)
        XCTAssertTrue(viewModel.isValid)
        XCTAssertTrue(reconfigureCalled)
    }
    
    func testConvenienceInit() {
        let reconfigureHandler: InfoCollectorTextFieldViewModel.ReconfigureHandler = { _, _ in }
        let viewModel = InfoCollectorTextFieldViewModel(
            cvcValidator: CardCVCValidator(maxLength: 16),
            editingEventObserver: BeginEditingEventObserver {},
            reconfigureHandler: reconfigureHandler
        )
        XCTAssert(viewModel.inputValidator is CardCVCValidator)
        XCTAssert(viewModel.inputFormatter is CardCVCValidator)
        XCTAssert(viewModel.editingEventObserver is BeginEditingEventObserver)
        XCTAssertEqual(viewModel.textFieldType, .CVC)
        XCTAssertEqual(viewModel.placeholder, NSLocalizedString("CVC", bundle: .paymentSheet, comment: ""))
    }
}
