//
//  BillingInfoCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexCore)
import AirwallexCore
#endif
#if canImport(AirwallexPayment)
import AirwallexPayment
#endif

class BillingInfoCellViewModel: CellViewModelIdentifiable {

    let itemIdentifier: String

    /// determin if we should display reuse toggle to user
    var canReusePrefilledAddress: Bool
    /// if determin the value of the reuse toggle
    var shouldReusePrefilledAddress: Bool

    var toggleReuseSelection: () -> Void

    var countryConfigurer: CountrySelectionViewModel!

    var streetConfigurer: InfoCollectorTextFieldViewModel!

    /// Free-text state field used when the country has no `sub_keys`.
    var stateTextConfigurer: InfoCollectorTextFieldViewModel!

    /// State dropdown used when the country has `sub_keys`. Non-nil only in dropdown mode.
    var stateDropdownConfigurer: SubdivisionSelectionViewModel?

    /// Currently-active state field — dropdown if present, otherwise the free-text fallback.
    var stateConfigurer: InfoCollectorTextFieldViewModel {
        stateDropdownConfigurer ?? stateTextConfigurer
    }

    var cityConfigurer: InfoCollectorTextFieldViewModel!

    var zipConfigurer: InfoCollectorTextFieldViewModel!

    /// Address fields visible for the currently-selected country, in render order.
    private(set) var currentFields: [AddressFieldSpec] = []

    var errorHintForBillingFields: String? {
        activeConfigurers.first { !$0.isValid && $0.errorHint != nil }?.errorHint
    }

    var updateFieldsLayeringForErrorStatus: (() -> Void)?

    private let ruleProvider: AddressRuleProvider
    private let subdivisionSelectionHandler: () -> Void
    private let cellReconfigureHandler: CellReconfigureHandler

    // MARK: -

    init(itemIdentifier: String,
         prefilledAddress: AWXAddress?,
         defaultCountryCode: String? = nil,
         reusePrefilledAddress: Bool = true,
         ruleProvider: AddressRuleProvider = AddressRuleProvider(),
         countrySelectionHandler: @escaping () -> Void,
         subdivisionSelectionHandler: @escaping () -> Void = {},
         toggleReuseSelection: @escaping () -> Void,
         cellReconfigureHandler: @escaping CellReconfigureHandler) {
        var country: AWXCountry?
        if let countryCode = prefilledAddress?.countryCode {
            country = AWXCountry(code: countryCode)
        } else if let defaultCountryCode {
            country = AWXCountry(code: defaultCountryCode)
        }
        let isPrefilledComplete = prefilledAddress.map { ruleProvider.isValid($0) } ?? false
        let reusePrefilledAddress = isPrefilledComplete && reusePrefilledAddress

        canReusePrefilledAddress = isPrefilledComplete
        shouldReusePrefilledAddress = reusePrefilledAddress
        self.toggleReuseSelection = toggleReuseSelection
        self.itemIdentifier = itemIdentifier
        self.ruleProvider = ruleProvider
        self.subdivisionSelectionHandler = subdivisionSelectionHandler
        self.cellReconfigureHandler = cellReconfigureHandler

        countryConfigurer = CountrySelectionViewModel(
            country: country,
            isEnabled: !reusePrefilledAddress,
            handleUserInteraction: countrySelectionHandler,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
        streetConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .street,
            text: prefilledAddress?.street,
            placeholder: NSLocalizedString("Street", bundle: .paymentSheet, comment: "billing street placeholder"),
            isEnabled: !reusePrefilledAddress,
            clearButtonMode: .whileEditing,
            returnKeyType: .next,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
        stateTextConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .state,
            text: prefilledAddress?.state,
            placeholder: NSLocalizedString("State", bundle: .paymentSheet, comment: "billing state placeholder"),
            isEnabled: !reusePrefilledAddress,
            clearButtonMode: .whileEditing,
            returnKeyType: .next,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
        cityConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .city,
            text: prefilledAddress?.city,
            placeholder: NSLocalizedString("City", bundle: .paymentSheet, comment: "billing city placeholder"),
            isEnabled: !reusePrefilledAddress,
            clearButtonMode: .whileEditing,
            returnKeyType: .next,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
        zipConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .zipcode,
            text: prefilledAddress?.postcode,
            placeholder: NSLocalizedString("Postal code", bundle: .paymentSheet, comment: "billing postal code placeholder"),
            isEnabled: !reusePrefilledAddress,
            clearButtonMode: .whileEditing,
            returnKeyType: .next,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )

        applyCountryRules(country?.countryCode, shouldClearFieldText: false, initialStateValue: prefilledAddress?.state)
    }

    func billingAddressFromCollectedInfo() -> AWXAddress {
        let address = AWXAddress()
        address.countryCode = selectedCountry?.countryCode
        // Only emit fields the country's rule actually declares. Sending e.g. an empty
        // `postcode` for HK (which has no %Z in its `fmt`) or an empty `state` for GB would
        // be both noisy.
        for spec in currentFields {
            switch spec.kind {
            case .street:
                address.street = streetConfigurer.text
            case .state:
                if let dropdown = stateDropdownConfigurer {
                    address.state = dropdown.selection?.value
                } else {
                    address.state = stateTextConfigurer.text
                }
            case .city:
                address.city = cityConfigurer.text
            case .postcode:
                address.postcode = zipConfigurer.text
            }
        }
        return address
    }

    func updateValidStatusForCheckout() {
        for configurer in activeConfigurers {
            //  force configurer to check valid status if user left this field untouched
            configurer.handleDidEndEditing(reconfigureStrategy: .onValidationChange)
        }
        if let updateFieldsLayeringForErrorStatus {
            updateFieldsLayeringForErrorStatus()
        }
    }

    var selectedCountry: AWXCountry? {
        get {
            countryConfigurer.country
        }
        set {
            countryConfigurer.country = newValue
            applyCountryRules(newValue?.countryCode, shouldClearFieldText: true)
            cellReconfigureHandler(itemIdentifier, true)
        }
    }

    // MARK: - Country rules

    private func applyCountryRules(_ countryCode: String?, shouldClearFieldText: Bool, initialStateValue: String? = nil) {
        let fields = ruleProvider.fields(for: countryCode)
        currentFields = fields

        // Clear every text field up front so values entered for the previous country don't
        // resurface if the user later switches back through a country that hides them. Mirrors
        // web's `clearAddressFields` (index.tsx:52-56).
        if shouldClearFieldText {
            streetConfigurer.resetTextAndValidationStatus()
            stateTextConfigurer.resetTextAndValidationStatus()
            cityConfigurer.resetTextAndValidationStatus()
            zipConfigurer.resetTextAndValidationStatus()
        }

        for spec in fields {
            let placeholder = spec.localizedLabel
            switch spec.kind {
            case .street:
                streetConfigurer.placeholder = placeholder
                streetConfigurer.inputValidator = RegexInputValidator(
                    regex: nil,
                    isRequired: true
                )
            case .state:
                if let options = spec.subdivision {
                    // Pre-select the dropdown from the prefilled state string (via the same exact-
                    // match-against-value-or-label rule as web's `getMappedState`). Country changes
                    // don't pass an `initialStateValue`, so the dropdown resets to nil on switch.
                    let preselected = options.option(matching: initialStateValue)
                    stateDropdownConfigurer = SubdivisionSelectionViewModel(
                        options: options,
                        selection: preselected,
                        placeholder: placeholder,
                        isEnabled: !shouldReusePrefilledAddress,
                        handleUserInteraction: subdivisionSelectionHandler,
                        reconfigureHandler: { [cellReconfigureHandler, itemIdentifier] _, refresh in
                            cellReconfigureHandler(itemIdentifier, refresh)
                        }
                    )
                    stateDropdownConfigurer?.inputValidator = RegexInputValidator(
                        regex: nil,
                        isRequired: true
                    )
                } else {
                    stateDropdownConfigurer = nil
                    stateTextConfigurer.placeholder = placeholder
                    stateTextConfigurer?.inputValidator = RegexInputValidator(
                        regex: nil,
                        isRequired: true
                    )
                }
            case .city:
                cityConfigurer.placeholder = placeholder
                cityConfigurer.inputValidator = RegexInputValidator(
                    regex: nil,
                    isRequired: true
                )
            case .postcode:
                zipConfigurer.placeholder = placeholder
                zipConfigurer.inputValidator = RegexInputValidator(
                    regex: spec.regex,
                    isRequired: true
                )
            }
        }
    }

    /// Address-field configurers (excluding country) for currently-visible fields, in render order.
    private var addressFieldConfigurers: [InfoCollectorTextFieldViewModel] {
        currentFields.map { spec in
            switch spec.kind {
            case .street: return streetConfigurer
            case .state: return stateConfigurer
            case .city: return cityConfigurer
            case .postcode: return zipConfigurer
            }
        }
    }

    /// All currently-visible configurers including country. Used for validation and error-hint surfacing.
    private var activeConfigurers: [InfoCollectorTextFieldViewModel] {
        [countryConfigurer] + addressFieldConfigurers
    }
}

extension BillingInfoCellViewModel: ViewModelValidatable {
    func validate() throws {
        for configurer in activeConfigurers {
            try configurer.validate()
        }
    }
}
