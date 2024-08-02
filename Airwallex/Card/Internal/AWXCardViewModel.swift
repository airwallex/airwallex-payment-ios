//
//  AWXCardViewModel.swift
//  Card
//
//  Created by Tony He (CTR) on 2024/7/25.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@objcMembers
@objc
public class AWXCardViewModel: NSObject {
    public var ctaTitle: String {
        if session is AWXRecurringSession {
            return NSLocalizedString("Confirm", comment: "Confirm button title")
        } else {
            return NSLocalizedString("Pay", comment: "Pay button title")
        }
    }

    public let pageName: String = "card_payment_view"

    public var isReusingShippingAsBillingInformation: Bool = false
    public var isBillingInformationRequired: Bool {
        session?.isBillingInformationRequired ?? false
    }

    public var isCardSavingEnabled: Bool {
        session is AWXOneOffSession && session?.customerId() != nil
    }

    public var initialBilling: AWXPlaceDetails {
        session?.billing ?? AWXPlaceDetails()
    }

    public var selectedCountry: AWXCountry?

    var session: AWXSession?
    var supportedCardSchemes: [AWXCardScheme] = []

    public init(session: AWXSession, supportedCardSchemes: [AWXCardScheme]) {
        super.init()
        self.session = session
        selectedCountry = AWXCountry.countryWithCode(session.billing?.address?.countryCode ?? "")
        isReusingShippingAsBillingInformation =
            session.billing != nil && session.isBillingInformationRequired
        self.supportedCardSchemes = supportedCardSchemes
    }

    public func setReusesShippingAsBillingInformation(_ reusesShippingAsBillingInformation: Bool)
        throws
    {
        if reusesShippingAsBillingInformation && session?.billing == nil {
            throw NSError.errorForAirwallexSDK(with: -1, localizedDescription: NSLocalizedString("No shipping address configured.", comment: ""))
        } else {
            isReusingShippingAsBillingInformation = reusesShippingAsBillingInformation
        }
    }

    public func makeBilling(
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String,
        state: String,
        city: String,
        street: String,
        postcode: String
    ) -> AWXPlaceDetails {
        if isReusingShippingAsBillingInformation, let billing = session?.billing {
            return billing
        }

        let place = AWXPlaceDetails()
        place.firstName = firstName
        place.lastName = lastName
        place.email = email
        place.phoneNumber = phoneNumber

        let address = AWXAddress()
        address.countryCode = selectedCountry?.countryCode ?? ""
        address.state = state
        address.city = city
        address.street = street
        address.postcode = postcode

        place.address = address
        return place
    }

    public func makeCard(
        name: String,
        number: String,
        expiry: String,
        cvc: String
    ) -> AWXCard {
        let dates = expiry.split(separator: "/")
        let card = AWXCard()
        card.name = name
        card.number = number.replacingOccurrences(of: " ", with: "")
        card.expiryYear = "20\(dates.last ?? "")"
        card.expiryMonth = "\(dates.first ?? "")"
        card.cvc = cvc

        return card
    }

    public func makeDisplayedCardBrands() -> [Any] {
        var cardBrands = [Any]()
        for brand in AWXCardSupportedBrands() {
            if let brandInt = brand as? Int {
                for cardScheme in supportedCardSchemes {
                    if cardBrandFromCardScheme(cardScheme).rawValue == brandInt {
                        cardBrands.append(brand)
                    }
                }
            }
        }
        return cardBrands
    }

    public func validatedBillingDetails(_ billing: AWXPlaceDetails, error: inout String?)
        -> AWXPlaceDetails?
    {
        if let validationError = billing.validate() {
            error = validationError
            return nil
        } else {
            return billing
        }
    }

    public func validatedCardDetails(_ card: AWXCard, error: inout String?) -> AWXCard? {
        if let validationError = card.validate() {
            error = validationError
            return nil
        } else {
            return card
        }
    }

    public func validationMessageFromCardNumber(_ cardNumber: String) -> String? {
        if !cardNumber.isEmpty {
            if AWXCardValidator.shared().isValidCardLength(cardNumber) {
                let cardName = AWXCardValidator.shared().brand(forCardNumber: cardNumber)?.name ?? ""
                for cardScheme in supportedCardSchemes {
                    if cardScheme.name == cardName.lowercased() {
                        return nil
                    }
                }
                return NSLocalizedString("Card not supported for payment", comment: "")
            }
            return NSLocalizedString("Card number is invalid", comment: "")
        }
        return NSLocalizedString("Card number is required", comment: "")
    }

    public func preparedProviderWithDelegate(_ delegate: AWXProviderDelegate) -> AWXCardProvider {
        AWXCardProvider(delegate: delegate, session: session ?? AWXSession())
    }

    public func actionProviderForNextAction(
        _: AWXConfirmPaymentNextAction, delegate: AWXProviderDelegate
    ) -> AWXDefaultActionProvider {
        let actionProvider = AWX3DSActionProvider(
            delegate: delegate, session: session ?? AWXSession()
        )
        return actionProvider
    }

    public func confirmPayment(
        provider: AWXCardProvider, billing placeDetails: AWXPlaceDetails?, card: AWXCard,
        shouldStoreCardDetails storeCard: Bool
    ) throws {
        var validatedBilling: AWXPlaceDetails?
        if isBillingInformationRequired, placeDetails == nil {
            throw NSError.errorForAirwallexSDK(with: -1, localizedDescription: NSLocalizedString("No billing address provided.", comment: ""))
        } else if isBillingInformationRequired, let placeDetails = placeDetails {
            var billingValidationError: String?
            validatedBilling = validatedBillingDetails(placeDetails, error: &billingValidationError)
            if validatedBilling == nil {
                throw NSError.errorForAirwallexSDK(with: -1, localizedDescription: billingValidationError ?? "")
            }
        }

        var cardValidationError: String?
        let validatedCard = validatedCardDetails(card, error: &cardValidationError)
        if validatedCard == nil {
            throw NSError.errorForAirwallexSDK(with: -1, localizedDescription: cardValidationError ?? "")
        }

        if let vCard = validatedCard {
            provider.confirmPaymentIntent(with: vCard, billing: validatedBilling, saveCard: storeCard)
        } else {
            throw NSError.errorForAirwallexSDK(with: -1, localizedDescription: NSLocalizedString("Invalid card or billing.", comment: ""))
        }
    }

    public func updatePaymentIntentId(_ paymentIntentId: String) {
        session?.updateInitialPaymentIntentId(paymentIntentId)
    }

    func cardBrandFromCardScheme(_ cardScheme: AWXCardScheme) -> AWXBrandType {
        switch cardScheme.name {
        case "amex":
            return AWXBrandTypeAmex
        case "mastercard":
            return AWXBrandTypeMastercard
        case "visa":
            return AWXBrandTypeVisa
        case "unionpay":
            return AWXBrandTypeUnionPay
        case "jcb":
            return AWXBrandTypeJCB
        case "diners":
            return AWXBrandTypeDinersClub
        case "discover":
            return AWXBrandTypeDiscover
        default:
            return AWXBrandTypeUnknown
        }
    }
}
