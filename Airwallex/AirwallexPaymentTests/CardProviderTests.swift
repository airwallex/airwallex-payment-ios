//
//  CardProviderTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 28/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
import UIKit
import XCTest

//class CardProviderTests: XCTestCase {
//
//    func testInit() {
//        
//    }
//    
//    func testCanHandleSession() {
//        
//    }
//    
//    func testConfirmIntentWithCard() {
//        
//    }
//    
//    func testConfirmIntentAndSaveCard() {
//        
//    }
//    
//    func testConfirmIntentWithConsent() {
//        
//    }
//    
//    func testCreateRequestForConfirmSubsequentTransaction() {
//        // Create a provider
//        let provider = CardProvider(
//            delegate: mockDelegate,
//            session: mockSession,
//            methodType: mockMethodType
//        )
//        
//        // Create parameters for subsequent transaction
//        let consentId = "test_consent_id"
//        let cvc = "123"
//        
//        // Test creating request for subsequent transaction
//        let request = provider.createRequestForConfirmSubsequentTransaction(consentId: consentId, cvc: cvc)
//        
//        // Verify request is correctly configured
//        XCTAssertEqual(request.intentId, mockPaymentIntent.id)
//        XCTAssertEqual(request.customerId, mockPaymentIntent.customerId)
//        XCTAssertNotNil(request.paymentMethod)
//        XCTAssertEqual(request.paymentMethod?.type, AWXCardKey)
//        XCTAssertNotNil(request.paymentMethod?.card)
//        XCTAssertEqual(request.paymentMethod?.card?.cvc, cvc)
//        XCTAssertNotNil(request.device)
//        XCTAssertEqual(request.returnURL, AWXThreeDSReturnURL)
//    }
//    
//    func testCreateRequestForConfirmSubsequentTransactionWithoutCVC() {
//        // Create a provider
//        let provider = PaymentProvider(
//            delegate: mockDelegate,
//            session: mockSession,
//            methodType: mockMethodType
//        )
//        
//        // Create parameters for subsequent transaction without CVC
//        let consentId = "test_consent_id"
//        
//        // Test creating request for subsequent transaction without CVC
//        let request = provider.createRequestForConfirmSubsequentTransaction(consentId: consentId, cvc: nil)
//        
//        // Verify request is correctly configured
//        XCTAssertEqual(request.intentId, mockPaymentIntent.id)
//        XCTAssertEqual(request.customerId, mockPaymentIntent.customerId)
//        XCTAssertNotNil(request.paymentMethod)
//        XCTAssertEqual(request.paymentMethod?.type, AWXCardKey)
//        XCTAssertNil(request.paymentMethod?.card)
//        XCTAssertNotNil(request.device)
//        XCTAssertEqual(request.returnURL, AWXThreeDSReturnURL)
//    }
//    
//    func testCreateRequestForConfirmConsentConversion() {
//        // Create a provider
//        let provider = PaymentProvider(
//            delegate: mockDelegate,
//            session: mockSession,
//            methodType: mockMethodType
//        )
//        
//        // Create parameters for consent conversion
//        let methodId = "test_method_id"
//        let cvc = "123"
//        
//        // Test creating request for consent conversion
//        let request = provider.createRequestForConfirmConsentConversion(methodId: methodId, cvc: cvc)
//        
//        // Verify request is correctly configured
//        XCTAssertEqual(request.intentId, mockPaymentIntent.id)
//        XCTAssertEqual(request.customerId, mockPaymentIntent.customerId)
//        XCTAssertNotNil(request.paymentMethod)
//        XCTAssertEqual(request.paymentMethod?.type, AWXCardKey)
//        XCTAssertEqual(request.paymentMethod?.id, methodId)
//        XCTAssertNotNil(request.paymentMethod?.card)
//        XCTAssertEqual(request.paymentMethod?.card?.cvc, cvc)
//        XCTAssertNotNil(request.device)
//        XCTAssertEqual(request.returnURL, AWXThreeDSReturnURL)
//    }
//}
