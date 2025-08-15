//
//  SchemaFieldValidator.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 30/7/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
@_spi(AWX) import AirwallexPayment
#endif
import Foundation

struct SchemaFieldValidator: UserInputValidator {
    
    let validation: AWXFieldValidation
    let displayName: String?
    
    init?(field: AWXField) {
        guard let validation = field.validations,
              validation.regex != nil || validation.max > 0 else {
            return nil
        }
        self.validation = validation
        self.displayName = field.displayName.isEmpty ? nil : field.displayName
    }
    
    func validateUserInput(_ text: String?) throws {
        guard let text else {
            throw NSLocalizedString("Invalid user input", bundle: .paymentSheet, comment: "invalid user input").asError()
        }
        
        if validation.max > 0 {
            guard text.count <= validation.max else {
                throw NSLocalizedString("Input is too long.", bundle: .paymentSheet, comment: "invalid user input").asError()
            }
        }
        
        if let pattern = validation.regex {
            do {
                let regex = try NSRegularExpression(pattern: pattern)
                let range = NSRange(location: 0, length: text.utf16.count)
                let matches = regex.matches(in: text, options: [], range: range)
                
                // Check if the entire string matches the regex
                let fullMatch = matches.first?.range.length == text.utf16.count
                
                guard fullMatch else {
                    if let displayName {
                        let localizedFormat = NSLocalizedString("Invalid %@", bundle: .paymentSheet, comment: "user input validation")
                        throw String(format: localizedFormat, displayName.lowercased()).asError()
                    } else {
                        throw NSLocalizedString("Invalid user input", bundle: .paymentSheet, comment: "invalid user input").asError()
                    }
                }
            } catch let error as ErrorMessage {
                throw error
            } catch {
                // just ignore this regex
            }
        }
    }
}
