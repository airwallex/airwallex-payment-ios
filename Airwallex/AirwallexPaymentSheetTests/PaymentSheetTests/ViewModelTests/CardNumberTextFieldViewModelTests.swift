//
//  CardNumberTextFieldViewModelTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/22.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet
import AirwallexCore

class CardNumberTextFieldViewModelTests: XCTestCase {
    
    func testInit() {
        let viewModel = CardNumberTextFieldViewModel(
            supportedCardSchemes: AWXCardScheme.allAvailable,
            editingEventObserver: BeginEditingEventObserver(block: {}),
            reconfigureHandler: { _,_ in }
        )
        XCTAssertEqual(viewModel.textFieldType, .cardNumber)
        XCTAssertEqual(viewModel.supportedBrands, AWXCardScheme.allAvailable.map { $0.brandType })
        XCTAssertEqual(viewModel.currentBrand, .unknown)
    }
    
    func testSupportedBrandsAndCurrentBrand() {
        let cardSchemes = [AWXCardBrand.unionPay, AWXCardBrand.discover, AWXCardBrand.mastercard]
            .map { AWXCardScheme(name: $0.rawValue) }
        let viewModel = CardNumberTextFieldViewModel(
            supportedCardSchemes: cardSchemes,
            editingEventObserver: BeginEditingEventObserver(block: {}),
            reconfigureHandler: { _,_ in }
        )
        let allPossibleBrands = Set([AWXBrandType.unionPay, AWXBrandType.discover, AWXBrandType.mastercard])
        
        XCTAssertEqual(viewModel.currentBrand, .unknown)
        XCTAssertEqual(Set(viewModel.cardBrands), allPossibleBrands)// all possible candidates
        
        // brand not supported
        let textField = UITextField()
        let _ = viewModel.textField(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "4")
        XCTAssertEqual(viewModel.currentBrand, .unknown)
        XCTAssertEqual(viewModel.cardBrands, [])
        
        // card number with multiple possible brands
        let _ = viewModel.textField(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 1), replacementString: "6")
        XCTAssertEqual(viewModel.currentBrand, .discover)// most specific card
        XCTAssertEqual(Set(viewModel.cardBrands), allPossibleBrands)// all possible candidates
        
        // empty card number
        let _ = viewModel.textField(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 1), replacementString: "")
        XCTAssertEqual(viewModel.currentBrand, .unknown)
        XCTAssertEqual(Set(viewModel.cardBrands), allPossibleBrands)// all possible candidates
    }
}
