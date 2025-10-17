//
//  ProviderFactory.swift
//  AirwallexPayment
//
//  Created by Weiping Li on 29/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Foundation

protocol ProviderFactoryProtocol {
    
    func applePayProvider(delegate: any AWXProviderDelegate,
                          session: AWXSession,
                          type: AWXPaymentMethodType?) -> ApplePayProviderProtocol
    
    func cardProvider(delegate: any AWXProviderDelegate,
                      session: AWXSession,
                      type: AWXPaymentMethodType?) -> CardProviderProtocol
    
    func redirectProvider(delegate: any AWXProviderDelegate,
                          session: AWXSession,
                          type: AWXPaymentMethodType?) -> RedirectProviderProtocol
}

final class ProviderFactory: ProviderFactoryProtocol {
    
    func applePayProvider(delegate: any AWXProviderDelegate,
                          session: AWXSession,
                          type: AWXPaymentMethodType?) -> ApplePayProviderProtocol {
        if let unifiedSession = Session(session) {
            // Simplified payment flow
            return ApplePayProvider(
                delegate: delegate,
                session: unifiedSession,
                methodType: type
            )
        } else {
            return AWXApplePayProvider(
                delegate: delegate,
                session: session,
                paymentMethodType: type
            )
        }
    }
    
    
    func cardProvider(delegate: any AWXProviderDelegate,
                      session: AWXSession,
                      type: AWXPaymentMethodType?) -> CardProviderProtocol {
        if let session = Session(session) {
            return CardProvider(
                delegate: delegate,
                session: session,
                methodType: type
            )
        } else {
            return AWXCardProvider(
                delegate: delegate,
                session: session,
                paymentMethodType: type
            )
        }
    }
    
    func redirectProvider(delegate: any AWXProviderDelegate,
                          session: AWXSession,
                          type: AWXPaymentMethodType?) -> RedirectProviderProtocol {
        let session = if let unifiedSession = session as? Session {
            // simplified consnet flow not yet supported by LPM
            unifiedSession.convertToLegacySession()
        } else {
            session
        }
        return AWXRedirectActionProvider(
            delegate: delegate,
            session: session,
            paymentMethodType: type
        )
    }
}

protocol ApplePayProviderProtocol: AWXDefaultProvider {
    func startPayment(cancelPaymentOnDismiss: Bool) throws
}

extension ApplePayProvider: ApplePayProviderProtocol {}

extension AWXApplePayProvider: ApplePayProviderProtocol {
    func startPayment(cancelPaymentOnDismiss: Bool) throws {
        try validate()
        if cancelPaymentOnDismiss {
            startPayment()
        } else {
            handleFlow()
        }
    }
}

protocol CardProviderProtocol: AWXDefaultProvider {
    
    func confirmIntentWithCard(_ card: AWXCard, billing: AWXPlaceDetails?, saveCard: Bool) async
    
    func confirmIntentWithConsent(_ consent: AWXPaymentConsent) async
    
    func confirmIntentWithConsent(_ consentId: String, requiresCVC: Bool) async
}

extension CardProvider: CardProviderProtocol {}

extension AWXCardProvider: CardProviderProtocol {
    func confirmIntentWithCard(_ card: AWXCard, billing: AWXPlaceDetails?, saveCard: Bool) async {
        await MainActor.run {
            confirmPaymentIntent(with: card, billing: billing, saveCard: saveCard)
        }
    }
    
    func confirmIntentWithConsent(_ consent: AWXPaymentConsent) async {
        await MainActor.run {
            confirmPaymentIntent(with: consent)
        }
    }
    
    func confirmIntentWithConsent(_ consentId: String, requiresCVC: Bool) async {
        await MainActor.run {
            confirmPaymentIntent(withPaymentConsentId: consentId)
        }
    }
}

protocol RedirectProviderProtocol: AWXDefaultProvider {
    func confirmPaymentIntent(with: String, additionalInfo: [String: String]?)
    
    func validate(name: String) throws
}

extension AWXRedirectActionProvider: RedirectProviderProtocol {}
