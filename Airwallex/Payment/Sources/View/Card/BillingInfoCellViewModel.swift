//
//  BillingInfoCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

class BillingInfoCellViewModel {
    var phoneConfigurer: InfoCollectorTextFieldViewModel!
    
    var emailConfigurer: InfoCollectorTextFieldViewModel!
    
    var firstNameConfigurer: InfoCollectorTextFieldViewModel!
    
    var lastNameConfigurer: InfoCollectorTextFieldViewModel!
    
    var canReuseShippingAddress: Bool
    
    var shouldReuseShippingAddress: Bool
    
    var toggleReuseSelection: () -> Void
    
    var countryConfigurer: CountrySelectionViewModel!
    
    var streetConfigurer: InfoCollectorTextFieldViewModel!
    
    var stateConfigurer: InfoCollectorTextFieldViewModel!
    
    var cityConfigurer: InfoCollectorTextFieldViewModel!
    
    var zipConfigurer: InfoCollectorTextFieldViewModel!
    
    var errorHintForBillingFields: String? {
        let arr: [any BaseTextFieldConfiguring] = [
            countryConfigurer,
            streetConfigurer,
            stateConfigurer,
            cityConfigurer,
            zipConfigurer,
            firstNameConfigurer,
            lastNameConfigurer,
            phoneConfigurer,
            emailConfigurer
        ]
        return arr.first { !$0.isValid && $0.errorHint != nil }?.errorHint
    }
    
    var triggerLayoutUpdate: () -> Void
    
    var reconfigureHandler: (BillingInfoCellViewModel, Bool) -> Void
    
    // MARK: -
    private var shippingInfo: AWXPlaceDetails?
    
    init(shippingInfo: AWXPlaceDetails?,
         reusingShippingInfo: Bool = true,
         countrySelectionHandler: @escaping () -> Void,
         triggerLayoutUpdate: @escaping () -> Void,
         toggleReuseSelection: @escaping () -> Void,
         reconfigureHandler: @escaping (BillingInfoCellViewModel, Bool) -> Void) {
        let reusingShippingInfo = (shippingInfo != nil) && reusingShippingInfo
        var country: AWXCountry?
        if let countryCode = shippingInfo?.address.countryCode {
            country = AWXCountry(code: countryCode)
        }
        
        self.triggerLayoutUpdate = triggerLayoutUpdate
        canReuseShippingAddress = shippingInfo != nil
        shouldReuseShippingAddress = reusingShippingInfo
        self.toggleReuseSelection = toggleReuseSelection
        self.reconfigureHandler = reconfigureHandler
        
        countryConfigurer = CountrySelectionViewModel(
            isEnabled: !reusingShippingInfo,
            country: country,
            handleUserInteraction: countrySelectionHandler,
            reconfigureHandler: { [weak self] _, invalidateLayout in
                guard let self else { return }
                self.reconfigureHandler(self, invalidateLayout)
            }
        )
        streetConfigurer = InfoCollectorTextFieldViewModel(
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.address.street,
            textFieldType: .street,
            placeholder: NSLocalizedString("Street", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .next,
            reconfigureHandler: { [weak self] _, invalidateLayout in
                guard let self else { return }
                self.reconfigureHandler(self, invalidateLayout)
            }
        )
        stateConfigurer = InfoCollectorTextFieldViewModel(
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.address.state,
            textFieldType: .state,
            placeholder: NSLocalizedString("State", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .next,
            reconfigureHandler: { [weak self] _, invalidateLayout in
                guard let self else { return }
                self.reconfigureHandler(self, invalidateLayout)
            }
        )
        cityConfigurer = InfoCollectorTextFieldViewModel(
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.address.city,
            textFieldType: .city,
            placeholder: NSLocalizedString("City", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .next,
            reconfigureHandler: { [weak self] _, invalidateLayout in
                guard let self else { return }
                self.reconfigureHandler(self, invalidateLayout)
            }
        )
        zipConfigurer = InfoCollectorTextFieldViewModel(
            isRequired: false,
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.address.postcode,
            textFieldType: .zipcode,
            placeholder: NSLocalizedString("Zip code (optional)", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .next,
            reconfigureHandler: { [weak self] _, invalidateLayout in
                guard let self else { return }
                self.reconfigureHandler(self, invalidateLayout)
            }
        )
        
        firstNameConfigurer = InfoCollectorTextFieldViewModel(
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.firstName,
            textFieldType: .firstName,
            placeholder: NSLocalizedString("First name", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .next,
            reconfigureHandler: { [weak self] _, invalidateLayout in
                guard let self else { return }
                self.reconfigureHandler(self, invalidateLayout)
            }
        )
        lastNameConfigurer = InfoCollectorTextFieldViewModel(
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.lastName,
            textFieldType: .lastName,
            placeholder: NSLocalizedString("Last name", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .next,
            reconfigureHandler: { [weak self] _, invalidateLayout in
                guard let self else { return }
                self.reconfigureHandler(self, invalidateLayout)
            }
        )
        phoneConfigurer = InfoCollectorTextFieldViewModel(
            isRequired: false,
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.phoneNumber,
            textFieldType: .phoneNumber,
            placeholder: NSLocalizedString("Phone number (optional)", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .next,
            reconfigureHandler: { [weak self] _, invalidateLayout in
                guard let self else { return }
                self.reconfigureHandler(self, invalidateLayout)
            }
        )
        emailConfigurer = InfoCollectorTextFieldViewModel(
            isRequired: false,
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.email,
            textFieldType: .email,
            placeholder: NSLocalizedString("Email (optional)", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .default,
            reconfigureHandler: { [weak self] _, invalidateLayout in
                guard let self else { return }
                self.reconfigureHandler(self, invalidateLayout)
            }
        )
    }
    
    func billingFromCollectedInfo() -> AWXPlaceDetails {
        let place = AWXPlaceDetails()
        place.firstName = firstNameConfigurer.text ?? ""
        place.lastName = lastNameConfigurer.text ?? ""
        place.email = emailConfigurer.text
        place.phoneNumber = phoneConfigurer.text
        
        let address = AWXAddress()
        address.countryCode = selectedCountry?.countryCode
        address.state = stateConfigurer.text ?? ""
        address.city = cityConfigurer.text ?? ""
        address.street = streetConfigurer.text ?? ""
        address.postcode = zipConfigurer.text ?? ""
        
        place.address = address
        return place
    }
    
    func updateValidStatusForCheckout() {
        let fieldConfigurers = [
            firstNameConfigurer,
            lastNameConfigurer,
            streetConfigurer,
            stateConfigurer,
            cityConfigurer,
            zipConfigurer,
            emailConfigurer,
            phoneConfigurer
        ]
        for configurer in fieldConfigurers {
            //  force configurer to check valid status if user left this field untouched
//            configurer.handleDidEndEditing()
            // wpdebug optimize this
            configurer?.textFieldDidEndEditing(UITextField())
        }
    }
    
    var selectedCountry: AWXCountry? {
        get {
            (countryConfigurer as? CountrySelectionViewModel)?.country
        }
        set {
            (countryConfigurer as? CountrySelectionViewModel)?.country = newValue
        }
    }
}

