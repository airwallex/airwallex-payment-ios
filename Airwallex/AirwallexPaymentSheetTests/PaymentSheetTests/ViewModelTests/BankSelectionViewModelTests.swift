//
//  BankSelectionViewModelTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 23/4/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet
import AirwallexCore

class BankSelectionViewModelTests: XCTestCase {

    private var mockBank: AWXBank!
    private let mockIdentifier = "identifier"
    
    override func setUp() {
        super.setUp()
        mockBank = AWXBank()
        mockBank.name = "bank"
        mockBank.displayName = "Mock Bank"
        mockBank.resources = AWXResources()
    }
    
    func testInit() {
        let viewModel = BankSelectionViewModel(
            bank: mockBank,
            handleUserInteraction: {},
            reconfigureHandler: { _,_ in }
        )
        
        XCTAssertEqual(viewModel.fieldName, AWXField.Name.bankName)
        XCTAssertEqual(viewModel.isRequired, true)
        XCTAssertEqual(viewModel.isEnabled, true)
        XCTAssertEqual(viewModel.hideErrorHintLabel, false)
        XCTAssertEqual(viewModel.bank?.name, mockBank.name)
        
        let cellViewModel = BankSelectionCellViewModel(
            bank: mockBank,
            itemIdentifier: mockIdentifier,
            handleUserInteraction: {},
            cellReconfigureHandler: { _,_ in }
        )
        XCTAssertEqual(cellViewModel.bank?.name, mockBank.name)
        XCTAssertEqual(cellViewModel.itemIdentifier, mockIdentifier)
        XCTAssertEqual(cellViewModel.fieldName, AWXField.Name.bankName)
        XCTAssertEqual(cellViewModel.isRequired, true)
        XCTAssertEqual(cellViewModel.isEnabled, true)
        XCTAssertEqual(cellViewModel.hideErrorHintLabel, false)
    }
    
    func testReconfigureHandler() {
        var handlerCalled: (String, Bool)? = nil
        let cellViewModel = BankSelectionCellViewModel(
            bank: nil,
            itemIdentifier: mockIdentifier,
            handleUserInteraction: {},
            cellReconfigureHandler: { handlerCalled = ($0, $1) }
        )
        
        XCTAssertNil(cellViewModel.bank)
        cellViewModel.bank = mockBank
        XCTAssertNotNil(cellViewModel.bank)
        XCTAssertEqual(handlerCalled?.0, mockIdentifier)
        XCTAssertEqual(handlerCalled?.1, true)
    }
    
    func testValidate() {
        let cellViewModel = BankSelectionCellViewModel(
            bank: nil,
            itemIdentifier: mockIdentifier,
            handleUserInteraction: {},
            cellReconfigureHandler: { _,_ in }
        )
        
        XCTAssertTrue(cellViewModel.isValid)
        cellViewModel.handleDidEndEditing(reconfigurePolicy: .never)
        XCTAssertFalse(cellViewModel.isValid)
        XCTAssertNotNil(cellViewModel.errorHint)
        
        cellViewModel.bank = mockBank
        XCTAssertTrue(cellViewModel.isValid)
        XCTAssertNil(cellViewModel.errorHint)
    }
}
