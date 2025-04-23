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

class BillingInfoCellViewModel: CellViewModelIdentifiable {
    
    let itemIdentifier: String
    
    /// determin if we should display reuse toggle to user
    var canReusePrefilledAddress: Bool
    /// if determin the value of the reuse toggle
    var shouldReusePrefilledAddress: Bool
    
    var toggleReuseSelection: () -> Void
    
    var countryConfigurer: CountrySelectionViewModel!
    
    var streetConfigurer: InfoCollectorTextFieldViewModel!
    
    var stateConfigurer: InfoCollectorTextFieldViewModel!
    
    var cityConfigurer: InfoCollectorTextFieldViewModel!
    
    var zipConfigurer: InfoCollectorTextFieldViewModel!
    
    var errorHintForBillingFields: String? {
        let arr: [InfoCollectorTextFieldViewModel] = [
            countryConfigurer,
            streetConfigurer,
            stateConfigurer,
            cityConfigurer,
            zipConfigurer,
        ]
        return arr.first { !$0.isValid && $0.errorHint != nil }?.errorHint
    }
    
    // MARK: -
    
    init(itemIdentifier: String,
         prefilledAddress: AWXAddress?,
         reusePrefilledAddress: Bool = true,
         countrySelectionHandler: @escaping () -> Void,
         toggleReuseSelection: @escaping () -> Void,
         cellReconfigureHandler: @escaping CellReconfigureHandler) {
        let reusePrefilledAddress = (prefilledAddress?.isComplete ?? false) && reusePrefilledAddress
        var country: AWXCountry?
        if let countryCode = prefilledAddress?.countryCode {
            country = AWXCountry(code: countryCode)
        }
        
        canReusePrefilledAddress = prefilledAddress?.isComplete ?? false
        shouldReusePrefilledAddress = reusePrefilledAddress
        self.toggleReuseSelection = toggleReuseSelection
        self.itemIdentifier = itemIdentifier
        
        countryConfigurer = CountrySelectionViewModel(
            country: country,
            isEnabled: !reusePrefilledAddress,
            handleUserInteraction: countrySelectionHandler,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
        streetConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .street,
            text: prefilledAddress?.street,
            placeholder: NSLocalizedString("Street", bundle: .paymentSheet, comment: "info in billing address"),
            isEnabled: !reusePrefilledAddress,
            returnKeyType: .next,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
        stateConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .state,
            text: prefilledAddress?.state,
            placeholder: NSLocalizedString("State", bundle: .paymentSheet, comment: "info in billing address"),
            isEnabled: !reusePrefilledAddress,
            returnKeyType: .next,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
        cityConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .city,
            text: prefilledAddress?.city,
            placeholder: NSLocalizedString("City", bundle: .paymentSheet, comment: "info in billing address"),
            isEnabled: !reusePrefilledAddress,
            returnKeyType: .next,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
        zipConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .zipcode,
            text: prefilledAddress?.postcode,
            placeholder: NSLocalizedString("Postal code", bundle: .paymentSheet, comment: "info in billing address"),
            isEnabled: !reusePrefilledAddress,
            returnKeyType: .next,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
    }
    
    func billingAddressFromCollectedInfo() -> AWXAddress {
        let address = AWXAddress()
        address.countryCode = selectedCountry?.countryCode
        address.state = stateConfigurer.text ?? ""
        address.city = cityConfigurer.text ?? ""
        address.street = streetConfigurer.text ?? ""
        address.postcode = zipConfigurer.text
        return address
    }
    
    func updateValidStatusForCheckout() {
        let fieldConfigurers = [
            countryConfigurer,
            streetConfigurer,
            stateConfigurer,
            cityConfigurer,
            zipConfigurer,
        ]
        for configurer in fieldConfigurers {
            //  force configurer to check valid status if user left this field untouched
            configurer?.handleDidEndEditing(reconfigurePolicy: .ifNeeded)
        }
    }
    
    var selectedCountry: AWXCountry? {
        get {
            countryConfigurer.country
        }
        set {
            countryConfigurer.country = newValue
        }
    }
}

extension BillingInfoCellViewModel: ViewModelValidatable {
    func validate() throws {
        let fieldConfigurers = [
            countryConfigurer,
            streetConfigurer,
            stateConfigurer,
            cityConfigurer,
            zipConfigurer,
        ]
        for configurer in fieldConfigurers {
            try configurer?.validate()
        }
    }
}

