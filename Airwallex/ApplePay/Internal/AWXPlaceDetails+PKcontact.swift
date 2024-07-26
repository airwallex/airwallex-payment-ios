//
//  AWXPlaceDetails+PKcontact.swift
//  ApplePay
//
//  Created by Tony He (CTR) on 2024/7/29.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@objc extension AWXPlaceDetails {
    
    public func convertToPaymentContact() -> PKContact {
        let contact = PKContact()
        var nameComponents = PersonNameComponents()
        nameComponents.givenName = firstName
        nameComponents.familyName = lastName
        
        let addr = CNMutablePostalAddress()
        if let city = address?.city {
            addr.city = city
        }
        if let street = address?.street {
            addr.street = street
        }
        if let countryCode = address?.countryCode {
            addr.isoCountryCode = countryCode
        }
        if let state = address?.state {
            addr.state = state
        }
        if let postcode = address?.postcode {
            addr.postalCode = postcode
        }
        
        contact.name = nameComponents
        if let email = email {
            contact.emailAddress = email
        }
        if let phoneNumber = phoneNumber {
            contact.phoneNumber = CNPhoneNumber(stringValue: phoneNumber)
        }
        contact.postalAddress = addr
        
        return contact
    }
    
}
