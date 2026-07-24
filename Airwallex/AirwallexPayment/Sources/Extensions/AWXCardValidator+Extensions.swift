//
//  AWXCardValidator+Extensions.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/9.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif

package extension AWXCardValidator {
        
    static func validate(card: AWXCard,
                         nameRequired: Bool,
                         supportedSchemes: [AWXCardScheme] = [],
                         language: AWXPaymentLanguage = .english) throws {
        do {
            try Self.validate(number: card.number, supportedSchemes: supportedSchemes, language: language)
        } catch {
            throw NSLocalizedString("Invalid card number", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
        
        do {
            try Self.validate(expiryMonth: card.expiryMonth, expiryYear: card.expiryYear, language: language)
        } catch {
            throw NSLocalizedString("Invalid expires date", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
        
        do {
            // it's safe to force-unwrap here since `validate(number: card.number)` passed
            let brand = AWXCardValidator.shared().brand(forCardNumber: card.number)
            try validate(cvc: card.cvc, requiredLength: Self.cvcLength(for: brand.type), language: language)
        } catch {
            throw NSLocalizedString("Invalid CVC / CVV", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
        
        // cardholder name can be nil or empty if not required by session.requireBillingContactFields
        if nameRequired {
            do {
                try validate(nameOnCard: card.name, language: language)
            } catch {
                throw NSLocalizedString("Invalid name on card", bundle: .payment.language(language), comment: "card validator error message").asError()
            }
        }
    }
    /// validate card number
    /// - Parameters:
    ///   - number: string composed of decimal digits
    ///   - supportedSchemes: supported scheme return from server
    static func validate(number: String?,
                         supportedSchemes: [AWXCardScheme],
                         language: AWXPaymentLanguage = .english) throws {
        guard let number, !number.isEmpty else {
            throw NSLocalizedString("Card number is required", bundle: .payment.language(language), comment: "card validator error message").asError()
        }

        // Ensure the card number contains only decimal digits
        guard number.allSatisfy({ $0.isASCII && $0.isNumber }) else {
            throw NSLocalizedString("Card number must contain only digits", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
        
        let brand = AWXCardValidator.shared().brand(forCardNumber: number)
        
        guard brand.type != .unknown else {
            throw NSLocalizedString("Card not supported for payment", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
        
        guard supportedSchemes.contains(where: { $0.name.lowercased() == brand.name.lowercased() }) else {
            throw NSLocalizedString("Card not supported for payment", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
        
        guard AWXCardValidator.shared().isValidCardLength(number) else {
            throw NSLocalizedString("Card number is invalid", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
        
        // Validate card number using Luhn algorithm
        guard isValidLuhn(cardNumber: number) else {
            throw NSLocalizedString("Card number is invalid", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
    }
    
    static func validate(expiryMonth: String?,
                         expiryYear: String?,
                         language: AWXPaymentLanguage = .english) throws {
        guard let expiryMonth,
              !expiryMonth.isEmpty,
              let expiryYear,
              !expiryYear.isEmpty else {
            throw NSLocalizedString("Expiry date is required", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
        
        guard let month = Int(expiryMonth),
              let year = Int(expiryYear),
              month > 0 && month <= 12 else {
            throw NSLocalizedString("Card’s expiration date is invalid", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
        
        let calendar = Calendar(identifier: .gregorian)
        let date = Date()
        let currentYear = calendar.component(.year, from: date)
        let currentMonth = calendar.component(.month, from: date)
         
        guard (year == currentYear && month >= currentMonth) || year > currentYear else {
            throw NSLocalizedString("Card’s expiration date is invalid", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
    }
    
    static func validate(cvc: String?,
                         requiredLength: Int,
                         language: AWXPaymentLanguage = .english) throws {
        guard let cvc, !cvc.isEmpty else {
            throw NSLocalizedString("Security code is required", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
        // Ensure the card number contains only decimal digits
        guard cvc.allSatisfy({ $0.isASCII && $0.isNumber }) else {
            throw NSLocalizedString("Security code must contain only digits", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
        
        guard cvc.count == requiredLength else {
            throw NSLocalizedString("Security code is invalid", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
    }
    
    static func validate(nameOnCard: String?, language: AWXPaymentLanguage = .english) throws {
        guard let nameOnCard, !nameOnCard.isEmpty else {
            throw NSLocalizedString("Please enter your card name", bundle: .payment.language(language), comment: "card validator error message").asError()
        }
    }
    
    static func possibleBrandTypes(forCardNumber number: String?) -> [AWXBrandType] {
        let results = AWXCardValidator.shared().possibleBrandTypes(forCardNumber: number ?? "")
        return results.compactMap { AWXBrandType(rawValue: $0.uintValue) }
    }
    
    /// Validates a card number using the Luhn algorithm
    /// - Parameter cardNumber: The card number to validate
    /// - Returns: True if the card number passes Luhn validation, false otherwise
    private static func isValidLuhn(cardNumber: String) -> Bool {
        // Convert string to array of integers
        let digits = cardNumber.compactMap { Int(String($0)) }
        
        guard digits.count == cardNumber.count else {
            return false
        }
        
        // Starting from the right, double every second digit
        var sum = 0
        for (index, digit) in digits.enumerated().reversed() {
            // If index is even (from the right), use the digit as is
            // If index is odd (from the right), double the digit
            let isOdd = (digits.count - 1 - index) % 2 == 1
            let value = isOdd ? digit * 2 : digit
            
            // If doubling results in a two-digit number, add those digits together
            sum += value > 9 ? value - 9 : value
        }
        
        // If the sum is divisible by 10, the card number is valid
        return sum % 10 == 0
    }
}
