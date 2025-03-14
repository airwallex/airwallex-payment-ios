//
//  AWXCardValidator+Extensions.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/9.
//  Copyright © 2025 Airwallex. All rights reserved.
//

extension AWXCardValidator {
    
    convenience init(_ supportedSchemes: [AWXCardScheme]?) {
        self.init()
        self.supportedSchemes = supportedSchemes
    }
    
    
    func validate(card: AWXCard) throws {
        do {
            try Self.validate(number: card.number, supportedSchemes: supportedSchemes ?? [])
        } catch {
            throw NSLocalizedString("Invalid card number", bundle: .payment, comment: "card validator error message").asError()
        }
        
        do {
            try Self.validate(expiryMonth: card.expiryMonth, expiryYear: card.expiryYear)
        } catch {
            throw NSLocalizedString("Invalid expires date", bundle: .payment, comment: "card validator error message").asError()
        }
        
        do {
            // it's safe to force-unwrap here since `validate(number: card.number)` passed
            let brand = brand(forCardNumber: card.number)!
            try Self.validate(cvc: card.cvc, requiredLength: Self.cvcLength(for: brand.type))
        } catch {
            throw NSLocalizedString("Invalid CVC / CVV", bundle: .payment, comment: "card validator error message").asError()
        }
        
        // cardholder name can be nil if not required by session.requireBillingContactFields & no shipping info to reuse
    }
    /// validate card number
    /// - Parameters:
    ///   - number: string composed of decimal digits
    ///   - supportedSchemes: supported scheme return from server
    static func validate(number: String?, supportedSchemes: [AWXCardScheme]) throws {
        guard let cardNumber = number?.filterIllegalCharacters(in: .decimalDigits.inverted),
              !cardNumber.isEmpty else {
            throw NSLocalizedString("Card number is required", bundle: .payment, comment: "card validator error message").asError()
        }
        guard AWXCardValidator.shared().isValidCardLength(cardNumber) else {
            throw NSLocalizedString("Card number is invalid", bundle: .payment, comment: "card validator error message").asError()
        }
        let brand = AWXCardValidator.shared().brand(forCardNumber: cardNumber)
        
        guard let brand else {
            throw NSLocalizedString("Card not supported for payment", bundle: .payment, comment: "card validator error message").asError()
        }
        
        guard supportedSchemes.contains(where: { $0.name.lowercased() == brand.name.lowercased() }) else {
            throw NSLocalizedString("Card not supported for payment", bundle: .payment, comment: "card validator error message").asError()
        }
    }
    
    static func validate(expiryMonth: String?, expiryYear: String?) throws {
        guard let expiryMonth = expiryMonth?.trimmed,
              !expiryMonth.isEmpty,
              let expiryYear = expiryYear?.trimmed,
              !expiryYear.isEmpty else {
            throw NSLocalizedString("Expiry date is required", bundle: .payment, comment: "card validator error message").asError()
        }
        
        guard let month = Int(expiryMonth),
              let year = Int(expiryYear),
              month > 0 && month <= 12 else {
            throw NSLocalizedString("Card’s expiration date is invalid", bundle: .payment, comment: "card validator error message").asError()
        }
        
        let calendar = Calendar(identifier: .gregorian)
        let date = Date()
        let currentYear = calendar.component(.year, from: date) % 100
        let currentMonth = calendar.component(.month, from: date)
         
        guard (year == currentYear && month >= currentMonth) || year > currentYear else {
            throw NSLocalizedString("Card’s expiration date is invalid", bundle: .payment, comment: "card validator error message").asError()
        }
    }
    
    static func validate(cvc: String?, requiredLength: Int) throws {
        guard let cvc = cvc?.filterIllegalCharacters(in: .decimalDigits.inverted),
              !cvc.isEmpty else {
            throw NSLocalizedString("Security code is required", bundle: .payment, comment: "card validator error message").asError()
        }
        guard cvc.count == requiredLength else {
            throw NSLocalizedString("Security code is invalid", bundle: .payment, comment: "card validator error message").asError()
        }
    }
    
    static func validate(nameOnCard: String?) throws {
        guard let nameOnCard, !nameOnCard.isEmpty else {
            throw NSLocalizedString("Please enter your card name", bundle: .payment, comment: "card validator error message").asError()
        }
    }
}
