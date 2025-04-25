//
//  BillingInfoCellViewModelTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 23/4/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet
import AirwallexCore

class BillingInfoCellViewModelTests: XCTestCase {
    
    private var mockIdentifier = "identifier"
    private var mockAddress: AWXAddress!
    
    override func setUp() {
        super.setUp()
        mockAddress = AWXAddress()
        mockAddress.countryCode = "AU"
        mockAddress.state = "state"
        mockAddress.city = "city"
        mockAddress.street = "street"
        mockAddress.postcode = "123abc"
    }
    
    func testInit_WithAddress() {
        var viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: mockAddress,
            reusePrefilledAddress: true,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: {_,_ in}
        )
        XCTAssertEqual(viewModel.itemIdentifier, mockIdentifier)
        XCTAssertEqual(viewModel.canReusePrefilledAddress, true)
        XCTAssertEqual(viewModel.shouldReusePrefilledAddress, true)
        XCTAssertEqual(viewModel.countryConfigurer.country?.countryCode, mockAddress.countryCode)
        XCTAssertEqual(viewModel.stateConfigurer.text, mockAddress.state)
        XCTAssertEqual(viewModel.cityConfigurer.text, mockAddress.city)
        XCTAssertEqual(viewModel.streetConfigurer.text, mockAddress.street)
        XCTAssertEqual(viewModel.zipConfigurer.text, mockAddress.postcode)
        XCTAssertNil(viewModel.errorHintForBillingFields)
        
        viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: mockAddress,
            reusePrefilledAddress: false,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: {_,_ in}
        )
        XCTAssertEqual(viewModel.itemIdentifier, mockIdentifier)
        XCTAssertEqual(viewModel.canReusePrefilledAddress, true)
        XCTAssertEqual(viewModel.shouldReusePrefilledAddress, false)
        XCTAssertEqual(viewModel.countryConfigurer.country?.countryCode, mockAddress.countryCode)
        XCTAssertEqual(viewModel.stateConfigurer.text, mockAddress.state)
        XCTAssertEqual(viewModel.cityConfigurer.text, mockAddress.city)
        XCTAssertEqual(viewModel.streetConfigurer.text, mockAddress.street)
        XCTAssertEqual(viewModel.zipConfigurer.text, mockAddress.postcode)
        XCTAssertNil(viewModel.errorHintForBillingFields)
    }
    
    func testInit_WithoutAddress() {
        var viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: nil,
            reusePrefilledAddress: true,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: {_,_ in}
        )
        XCTAssertEqual(viewModel.itemIdentifier, mockIdentifier)
        XCTAssertEqual(viewModel.canReusePrefilledAddress, false)
        XCTAssertEqual(viewModel.shouldReusePrefilledAddress, false)
        XCTAssertNil(viewModel.countryConfigurer.country?.countryCode)
        XCTAssertNil(viewModel.stateConfigurer.text)
        XCTAssertNil(viewModel.cityConfigurer.text)
        XCTAssertNil(viewModel.streetConfigurer.text)
        XCTAssertNil(viewModel.zipConfigurer.text)
        XCTAssertNil(viewModel.errorHintForBillingFields)
        
        viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: nil,
            reusePrefilledAddress: false,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: {_,_ in}
        )
        XCTAssertEqual(viewModel.itemIdentifier, mockIdentifier)
        XCTAssertEqual(viewModel.canReusePrefilledAddress, false)
        XCTAssertEqual(viewModel.shouldReusePrefilledAddress, false)
        XCTAssertNil(viewModel.countryConfigurer.country?.countryCode)
        XCTAssertNil(viewModel.stateConfigurer.text)
        XCTAssertNil(viewModel.cityConfigurer.text)
        XCTAssertNil(viewModel.streetConfigurer.text)
        XCTAssertNil(viewModel.zipConfigurer.text)
        XCTAssertNil(viewModel.errorHintForBillingFields)
    }
    
    func testInit_IncompleteAddress() {
        mockAddress.countryCode = nil
        var viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: mockAddress,
            reusePrefilledAddress: true,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: {_,_ in}
        )
        XCTAssertEqual(viewModel.itemIdentifier, mockIdentifier)
        XCTAssertEqual(viewModel.canReusePrefilledAddress, false)
        XCTAssertEqual(viewModel.shouldReusePrefilledAddress, false)
        XCTAssertEqual(viewModel.countryConfigurer.country?.countryCode, mockAddress.countryCode)
        XCTAssertEqual(viewModel.stateConfigurer.text, mockAddress.state)
        XCTAssertEqual(viewModel.cityConfigurer.text, mockAddress.city)
        XCTAssertEqual(viewModel.streetConfigurer.text, mockAddress.street)
        XCTAssertEqual(viewModel.zipConfigurer.text, mockAddress.postcode)
        XCTAssertNil(viewModel.errorHintForBillingFields)
        
        viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: mockAddress,
            reusePrefilledAddress: false,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: {_,_ in}
        )
        XCTAssertEqual(viewModel.itemIdentifier, mockIdentifier)
        XCTAssertEqual(viewModel.canReusePrefilledAddress, false)
        XCTAssertEqual(viewModel.shouldReusePrefilledAddress, false)
        XCTAssertEqual(viewModel.countryConfigurer.country?.countryCode, mockAddress.countryCode)
        XCTAssertEqual(viewModel.stateConfigurer.text, mockAddress.state)
        XCTAssertEqual(viewModel.cityConfigurer.text, mockAddress.city)
        XCTAssertEqual(viewModel.streetConfigurer.text, mockAddress.street)
        XCTAssertEqual(viewModel.zipConfigurer.text, mockAddress.postcode)
        XCTAssertNil(viewModel.errorHintForBillingFields)
    }
    
    func testBillingAddressFromCollectedInfo() {
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: mockAddress,
            reusePrefilledAddress: true,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: {_,_ in}
        )
        
        let address = viewModel.billingAddressFromCollectedInfo()
        XCTAssertEqual(mockAddress.countryCode, address.countryCode)
        XCTAssertEqual(mockAddress.state, address.state)
        XCTAssertEqual(mockAddress.city, address.city)
        XCTAssertEqual(mockAddress.street, address.street)
        XCTAssertEqual(mockAddress.postcode, address.postcode)
    }
    
    func testUpdateValidStatusForCheckout() {
        mockAddress.countryCode = nil
        mockAddress.postcode = nil
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: mockAddress,
            reusePrefilledAddress: true,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: {_,_ in}
        )
        viewModel.updateValidStatusForCheckout()
        XCTAssertFalse(viewModel.countryConfigurer.isValid)
        XCTAssertTrue(viewModel.stateConfigurer.isValid)
        XCTAssertTrue(viewModel.cityConfigurer.isValid)
        XCTAssertTrue(viewModel.streetConfigurer.isValid)
        XCTAssertFalse(viewModel.zipConfigurer.isValid)
        XCTAssertEqual(viewModel.errorHintForBillingFields, viewModel.countryConfigurer.errorHint)
        
        let country = AWXCountry()
        country.countryCode = "AU"
        viewModel.selectedCountry = country
        viewModel.updateValidStatusForCheckout()
        
        XCTAssertTrue(viewModel.countryConfigurer.isValid)
        XCTAssertFalse(viewModel.zipConfigurer.isValid)
        XCTAssertEqual(viewModel.errorHintForBillingFields, viewModel.zipConfigurer.errorHint)
        
        viewModel.zipConfigurer.text = "1234"
        viewModel.updateValidStatusForCheckout()
        XCTAssertTrue(viewModel.zipConfigurer.isValid)
        XCTAssertNil(viewModel.errorHintForBillingFields)
    }
    
    func testValidate() {
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: mockAddress,
            reusePrefilledAddress: true,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: {_,_ in}
        )
        XCTAssertNoThrow(try viewModel.validate())
        
        viewModel.selectedCountry = nil
        XCTAssertThrowsError(try viewModel.validate())
    }
}
