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
    
    enum JWTError: Error, LocalizedError {
        case invalidFormat
        case invalidBase64
        case invalidJSON
        
        public var errorDescription: String? {
            switch self {
            case .invalidFormat:
                return "The JWT is not in a valid format."
            case .invalidBase64:
                return "The JWT contains invalid base64."
            case .invalidJSON:
                return "The JWT payload contains invalid JSON."
            }
        }
    }
    
    func payloadOfJWT() throws -> [String: Any] {
        // JWT format: header.payload.signature
        let components = self.components(separatedBy: ".")
        
        guard components.count >= 2 else {
            throw JWTError.invalidFormat
        }
        
        // Get the payload (second part)
        let payload = components[1]
        
        // Base64Url decode the payload
        var base64 = payload
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if needed
        let paddingLength = 4 - (base64.count % 4)
        if paddingLength < 4 {
            base64 += String(repeating: "=", count: paddingLength)
        }
        
        // Decode base64
        guard let data = Data(base64Encoded: base64) else {
            throw JWTError.invalidBase64
        }
        
        // Parse JSON
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return json
            } else {
                throw JWTError.invalidJSON
            }
        } catch {
            throw JWTError.invalidJSON
        }
    }
}
