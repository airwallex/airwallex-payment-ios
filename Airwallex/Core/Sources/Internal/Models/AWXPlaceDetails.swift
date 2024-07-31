//
//  AWXPlaceDetails.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/// `AWXPlaceDetails` includes the information of a billing address.
@objcMembers
@objc
public class AWXPlaceDetails: NSObject, Codable {
    /**
     First name of the customer.
     */
    public var firstName: String?

    /**
     Last name of the customer.
     */
    public var lastName: String?

    /**
     Email address of the customer, optional.
     */
    public var email: String?

    /**
     Date of birth of the customer in the format: YYYY-MM-DD, optional.
     */
    public var dateOfBirth: String?

    /**
     Phone number of the customer, optional.
     */
    public var phoneNumber: String?

    /**
     Address object.
     */
    public var address: AWXAddress?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case dateOfBirth = "date_of_birth"
        case phoneNumber = "phone_number"
        case address
    }
}

@objc public extension AWXPlaceDetails {
    func validate() -> String? {
        if firstName == nil || firstName?.count == 0 {
            return "Invalid first name"
        }
        if firstName == nil || lastName?.count == 0 {
            return "Invalid last name"
        }
        if let email = email, email.count > 0 {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            if !emailTest.evaluate(with: email) {
                return "Invalid email"
            }
        }
        if address == nil {
            return "Invalid shipping address"
        }
        if address?.countryCode == nil || address?.countryCode?.count == 0 {
            return "Invalid country/region"
        }
        if address?.city == nil || address?.city?.count == 0 {
            return "Invalid your city"
        }
        if address?.street == nil || address?.street?.count == 0 {
            return "Invalid street"
        }
        return nil
    }

    static func decodeFromJSON(_ dic: [String: Any]) -> AWXPlaceDetails {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let decoder = JSONDecoder()
            let result = try decoder.decode(AWXPlaceDetails.self, from: jsonData)

            return result
        } catch {
            return AWXPlaceDetails()
        }
    }
}
