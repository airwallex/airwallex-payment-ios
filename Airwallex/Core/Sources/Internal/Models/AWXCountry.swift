//
//  AWXCountry.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/**
 `AWXCountry` includes the information of a country.
 */
@objcMembers
@objc
public class AWXCountry: NSObject, Codable {
    /**
     Country code.
     */
    public var countryCode: String = ""

    /**
     Country name.
     */
    public var countryName: String = ""

    /**
     Return all of the supported countries.
     */
    
    public static func allCountries() -> [AWXCountry] {
        let locale = Locale.current
        let isoCountryCodes = Locale.isoRegionCodes
        var countries = [AWXCountry]()
        for isoCountryCode in isoCountryCodes {
            if let name = locale.localizedString(forCurrencyCode: isoCountryCode) {
                let country = AWXCountry()
                country.countryCode = isoCountryCode
                country.countryName = name
                countries.append(country)
            }
        }
        countries.sort {
            $0.countryName.localizedCompare($1.countryName) == .orderedAscending
        }
        
        return countries
    }
    
    
    /**
     Get a matched country object.

     @param code Country code.
     @return A country object.
     */
    public static func countryWithCode(_ code: String) -> AWXCountry? {
        return allCountries().first {
            $0.countryCode == code
        }
    }
}
