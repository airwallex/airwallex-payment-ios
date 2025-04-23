//
//  CountrySelectionViewModelTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 22/4/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet
import AirwallexCore

class CountrySelectionViewModelTests: XCTestCase {

    private var mockCountry: AWXCountry!
    private let mockIdentifier = "identifier"
    
    override func setUp() {
        super.setUp()
        mockCountry = AWXCountry(code: "SG")
    }
    
    func testInit() {
        let viewModel = CountrySelectionViewModel(
            country: mockCountry,
            handleUserInteraction: {},
            reconfigureHandler: { _,_ in }
        )
        
        XCTAssertEqual(viewModel.fieldName, "country")
        XCTAssertEqual(viewModel.isRequired, true)
        XCTAssertEqual(viewModel.isEnabled, true)
        XCTAssertEqual(viewModel.hideErrorHintLabel, true)
        XCTAssertEqual(viewModel.country?.countryCode, mockCountry.countryCode)
        
        let cellViewModel = CountrySelectionCellViewModel(
            country: mockCountry,
            itemIdentifier: mockIdentifier,
            handleUserInteraction: {},
            cellReconfigureHandler: { _,_ in }
        )
        XCTAssertEqual(cellViewModel.country?.countryCode, mockCountry.countryCode)
        XCTAssertEqual(cellViewModel.itemIdentifier, mockIdentifier)
        XCTAssertEqual(cellViewModel.fieldName, "country")
        XCTAssertEqual(cellViewModel.isRequired, true)
        XCTAssertEqual(cellViewModel.isEnabled, true)
        XCTAssertEqual(cellViewModel.hideErrorHintLabel, false)
    }
    
    func testReconfigureHandler() {
        var handlerCalled: (String, Bool)? = nil
        let cellViewModel = CountrySelectionCellViewModel(
            country: nil,
            itemIdentifier: mockIdentifier,
            handleUserInteraction: {},
            cellReconfigureHandler: { handlerCalled = ($0, $1) }
        )
        
        XCTAssertNil(cellViewModel.country)
        cellViewModel.country = mockCountry
        XCTAssertNotNil(cellViewModel.country)
        XCTAssertEqual(handlerCalled?.0, mockIdentifier)
        XCTAssertEqual(handlerCalled?.1, true)
    }
    
    func testValidate() {
        let cellViewModel = CountrySelectionCellViewModel(
            country: nil,
            itemIdentifier: mockIdentifier,
            handleUserInteraction: {},
            cellReconfigureHandler: { _,_ in }
        )
        
        XCTAssertTrue(cellViewModel.isValid)
        cellViewModel.handleDidEndEditing(reconfigureStrategy: .never)
        XCTAssertFalse(cellViewModel.isValid)
        XCTAssertNotNil(cellViewModel.errorHint)
        
        cellViewModel.country = mockCountry
        XCTAssertTrue(cellViewModel.isValid)
        XCTAssertNil(cellViewModel.errorHint)
    }
}
