//
//  CardInfoCollectorCellViewModelTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 22/4/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet
import AirwallexCore

class CardInfoCollectorCellViewModelTests: XCTestCase {
    
    private var mockCard: AWXCard!
    
    override func setUp() {
        super.setUp()
        mockCard = AWXCard(
            name: "",
            cardNumber: "4012000300000005",
            expiryMonth: "12",
            expiryYear: "2029",
            cvc: "737"
        )
    }
    
    func testReturnActionHandler() {
        let itemIdentifier = "card_info"
        var called = false
        let viewModel = CardInfoCollectorCellViewModel(
            itemIdentifier: itemIdentifier,
            cardSchemes: AWXCardScheme.allAvailable,
            returnActionHandler: { item, responder in
                XCTAssertEqual(item, itemIdentifier)
                called = true
                return false
            },
            reconfigureHandler: { _, _ in },
            cardNumberDidEndEditing: {}
        )
        viewModel.cardNumberConfigurer.text = mockCard.number
        viewModel.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        viewModel.cvcConfigurer.text = mockCard.cvc
        
        let cell = CardInfoCollectorCell()
        cell.setup(viewModel)
        
        guard let numberField = cell.allFields.first as? CardNumberTextField else {
            XCTFail()
            return
        }
        
        numberField.textField.selectedTextRange = numberField.textField.textRange(
            from: numberField.textField.endOfDocument,
            to: numberField.textField.endOfDocument
        )
        let _ = viewModel.cardNumberConfigurer.textField(
            numberField.textField,
            shouldChangeCharactersIn: NSRange(location: mockCard.number.count, length: 0),
            replacementString: "1"
        )
        XCTAssertFalse(called)
        
        guard let expiryField = cell.allFields[1] as? BaseTextField<InfoCollectorTextFieldViewModel> else {
            XCTFail()
            return
        }
        
        expiryField.textField.selectedTextRange = expiryField.textField.textRange(
            from: expiryField.textField.endOfDocument,
            to: expiryField.textField.endOfDocument
        )
        let _ = viewModel.expireDataConfigurer.textField(
            expiryField.textField,
            shouldChangeCharactersIn: NSRange(location: 5, length: 0),
            replacementString: "1"
        )
        XCTAssertFalse(called)
        guard let cvcField = cell.allFields.last as? BaseTextField<InfoCollectorTextFieldViewModel> else {
            XCTFail()
            return
        }
        cvcField.textField.selectedTextRange = cvcField.textField.textRange(
            from: cvcField.textField.endOfDocument,
            to: cvcField.textField.endOfDocument
        )
        let _ = viewModel.cvcConfigurer.textField(
            cvcField.textField,
            shouldChangeCharactersIn: NSRange(location: mockCard.cvc!.count, length: 0),
            replacementString: "1"
        )
        XCTAssertTrue(called)
    }
    
    func testReconfigureHandler() {
        let itemIdentifier = "card_info"
        var handlerCalled: (String, Bool)? = nil
        let viewModel = CardInfoCollectorCellViewModel(
            itemIdentifier: itemIdentifier,
            cardSchemes: AWXCardScheme.allAvailable,
            returnActionHandler: nil,
            reconfigureHandler: { itemIdentifier, updateLayout in
                handlerCalled = (itemIdentifier, updateLayout)
            },
            cardNumberDidEndEditing: {}
        )
        viewModel.cardNumberConfigurer.text = mockCard.number
        viewModel.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        viewModel.cvcConfigurer.text = mockCard.cvc
        
        let cell = CardInfoCollectorCell()
        cell.setup(viewModel)
        
        // card number
        guard let numberField = cell.allFields.first as? CardNumberTextField else {
            XCTFail()
            return
        }
        
        let _ = viewModel.cardNumberConfigurer.textField(
            numberField.textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 1),
            replacementString: "4"
        )
        XCTAssertEqual(handlerCalled?.0, itemIdentifier)
        XCTAssertEqual(handlerCalled?.1, false)
        
        // expire
        guard let expiryField = cell.allFields[1] as? BaseTextField<InfoCollectorTextFieldViewModel> else {
            XCTFail()
            return
        }
        handlerCalled = nil
        let _ = viewModel.expireDataConfigurer.textField(
            expiryField.textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 1),
            replacementString: ""
        )
        XCTAssertNil(handlerCalled)
        viewModel.expireDataConfigurer.handleDidEndEditing(reconfigureStrategy: .automatic)
        XCTAssertEqual(handlerCalled?.0, itemIdentifier)
        XCTAssertEqual(handlerCalled?.1, true)
        
        // cvc
        handlerCalled = nil
        guard let cvcField = cell.allFields.last as? BaseTextField<InfoCollectorTextFieldViewModel> else {
            XCTFail()
            return
        }
        let _ = viewModel.cvcConfigurer.textField(
            cvcField.textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 1),
            replacementString: ""
        )
        XCTAssertNil(handlerCalled)
        viewModel.cvcConfigurer.handleDidEndEditing(reconfigureStrategy: .automatic)
        XCTAssertEqual(handlerCalled?.0, itemIdentifier)
        XCTAssertEqual(handlerCalled?.1, true)
    }
    
    func testUpdateValidStatusForCheckout() {
        let itemIdentifier = "card_info"
        let viewModel = CardInfoCollectorCellViewModel(
            itemIdentifier: itemIdentifier,
            cardSchemes: AWXCardScheme.allAvailable,
            returnActionHandler: nil,
            reconfigureHandler: { _,_ in },
            cardNumberDidEndEditing: {}
        )
        // all empty
        viewModel.updateValidStatusForCheckout()
        XCTAssertNotNil(viewModel.errorHintForCardFields)
        XCTAssertEqual(viewModel.errorHintForCardFields, viewModel.cardNumberConfigurer.errorHint)
        
        // fill with card number
        viewModel.cardNumberConfigurer.text = mockCard.number
        viewModel.updateValidStatusForCheckout()
        XCTAssertNotNil(viewModel.errorHintForCardFields)
        XCTAssertEqual(viewModel.errorHintForCardFields, viewModel.expireDataConfigurer.errorHint)
        
        // fill with expiry
        viewModel.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        viewModel.updateValidStatusForCheckout()
        XCTAssertNotNil(viewModel.errorHintForCardFields)
        XCTAssertEqual(viewModel.errorHintForCardFields, viewModel.cvcConfigurer.errorHint)
        
        // fill cvc
        viewModel.cvcConfigurer.text = mockCard.cvc
        viewModel.updateValidStatusForCheckout()
        XCTAssertNil(viewModel.errorHintForCardFields)
    }
    
    func testValidate() {
        var called = false
        let itemIdentifier = "card_info"
        let viewModel = CardInfoCollectorCellViewModel(
            itemIdentifier: itemIdentifier,
            cardSchemes: AWXCardScheme.allAvailable,
            returnActionHandler: nil,
            reconfigureHandler: { _,_ in
                called = true
            },
            cardNumberDidEndEditing: {}
        )
        
        XCTAssertThrowsError(try viewModel.validate())
        XCTAssertFalse(called)
        
        viewModel.cardNumberConfigurer.text = mockCard.number
        viewModel.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        viewModel.cvcConfigurer.text = mockCard.cvc
        
        XCTAssertNoThrow(try viewModel.validate())
        XCTAssertFalse(called)
    }
    
    func testCardFromCollectedInfo() {
        let itemIdentifier = "card_info"
        let viewModel = CardInfoCollectorCellViewModel(
            itemIdentifier: itemIdentifier,
            cardSchemes: AWXCardScheme.allAvailable,
            returnActionHandler: nil,
            reconfigureHandler: { _,_ in },
            cardNumberDidEndEditing: {}
        )
        
        viewModel.cardNumberConfigurer.text = mockCard.number
        viewModel.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        viewModel.cvcConfigurer.text = mockCard.cvc
        
        let card = viewModel.cardFromCollectedInfo()
        XCTAssertEqual(card.number, mockCard.number)
        XCTAssertEqual(card.expiryMonth, mockCard.expiryMonth)
        XCTAssertEqual(card.expiryYear, mockCard.expiryYear)
        XCTAssertEqual(card.cvc, mockCard.cvc)
    }
}
