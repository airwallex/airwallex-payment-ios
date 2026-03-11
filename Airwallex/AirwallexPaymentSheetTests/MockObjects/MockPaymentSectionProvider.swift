//
//  MockPaymentSectionProvider.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable @_spi(AWX) import AirwallexPayment
@testable import AirwallexPaymentSheet
import UIKit
import XCTest

@MainActor class MockPaymentSectionProvider {

    var layout = AWXUIContext.PaymentLayout.tab
    var preferConsentPayment = true

    var methodProvider: PaymentMethodProvider

    let paymentUIContext = PaymentSheetUIContext()

    /// Mock factory for testing checkout flows
    var mockHandlerFactory: MockPaymentSessionHandlerFactory?

    /// Holds a strong reference to the payment element for embedded mode testing
    private var embeddedElement: AWXPaymentElement?

    init(methodProvider: PaymentMethodProvider) {
        self.methodProvider = methodProvider
    }

    /// Configures the payment UI context with a mock handler factory for testing checkout.
    /// Call this before performUpdates() to inject the mock into section controllers.
    func configureMockHandlerFactory() -> MockPaymentSessionHandlerFactory {
        let factory = MockPaymentSessionHandlerFactory()
        mockHandlerFactory = factory
        paymentUIContext.paymentSessionHandlerFactory = factory
        return factory
    }

    /// Simulates embedded mode by creating a payment element.
    /// This sets `paymentUIContext.isEmbedded` to `true`.
    func simulateEmbeddedMode(delegate: AWXPaymentElementDelegate? = nil) {
        let mockDelegate = delegate ?? MockPaymentResultDelegate()
        let element = AWXPaymentElement(
            methodProvider: methodProvider,
            delegate: mockDelegate
        )
        // Store strong reference to prevent deallocation (paymentElement is weak)
        embeddedElement = element
        paymentUIContext.paymentElement = element
    }

    // status
    var actionCalled = false
}

extension MockPaymentSectionProvider: CollectionViewSectionProvider {
    
    private var displayMethodList: Bool {
        return layout == .tab && methodProvider.methods.count > (methodProvider.isApplePayAvailable ? 1 : 0)
    }
    
    func sections() -> [PaymentSectionType] {
        var sections = [PaymentSectionType]()
        switch layout {
        case .tab:

            if methodProvider.isApplePayAvailable {
                sections.append(.applePay)
            }
            
            if displayMethodList {
                // horizontal list
                sections.append(.methodList)
            }
            //  display selected payment method
            if let selectedMethodType = methodProvider.selectedMethod {
                if selectedMethodType.name == AWXCardKey {
                    if preferConsentPayment && !methodProvider.consents.isEmpty {
                        sections.append(.cardPaymentConsent)
                    } else {
                        sections.append(.cardPaymentNew)
                    }
                } else if selectedMethodType.hasSchema {
                    sections.append(.schemaPayment(selectedMethodType.name))
                }
            }
        case .accordion:
            if !paymentUIContext.isEmbedded &&
                methodProvider.isApplePayAvailable &&
                methodProvider.selectedMethod?.name != AWXApplePayKey {
                // Add applepay for payment sheet
                sections.append(.applePay)
            }

            if !methodProvider.methodsForAccordionPosition(.top).isEmpty {
                sections.append(.accordion(.top))
            }
            
            if let selectedMethodType = methodProvider.selectedMethod {
                if selectedMethodType.name == AWXApplePayKey {
                    // Add applepay for embedded element
                    sections.append(.applePay)
                } else if selectedMethodType.name == AWXCardKey {
                    if preferConsentPayment && !methodProvider.consents.isEmpty {
                        sections.append(.cardPaymentConsent)
                    } else {
                        sections.append(.cardPaymentNew)
                    }
                } else if selectedMethodType.hasSchema {
                    sections.append(.schemaPayment(selectedMethodType.name))
                }
            }
            
            if !methodProvider.methodsForAccordionPosition(.bottom).isEmpty {
                sections.append(.accordion(.bottom))
            }
        }
        return sections
    }
    
    func sectionController(for section: PaymentSectionType) -> AnySectionController<PaymentSectionType, String> {
        // Update paymentUIContext.layout before creating section controllers
        paymentUIContext.layout = layout

        switch section {
        case .applePay:
            let controller = ApplePaySectionController(
                session: methodProvider.session,
                methodType: methodProvider.applePayMethodType!,
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext
            )
            return controller.anySectionController()
        case .methodList:
            let controller = PaymentMethodTabSectionController(
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext
            )
            return controller.anySectionController()
        case .cardPaymentConsent:
            let controller = CardPaymentConsentSectionController(
                methodType: methodProvider.method(named: AWXCardKey)!,
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext,
                addNewCardAction: { [weak self] in
                    guard let self else { return }
                    self.preferConsentPayment = false
                    self.actionCalled = true
                }
            )
            return controller.anySectionController()
        case .cardPaymentNew:
            let controller = NewCardPaymentSectionController(
                cardPaymentMethod: methodProvider.selectedMethod!,
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext,
                switchToConsentPaymentAction: { [weak self] in
                    guard let self else { return }
                    self.preferConsentPayment = true
                    self.actionCalled = true
                }
            ).anySectionController()
            return controller
        case .schemaPayment(let name):
            let controller = SchemaPaymentSectionController(
                methodType: methodProvider.method(named: name)!,
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext
            ).anySectionController()
            return controller
        case .accordion(let position):
            return AccordionSectionController(
                position: position,
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext
            ).anySectionController()
        default:
            XCTFail("not expected")
            fatalError()
        }
    }
    
    func listBoundaryItemProviders() -> [BoundarySupplementaryItemProvider]? {
        return nil
    }
}
