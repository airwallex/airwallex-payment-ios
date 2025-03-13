//
//  BillingInfoCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

class BillingInfoCellViewModel {
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
    
    var reconfigureHandler: (BillingInfoCellViewModel, Bool) -> Void
    
    // MARK: -
    private var shippingInfo: AWXPlaceDetails?
    
    init(shippingInfo: AWXPlaceDetails?,
         reusingShippingInfo: Bool = true,
         countrySelectionHandler: @escaping () -> Void,
         toggleReuseSelection: @escaping () -> Void,
         reconfigureHandler: @escaping (BillingInfoCellViewModel, Bool) -> Void) {
        let reusingShippingInfo = (shippingInfo != nil) && reusingShippingInfo
        var country: AWXCountry?
        if let countryCode = shippingInfo?.address?.countryCode {
            country = AWXCountry(code: countryCode)
        }
        
        canReuseShippingAddress = shippingInfo != nil
        shouldReuseShippingAddress = reusingShippingInfo
        self.toggleReuseSelection = toggleReuseSelection
        self.reconfigureHandler = reconfigureHandler
        
        countryConfigurer = CountrySelectionViewModel(
            country: country,
            isEnabled: !reusingShippingInfo,
            handleUserInteraction: countrySelectionHandler,
            reconfigureHandler: { [weak self] _, invalidateLayout in
                guard let self else { return }
                self.reconfigureHandler(self, invalidateLayout)
            }
        )
        streetConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .street,
            text: shippingInfo?.address?.street,
            placeholder: NSLocalizedString("Street", bundle: .payment, comment: "info in billing address"),
            isEnabled: !reusingShippingInfo,
            returnKeyType: .next,
            reconfigureHandler: { [weak self] _, invalidateLayout in
                guard let self else { return }
                self.reconfigureHandler(self, invalidateLayout)
            }
        )
        stateConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .state,
            text: shippingInfo?.address?.state,
            placeholder: NSLocalizedString("State", bundle: .payment, comment: "info in billing address"),
            isEnabled: !reusingShippingInfo,
            returnKeyType: .next,
            reconfigureHandler: { [weak self] _, invalidateLayout in
                guard let self else { return }
                self.reconfigureHandler(self, invalidateLayout)
            }
        )
        cityConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .city,
            text: shippingInfo?.address?.city,
            placeholder: NSLocalizedString("City", bundle: .payment, comment: "info in billing address"),
            isEnabled: !reusingShippingInfo,
            returnKeyType: .next,
            reconfigureHandler: { [weak self] _, invalidateLayout in
                guard let self else { return }
                self.reconfigureHandler(self, invalidateLayout)
            }
        )
        zipConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .zipcode,
            text: shippingInfo?.address?.postcode,
            placeholder: NSLocalizedString("Postal code", bundle: .payment, comment: "info in billing address"),
            isEnabled: !reusingShippingInfo,
            returnKeyType: .next,
            reconfigureHandler: { [weak self] _, invalidateLayout in
                guard let self else { return }
                self.reconfigureHandler(self, invalidateLayout)
            }
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

