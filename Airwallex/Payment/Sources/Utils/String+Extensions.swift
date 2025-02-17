//
//  Strings.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//

import Foundation

extension String {
    func filterIllegalCharacters(in set: CharacterSet) -> String {
        let components = components(separatedBy: set)
        return components.joined()
    }
    
    static func flagEmoji(countryCode: String) -> String {
        String(String.UnicodeScalarView(
            countryCode.unicodeScalars.compactMap { UnicodeScalar(127397 + $0.value) }
        ))
    }
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
}
//
//extension String: @retroactive Error {
//    var localizedDescription: String { self }
//}
