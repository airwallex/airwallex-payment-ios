//
//  Strings.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//

import Foundation

@_spi(AWX) public extension String {
    func filterIllegalCharacters(in set: CharacterSet) -> String {
        components(separatedBy: set).joined()
    }
    
    static func flagEmoji(countryCode: String) -> String {
        String(String.UnicodeScalarView(
            countryCode.unicodeScalars.compactMap { UnicodeScalar(127397 + $0.value) }
        ))
    }
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,63}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    var isValidE164PhoneNumber: Bool {
        let e164Regex = #"^\+?[1-9]\d{1,14}$"#
        return NSPredicate(format: "SELF MATCHES %@", e164Regex).evaluate(with: self)
    }
    
    var isValidCountryCode: Bool {
        NSLocale.isoCountryCodes.contains(self)
    }
    
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
