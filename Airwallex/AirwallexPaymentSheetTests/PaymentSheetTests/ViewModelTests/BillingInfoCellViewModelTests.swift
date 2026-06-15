//
//  BillingInfoCellViewModelTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 23/4/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import UIKit
import XCTest

class BillingInfoCellViewModelTests: XCTestCase {

    private var mockIdentifier = "identifier"
    private var mockAddress: AWXAddress!

    override func setUp() {
        super.setUp()
        // Use a valid AU address that satisfies the country rule end-to-end:
        // - AU is a dropdown-state country (sub_keys ACT/NSW/NT/QLD/SA/TAS/VIC/WA),
        //   so the state must be one of those keys (or their labels).
        // - AU postcode is 4 digits.
        mockAddress = AWXAddress()
        mockAddress.countryCode = "AU"
        mockAddress.state = "NSW"
        mockAddress.city = "city"
        mockAddress.street = "street"
        mockAddress.postcode = "2060"
    }

    func testInit_WithAddress() {
        var viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: mockAddress,
            reusePrefilledAddress: true,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )
        XCTAssertEqual(viewModel.itemIdentifier, mockIdentifier)
        XCTAssertEqual(viewModel.canReusePrefilledAddress, true)
        XCTAssertEqual(viewModel.shouldReusePrefilledAddress, true)
        XCTAssertEqual(viewModel.countryConfigurer.country?.countryCode, mockAddress.countryCode)
        // AU has sub_keys, so the state row is a dropdown; the prefilled "NSW" pre-selects it
        // via `option(matching:)`, so the dropdown VM's selection.value mirrors the prefill.
        XCTAssertEqual(viewModel.stateDropdownConfigurer?.selection?.value, mockAddress.state)
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
            cellReconfigureHandler: { _, _ in }
        )
        XCTAssertEqual(viewModel.itemIdentifier, mockIdentifier)
        XCTAssertEqual(viewModel.canReusePrefilledAddress, true)
        XCTAssertEqual(viewModel.shouldReusePrefilledAddress, false)
        XCTAssertEqual(viewModel.countryConfigurer.country?.countryCode, mockAddress.countryCode)
        XCTAssertEqual(viewModel.stateDropdownConfigurer?.selection?.value, mockAddress.state)
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
            cellReconfigureHandler: { _, _ in }
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
            cellReconfigureHandler: { _, _ in }
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

    func testInit_WithDefaultCountryCode() {
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: nil,
            defaultCountryCode: "US",
            reusePrefilledAddress: false,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )
        XCTAssertEqual(viewModel.itemIdentifier, mockIdentifier)
        XCTAssertEqual(viewModel.canReusePrefilledAddress, false)
        XCTAssertEqual(viewModel.shouldReusePrefilledAddress, false)
        XCTAssertEqual(viewModel.countryConfigurer.country?.countryCode, "US")
        XCTAssertNil(viewModel.stateConfigurer.text)
        XCTAssertNil(viewModel.cityConfigurer.text)
        XCTAssertNil(viewModel.streetConfigurer.text)
        XCTAssertNil(viewModel.zipConfigurer.text)
        XCTAssertNil(viewModel.errorHintForBillingFields)
    }

    func testInit_DefaultCountryCode_OverriddenByAddress() {
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: mockAddress,
            defaultCountryCode: "US",
            reusePrefilledAddress: true,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )
        XCTAssertEqual(viewModel.itemIdentifier, mockIdentifier)
        XCTAssertEqual(viewModel.canReusePrefilledAddress, true)
        XCTAssertEqual(viewModel.shouldReusePrefilledAddress, true)
        XCTAssertEqual(viewModel.countryConfigurer.country?.countryCode, "AU")
        XCTAssertEqual(viewModel.stateDropdownConfigurer?.selection?.value, mockAddress.state)
        XCTAssertEqual(viewModel.cityConfigurer.text, mockAddress.city)
        XCTAssertEqual(viewModel.streetConfigurer.text, mockAddress.street)
        XCTAssertEqual(viewModel.zipConfigurer.text, mockAddress.postcode)
        XCTAssertNil(viewModel.errorHintForBillingFields)
    }

    func testInit_IncompleteAddress() {
        // Missing countryCode: the address can't be matched to a rule, so `isValid` is false →
        // reuse is impossible regardless of the `reusePrefilledAddress` flag.
        mockAddress.countryCode = nil
        var viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: mockAddress,
            reusePrefilledAddress: true,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )
        XCTAssertEqual(viewModel.itemIdentifier, mockIdentifier)
        XCTAssertEqual(viewModel.canReusePrefilledAddress, false)
        XCTAssertEqual(viewModel.shouldReusePrefilledAddress, false)
        XCTAssertNil(viewModel.countryConfigurer.country?.countryCode)
        // With no country, fmt fallback is [street, city]; the other text fields still receive
        // the prefilled values at init time, even if their kinds aren't visible.
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
            cellReconfigureHandler: { _, _ in }
        )
        XCTAssertEqual(viewModel.canReusePrefilledAddress, false)
        XCTAssertEqual(viewModel.shouldReusePrefilledAddress, false)
    }

    func testBillingAddressFromCollectedInfo() {
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: mockAddress,
            reusePrefilledAddress: true,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )

        let address = viewModel.billingAddressFromCollectedInfo()
        XCTAssertEqual(mockAddress.countryCode, address.countryCode)
        // Dropdown countries submit `selection.value` (the sub_key), which for "NSW" matches
        // the prefilled mock state.
        XCTAssertEqual(mockAddress.state, address.state)
        XCTAssertEqual(mockAddress.city, address.city)
        XCTAssertEqual(mockAddress.street, address.street)
        XCTAssertEqual(mockAddress.postcode, address.postcode)
    }

    func testBillingAddressFromCollectedInfo_OnlyEmitsFieldsInRule_HK() {
        // HK has no postcode in fmt — even if the user typed something into the (hidden)
        // zip configurer, `billingAddressFromCollectedInfo` should not emit `postcode`.
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: nil,
            defaultCountryCode: "HK",
            reusePrefilledAddress: false,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )
        // Simulate stale text in the kind that HK's rule doesn't include.
        viewModel.zipConfigurer.text = "9999"
        viewModel.streetConfigurer.text = "1 Salisbury Rd"
        viewModel.cityConfigurer.text = "Tsim Sha Tsui"
        viewModel.stateDropdownConfigurer?.selection = SubdivisionOption(value: "Kowloon", label: "九龍 - Kowloon")

        let address = viewModel.billingAddressFromCollectedInfo()
        XCTAssertEqual(address.countryCode, "HK")
        XCTAssertEqual(address.street, "1 Salisbury Rd")
        XCTAssertEqual(address.state, "Kowloon")
        XCTAssertEqual(address.city, "Tsim Sha Tsui")
        XCTAssertNil(address.postcode, "HK rule has no postcode — stale zip text must not leak")
    }

    func testBillingAddressFromCollectedInfo_OnlyEmitsFieldsInRule_GB() {
        // GB has no state in fmt — state should not be emitted even if the (hidden) state
        // configurer carries text.
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: nil,
            defaultCountryCode: "GB",
            reusePrefilledAddress: false,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )
        viewModel.stateTextConfigurer.text = "stale-state"
        viewModel.streetConfigurer.text = "10 Downing Street"
        viewModel.cityConfigurer.text = "London"
        viewModel.zipConfigurer.text = "SW1A 2AA"

        let address = viewModel.billingAddressFromCollectedInfo()
        XCTAssertEqual(address.countryCode, "GB")
        XCTAssertEqual(address.street, "10 Downing Street")
        XCTAssertEqual(address.city, "London")
        XCTAssertEqual(address.postcode, "SW1A 2AA")
        XCTAssertNil(address.state, "GB rule has no state — stale text must not leak")
    }

    func testBillingAddressFromCollectedInfo_DropdownPrefilledByLabel() {
        // The matcher accepts the sub_label too — `option(matching:)` returns the option whose
        // value or label matches case-insensitively. Output uses the sub_key.
        mockAddress.state = "New South Wales"
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: mockAddress,
            reusePrefilledAddress: true,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )

        let address = viewModel.billingAddressFromCollectedInfo()
        XCTAssertEqual(address.state, "NSW")
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
            cellReconfigureHandler: { _, _ in }
        )
        viewModel.updateValidStatusForCheckout()
        XCTAssertFalse(viewModel.countryConfigurer.isValid)
        XCTAssertEqual(viewModel.errorHintForBillingFields, viewModel.countryConfigurer.errorHint)

        // Set a country; the country-change clears all address text fields and resets the
        // state dropdown — every visible field will report invalid on first validation.
        let country = AWXCountry()
        country.countryCode = "AU"
        viewModel.selectedCountry = country
        viewModel.updateValidStatusForCheckout()

        XCTAssertTrue(viewModel.countryConfigurer.isValid)
        // The earliest invalid field's error wins; the order is country, street, state, city,
        // postcode → street fires first.
        XCTAssertFalse(viewModel.streetConfigurer.isValid)
        XCTAssertEqual(viewModel.errorHintForBillingFields, viewModel.streetConfigurer.errorHint)

        // Fill all fields with valid AU values.
        viewModel.streetConfigurer.text = "1 Main St"
        viewModel.cityConfigurer.text = "Sydney"
        viewModel.zipConfigurer.text = "2060"
        viewModel.stateDropdownConfigurer?.selection = SubdivisionOption(value: "NSW", label: "New South Wales")
        viewModel.updateValidStatusForCheckout()
        XCTAssertNil(viewModel.errorHintForBillingFields)
    }

    // MARK: - stateConfigurer mode (dropdown vs free-text)

    func testStateConfigurer_DropdownModeWhenCountryHasSubKeys() {
        // AU has `sub_keys` → state is a dropdown; stateConfigurer must be the dropdown VM.
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: nil,
            defaultCountryCode: "AU",
            reusePrefilledAddress: false,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )
        XCTAssertNotNil(viewModel.stateDropdownConfigurer)
        XCTAssertTrue(viewModel.stateConfigurer === viewModel.stateDropdownConfigurer)
        XCTAssertEqual(viewModel.currentFields.first { $0.kind == .state }?.options?.isEmpty, false)
    }

    func testStateConfigurer_TextModeWhenCountryHasStateButNoSubKeys() {
        // SC declares state in fmt (state_name_type "island") but provides no `sub_keys` —
        // the form should fall back to a free-text input.
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: nil,
            defaultCountryCode: "SC",
            reusePrefilledAddress: false,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )
        XCTAssertNil(viewModel.stateDropdownConfigurer)
        XCTAssertTrue(viewModel.stateConfigurer === viewModel.stateTextConfigurer)
        XCTAssertEqual(viewModel.currentFields.first { $0.kind == .state }?.nameType, "island")
        XCTAssertNil(viewModel.currentFields.first { $0.kind == .state }?.options)
    }

    func testStateConfigurer_TextModeFallbackWhenCountryHasNoStateField() {
        // GB has no %S in fmt — state isn't a visible field at all. The dropdown VM should be
        // nil and stateConfigurer falls back to the (unused) text VM.
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: nil,
            defaultCountryCode: "GB",
            reusePrefilledAddress: false,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )
        XCTAssertNil(viewModel.stateDropdownConfigurer)
        XCTAssertTrue(viewModel.stateConfigurer === viewModel.stateTextConfigurer)
        XCTAssertFalse(viewModel.currentFields.contains { $0.kind == .state })
    }

    func testSelectedCountry_SwitchDropdownToTextMode() {
        // Start in dropdown mode (AU) → switch to SC (state-text mode). The dropdown VM should
        // be torn down and stateConfigurer should resolve to the text VM.
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: nil,
            defaultCountryCode: "AU",
            reusePrefilledAddress: false,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )
        XCTAssertNotNil(viewModel.stateDropdownConfigurer)

        let sc = AWXCountry()
        sc.countryCode = "SC"
        viewModel.selectedCountry = sc

        XCTAssertNil(viewModel.stateDropdownConfigurer)
        XCTAssertTrue(viewModel.stateConfigurer === viewModel.stateTextConfigurer)
    }

    func testSelectedCountry_SwitchTextToDropdownMode() {
        // Start in text mode (SC) → switch to AU. A fresh dropdown VM should be built with the
        // new country's options and stateConfigurer should resolve to it.
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: nil,
            defaultCountryCode: "SC",
            reusePrefilledAddress: false,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )
        XCTAssertNil(viewModel.stateDropdownConfigurer)

        let au = AWXCountry()
        au.countryCode = "AU"
        viewModel.selectedCountry = au

        XCTAssertNotNil(viewModel.stateDropdownConfigurer)
        XCTAssertTrue(viewModel.stateConfigurer === viewModel.stateDropdownConfigurer)
        // Country changes don't carry an initialStateValue, so the dropdown starts unselected.
        XCTAssertNil(viewModel.stateDropdownConfigurer?.selection)
        // And the options reflect AU's sub_keys.
        let auOptions = viewModel.stateDropdownConfigurer?.options.map(\.value) ?? []
        XCTAssertTrue(auOptions.contains("NSW"))
        XCTAssertTrue(auOptions.contains("VIC"))
    }

    func testSelectedCountry_ClearsAllAddressFieldsOnChange() {
        // Start with a fully-prefilled AU address and confirm every field is populated, then
        // switch to a different country (JP) and confirm every text field is wiped (and the
        // newly-built dropdown VM has no preselection — country changes don't carry over
        // the previous state value).
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: mockAddress,
            reusePrefilledAddress: false,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )

        // Sanity-check the pre-populated state.
        XCTAssertEqual(viewModel.streetConfigurer.text, mockAddress.street)
        XCTAssertEqual(viewModel.cityConfigurer.text, mockAddress.city)
        XCTAssertEqual(viewModel.zipConfigurer.text, mockAddress.postcode)
        XCTAssertEqual(viewModel.stateDropdownConfigurer?.selection?.value, mockAddress.state)

        let jp = AWXCountry()
        jp.countryCode = "JP"
        viewModel.selectedCountry = jp

        XCTAssertEqual(viewModel.selectedCountry?.countryCode, "JP")
        // Every text-field configurer is reset to nil regardless of whether its kind is in
        // the new country's fmt. (E.g. JP has no city, but cityConfigurer.text is still
        // cleared — leaving stale text behind would resurface if the user later switched
        // to a country that does include city.)
        XCTAssertNil(viewModel.streetConfigurer.text)
        XCTAssertNil(viewModel.stateTextConfigurer.text)
        XCTAssertNil(viewModel.cityConfigurer.text)
        XCTAssertNil(viewModel.zipConfigurer.text)
        // The dropdown VM was rebuilt for JP's prefectures; no selection carries over.
        XCTAssertNotNil(viewModel.stateDropdownConfigurer)
        XCTAssertNil(viewModel.stateDropdownConfigurer?.selection)
    }

    func testValidate() {
        let viewModel = BillingInfoCellViewModel(
            itemIdentifier: mockIdentifier,
            prefilledAddress: mockAddress,
            reusePrefilledAddress: true,
            countrySelectionHandler: {},
            toggleReuseSelection: {},
            cellReconfigureHandler: { _, _ in }
        )
        XCTAssertNoThrow(try viewModel.validate())

        viewModel.selectedCountry = nil
        XCTAssertThrowsError(try viewModel.validate())
    }
}
