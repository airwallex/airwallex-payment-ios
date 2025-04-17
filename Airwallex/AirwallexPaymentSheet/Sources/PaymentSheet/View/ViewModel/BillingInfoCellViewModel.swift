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
    
    var canReuseShippingAddress: Bool
    
    var shouldReuseShippingAddress: Bool
    
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
    private var shippingInfo: AWXPlaceDetails?
    
    init(itemIdentifier: String,
         shippingAddress: AWXAddress?,
         reusingShippingInfo: Bool = true,
         countrySelectionHandler: @escaping () -> Void,
         toggleReuseSelection: @escaping () -> Void,
         cellReconfigureHandler: @escaping CellReconfigureHandler) {
        let reusingShippingInfo = (shippingAddress?.isComplete ?? false) && reusingShippingInfo
        var country: AWXCountry?
        if let countryCode = shippingAddress?.countryCode {
            country = AWXCountry(code: countryCode)
        }
        
        canReuseShippingAddress = shippingAddress?.isComplete ?? false
        shouldReuseShippingAddress = reusingShippingInfo
        self.toggleReuseSelection = toggleReuseSelection
        self.itemIdentifier = itemIdentifier
        
        countryConfigurer = CountrySelectionViewModel(
            country: country,
            isEnabled: !reusingShippingInfo,
            handleUserInteraction: countrySelectionHandler,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
        streetConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .street,
            text: shippingAddress?.street,
            placeholder: NSLocalizedString("Street", bundle: .paymentSheet, comment: "info in billing address"),
            isEnabled: !reusingShippingInfo,
            returnKeyType: .next,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
        stateConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .state,
            text: shippingAddress?.state,
            placeholder: NSLocalizedString("State", bundle: .paymentSheet, comment: "info in billing address"),
            isEnabled: !reusingShippingInfo,
            returnKeyType: .next,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
        cityConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .city,
            text: shippingAddress?.city,
            placeholder: NSLocalizedString("City", bundle: .paymentSheet, comment: "info in billing address"),
            isEnabled: !reusingShippingInfo,
            returnKeyType: .next,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
        zipConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .zipcode,
            text: shippingAddress?.postcode,
            placeholder: NSLocalizedString("Postal code", bundle: .paymentSheet, comment: "info in billing address"),
            isEnabled: !reusingShippingInfo,
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
            configurer?.handleDidEndEditing(reconfigureIfNeeded: true)
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

