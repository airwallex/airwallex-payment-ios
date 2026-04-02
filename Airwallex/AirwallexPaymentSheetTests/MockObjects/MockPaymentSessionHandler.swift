//
//  MockPaymentSessionHandler.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/2/27.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

/// Mock implementation of PaymentSessionHandlerProtocol for testing.
@MainActor
class MockPaymentSessionHandler: PaymentSessionHandlerProtocol {

    // MARK: - Protocol Properties

    var showIndicator: Bool = true

    // MARK: - Call Tracking

    var confirmCardPaymentCalled = false
    var confirmCardPaymentCard: AWXCard?
    var confirmCardPaymentBilling: AWXPlaceDetails?
    var confirmCardPaymentSaveCard: Bool?

    var confirmConsentPaymentCalled = false
    var confirmConsentPaymentConsent: AWXPaymentConsent?

    var confirmApplePayCalled = false

    var confirmRedirectPaymentCalled = false
    var confirmRedirectPaymentMethod: AWXPaymentMethod?

    // MARK: - Protocol Methods

    func confirmCardPayment(with card: AWXCard, billing: AWXPlaceDetails?, saveCard: Bool) {
        confirmCardPaymentCalled = true
        confirmCardPaymentCard = card
        confirmCardPaymentBilling = billing
        confirmCardPaymentSaveCard = saveCard
    }

    func confirmConsentPayment(with consent: AWXPaymentConsent) {
        confirmConsentPaymentCalled = true
        confirmConsentPaymentConsent = consent
    }

    func confirmApplePay() {
        confirmApplePayCalled = true
    }

    func confirmRedirectPayment(with paymentMethod: AWXPaymentMethod) async {
        confirmRedirectPaymentCalled = true
        confirmRedirectPaymentMethod = paymentMethod
    }

    // MARK: - Reset

    func reset() {
        showIndicator = true
        confirmCardPaymentCalled = false
        confirmCardPaymentCard = nil
        confirmCardPaymentBilling = nil
        confirmCardPaymentSaveCard = nil
        confirmConsentPaymentCalled = false
        confirmConsentPaymentConsent = nil
        confirmApplePayCalled = false
        confirmRedirectPaymentCalled = false
        confirmRedirectPaymentMethod = nil
    }
}

/// Mock factory that returns a MockPaymentSessionHandler for testing.
@MainActor
class MockPaymentSessionHandlerFactory: PaymentSessionHandlerFactory {

    var mockHandler: MockPaymentSessionHandler
    var createHandlerCalled = false
    var lastSession: AWXSession?
    var lastMethodType: AWXPaymentMethodType?

    init(mockHandler: MockPaymentSessionHandler? = nil) {
        self.mockHandler = mockHandler ?? MockPaymentSessionHandler()
    }

    func createHandler(
        session: AWXSession,
        methodType: AWXPaymentMethodType?,
        paymentUIContext: any PaymentUIContextProviding
    ) -> PaymentSessionHandlerProtocol {
        createHandlerCalled = true
        lastSession = session
        lastMethodType = methodType
        return mockHandler
    }

    func reset() {
        createHandlerCalled = false
        lastSession = nil
        lastMethodType = nil
        mockHandler.reset()
    }
}
