//
//  BillingInfoCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

class BillingInfoCellViewModel: BillingInfoCellConfiguring {
    var phoneConfigurer: any BaseTextFieldConfiguring
    
    var emailConfigurer: any BaseTextFieldConfiguring
    
    var firstNameConfigurer: any BaseTextFieldConfiguring
    
    var lastNameConfigurer: any BaseTextFieldConfiguring
    
    var canReuseShippingAddress: Bool
    
    var shouldReuseShippingAddress: Bool
    
    var toggleReuseSelection: () -> Void
    
    var countryConfigurer: any OptionSelectionViewConfiguring
    
    var streetConfigurer: any BaseTextFieldConfiguring
    
    var stateConfigurer: any BaseTextFieldConfiguring
    
    var cityConfigurer: any BaseTextFieldConfiguring
    
    var zipConfigurer: any BaseTextFieldConfiguring
    
    var errorHintForBillingFields: String? {
        let arr = [
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
    
    // MARK: -
    private var shippingInfo: AWXPlaceDetails?
    
    init(shippingInfo: AWXPlaceDetails?,
         reusingShippingInfo: Bool = true,
         countrySelectionHandler: @escaping () -> Void,
         triggerLayoutUpdate: @escaping () -> Void,
         toggleReuseSelection: @escaping () -> Void) {
        let reusingShippingInfo = (shippingInfo != nil) && reusingShippingInfo
        var country: AWXCountry?
        if let countryCode = shippingInfo?.address.countryCode {
            country = AWXCountry(code: countryCode)
        }
        countryConfigurer = CountrySelectionViewModel(
            isEnabled: !reusingShippingInfo,
            country: country,
            handleUserInteraction: countrySelectionHandler
        )
        streetConfigurer = InfoCollectorTextFieldViewModel(
            fieldName: "street",
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.address.street,
            textFieldType: .street,
            placeholder: NSLocalizedString("Street", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .next
        )
        stateConfigurer = InfoCollectorTextFieldViewModel(
            fieldName: "state",
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.address.state,
            textFieldType: .state,
            placeholder: NSLocalizedString("State", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .next
        )
        cityConfigurer = InfoCollectorTextFieldViewModel(
            fieldName: "city",
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.address.city,
            textFieldType: .city,
            placeholder: NSLocalizedString("City", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .next
        )
        zipConfigurer = InfoCollectorTextFieldViewModel(
            fieldName: "zip",
            isRequired: false,
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.address.postcode,
            textFieldType: .zipcode,
            placeholder: NSLocalizedString("Zip code (optional)", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .next
        )
        
        firstNameConfigurer = InfoCollectorTextFieldViewModel(
            fieldName: "first_name",
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.firstName,
            textFieldType: .firstName,
            placeholder: NSLocalizedString("First name", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .next
        )
        lastNameConfigurer = InfoCollectorTextFieldViewModel(
            fieldName: "last_name",
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.lastName,
            textFieldType: .lastName,
            placeholder: NSLocalizedString("Last name", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .next
        )
        phoneConfigurer = InfoCollectorTextFieldViewModel(
            fieldName: "phone",
            isRequired: false,
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.phoneNumber,
            textFieldType: .phoneNumber,
            placeholder: NSLocalizedString("Phone number (optional)", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .next
        )
        emailConfigurer = InfoCollectorTextFieldViewModel(
            fieldName: "email",
            isRequired: false,
            isEnabled: !reusingShippingInfo,
            text: shippingInfo?.email,
            textFieldType: .email,
            placeholder: NSLocalizedString("Email (optional)", bundle: .payment, comment: "info in billing address"),
            returnKeyType: .default
        )

        self.triggerLayoutUpdate = triggerLayoutUpdate
        
        canReuseShippingAddress = shippingInfo != nil
        shouldReuseShippingAddress = reusingShippingInfo
        self.toggleReuseSelection = toggleReuseSelection
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
            configurer.handleDidEndEditing()
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

