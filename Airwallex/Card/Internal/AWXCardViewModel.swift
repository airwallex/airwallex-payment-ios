//
//  AWXCardViewModel.swift
//  Card
//
//  Created by Tony He (CTR) on 2024/7/25.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@objc public protocol AWXCardviewModelDelegate {
    @objc optional func startLoading()
    @objc optional func stopLoading()
    @objc func shouldDismiss(completeStatus status: AirwallexPaymentStatus, error: (any Error)?)
    @objc optional func didCompleteWithPaymentConsentId(_ id: String)
    @objc optional func shouldShowError(_ error: String)
    @objc func shouldPresent(_ controller: UIViewController?, forceToDismiss: Bool, withAnimation: Bool)
    @objc func shouldInsert(_ controller: UIViewController?)
}

@objcMembers
@objc
public class AWXCardViewModel: NSObject {
    public weak var delegate: AWXCardviewModelDelegate?
    public var isShowCardFlowDirectly = false

    public var ctaTitle: String {
        if session is AWXRecurringSession {
            return NSLocalizedString("Confirm", comment: "Confirm button title")
        } else {
            return NSLocalizedString("Pay", comment: "Pay button title")
        }
    }

    public let pageName: String = "card_payment_view"
    public var additionalInfo: [String: Any] {
        return ["supportedSchemes": supportedCardSchemes.map { $0.name }]
    }

    public private(set) var isReusingShippingAsBillingInformation: Bool = false
    public var isBillingInformationRequired: Bool {
        session?.isBillingInformationRequired ?? false
    }

    public var isCardSavingEnabled: Bool {
        session is AWXOneOffSession && session?.customerId() != nil
    }

    public var initialBilling: AWXPlaceDetails {
        session?.billing ?? AWXPlaceDetails(firstName: nil, lastName: nil, email: nil, dateOfBirth: nil, phoneNumber: nil, address: nil)
    }

    public var selectedCountry: AWXCountry?
    public var provider: AWXDefaultProvider?

    public let session: AWXSession?
    private var supportedCardSchemes: [AWXCardScheme] = []

    public init(session: AWXSession, supportedCardSchemes: [AWXCardScheme]) {
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
            throw NSError.errorForAirwallexSDK(with: NSLocalizedString("No shipping address configured.", comment: ""))
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

        let address = AWXAddress(countryCode: selectedCountry?.countryCode ?? "", city: city, street: street, state: state, postcode: postcode)
        return AWXPlaceDetails(firstName: firstName, lastName: lastName, email: email, dateOfBirth: nil, phoneNumber: phoneNumber, address: address)
    }

    public func makeCard(
        name: String,
        number: String,
        expiry: String,
        cvc: String
    ) -> AWXCard {
        let dates = expiry.split(separator: "/")
        return AWXCard(number: number.replacingOccurrences(of: " ", with: ""), expiryMonth: "\(dates.first ?? "")", expiryYear: "20\(dates.last ?? "")", name: name, cvc: cvc, bin: nil, last4: nil, brand: nil, country: nil, funding: nil, fingerprint: nil, cvcCheck: nil, avsCheck: nil, numberType: nil)
    }

    public func makeDisplayedCardBrands() -> [AWXCardBrand] {
        return AWXAllCardBrand().filter { cardBrand in
            supportedCardSchemes.map { $0.name }.contains(cardBrand.rawValue)
        }
    }

    private func validatedBillingDetails(_ billing: AWXPlaceDetails, error: inout String?)
        -> AWXPlaceDetails?
    {
        if let validationError = billing.validateAndReturnError() {
            error = validationError
            return nil
        } else {
            return billing
        }
    }

    private func validatedCardDetails(_ card: AWXCard, error: inout String?) -> AWXCard? {
        if let validationError = card.validateAndReturnError() {
            error = validationError
            return nil
        } else {
            return card
        }
    }

    public func validationMessageFromCardNumber(_ cardNumber: String) -> String? {
        if !cardNumber.isEmpty {
            if AWXCardValidator.shared.isValidCardLength(cardNumber) {
                let cardName = AWXCardValidator.shared.brandForCardNumber(cardNumber)?.name ?? ""
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

    public func preparedProviderWithDelegate() -> AWXCardProvider {
        let provider = AWXCardProvider(delegate: self, session: session ?? AWXSession())
        self.provider = provider
        return provider
    }

    public func actionProviderForNextAction(
        _: AWXConfirmPaymentNextAction, delegate: AWXProviderDelegate
    ) -> AWXDefaultActionProvider {
        return AWX3DSActionProvider(delegate: delegate, session: session ?? AWXSession())
    }

    public func confirmPayment(
        provider: AWXCardProvider, billing placeDetails: AWXPlaceDetails?, card: AWXCard,
        shouldStoreCardDetails storeCard: Bool
    ) throws {
        var validatedBilling: AWXPlaceDetails?
        if isBillingInformationRequired, placeDetails == nil {
            throw NSError.errorForAirwallexSDK(with: NSLocalizedString("No billing address provided.", comment: ""))
        } else if isBillingInformationRequired, let placeDetails {
            var billingValidationError: String?
            validatedBilling = validatedBillingDetails(placeDetails, error: &billingValidationError)
            if validatedBilling == nil {
                throw NSError.errorForAirwallexSDK(with: billingValidationError ?? "")
            }
        }

        var cardValidationError: String?
        if let validatedCard = validatedCardDetails(card, error: &cardValidationError) {
            provider.confirmPaymentIntent(with: validatedCard, billing: validatedBilling, saveCard: storeCard)
        } else {
            throw NSError.errorForAirwallexSDK(with: cardValidationError ?? "")
        }
    }

    private func updatePaymentIntentId(_: String) {}

    private func cardBrandFromCardScheme(_ cardScheme: AWXCardScheme) -> AWXCardBrand {
        return AWXCardBrand(rawValue: cardScheme.name)
    }
}

extension AWXCardViewModel: AWXProviderDelegate {
    public func providerDidStartRequest(_: AWXDefaultProvider) {
        logMessage("providerDidStartRequest:")
        delegate?.startLoading?()
    }

    public func providerDidEndRequest(_: AWXDefaultProvider) {
        logMessage("providerDidEndRequest:")
        delegate?.stopLoading?()
    }

    public func provider(
        _: AWXDefaultProvider, didCompleteWith status: AirwallexPaymentStatus,
        error: (any Error)?
    ) {
        logMessage(
            "provider:didCompleteWithStatus:error: \(status)  \(error?.localizedDescription ?? "")")

        delegate?.shouldDismiss(completeStatus: status, error: error)
    }

    public func provider(_: AWXDefaultProvider, didCompleteWithPaymentConsentId id: String) {
        delegate?.didCompleteWithPaymentConsentId?(id)
    }

    public func provider(
        _: AWXDefaultProvider, didInitializePaymentIntentId paymentIntentId: String
    ) {
        logMessage("provider:didInitializePaymentIntentId:  \(paymentIntentId)")
        updatePaymentIntentId(paymentIntentId)
    }

    public func provider(
        _: AWXDefaultProvider, shouldHandle nextAction: AWXConfirmPaymentNextAction
    ) {
        logMessage(
            "provider:shouldHandleNextAction:  type:\(nextAction.type ?? ""), stage: \(nextAction.stage ?? "")")
        let actionProvider = actionProviderForNextAction(nextAction, delegate: self)
        actionProvider.handle(nextAction)
        provider = actionProvider
    }

    public func provider(
        _: AWXDefaultProvider, shouldPresent controller: UIViewController?,
        forceToDismiss: Bool, withAnimation: Bool
    ) {
        delegate?.shouldPresent(controller, forceToDismiss: forceToDismiss, withAnimation: withAnimation)
    }

    public func provider(_: AWXDefaultProvider, shouldInsert controller: UIViewController?) {
        delegate?.shouldInsert(controller)
    }
}
