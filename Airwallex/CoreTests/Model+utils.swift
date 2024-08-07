//
//  Model+utils.swift
//  CoreTests
//
//  Created by Tony He (CTR) on 2024/8/16.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@testable import Core

@objc public extension AWXPaymentMethodOptions {
    static func decodeFromJSON(_ dic: [String: Any]) -> AWXPaymentMethodOptions {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let result = try JSONDecoder().decode(AWXPaymentMethodOptions.self, from: jsonData)

            return result
        } catch {
            return AWXPaymentMethodOptions(cardOptions: nil)
        }
    }
}

@objc public extension AWXCard {
    static func decodeFromJSON(_ dic: [String: Any]) -> AWXCard {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let result = try JSONDecoder().decode(AWXCard.self, from: jsonData)

            return result
        } catch {
            return AWXCard(number: nil, expiryMonth: nil, expiryYear: nil, name: nil, cvc: nil, bin: nil, last4: nil, brand: nil, country: nil, funding: nil, fingerprint: nil, cvcCheck: nil, avsCheck: nil, numberType: nil)
        }
    }
}

@objc public extension AWXConfirmPaymentIntentResponse {
    static func decodeFromJSON(_ dic: [String: Any]) -> AWXConfirmPaymentIntentResponse {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let result = try JSONDecoder().decode(AWXConfirmPaymentIntentResponse.self, from: jsonData)

            return result
        } catch {
            return AWXConfirmPaymentIntentResponse(currency: nil, amount: nil, status: nil, nextAction: nil, latestPaymentAttempt: nil)
        }
    }
}

@objc public extension AWXDevice {
    static func decodeFromJSON(_ dic: [String: Any]) -> AWXDevice {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let result = try JSONDecoder().decode(AWXDevice.self, from: jsonData)

            return result
        } catch {
            return AWXDevice(deviceId: nil)
        }
    }
}

@objc public extension AWXPlaceDetails {
    static func decodeFromJSON(_ dic: [String: Any]) -> AWXPlaceDetails {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let result = try JSONDecoder().decode(AWXPlaceDetails.self, from: jsonData)

            return result
        } catch {
            return AWXPlaceDetails(firstName: nil, lastName: nil, email: nil, dateOfBirth: nil, phoneNumber: nil, address: nil)
        }
    }
}
