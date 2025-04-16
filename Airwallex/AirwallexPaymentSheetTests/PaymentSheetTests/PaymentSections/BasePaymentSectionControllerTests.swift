//
//  BasePaymentSectionControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/14.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet
import AirwallexCore

@MainActor class BasePaymentSectionControllerTests: XCTestCase {
    var mockShippingInfo: AWXPlaceDetails!
    var mockManager: CollectionViewManager<PaymentSectionType, String, MockPaymentSectionProvider>!
    var mockSectionProvider: MockPaymentSectionProvider!
    var mockMethodProvider: MockMethodProvider!
    var mockViewController: MockPaymentResultDelegate!
    
    override func setUp() {
        super.setUp()
        mockViewController = MockPaymentResultDelegate()
        mockMethodProvider = MockMethodProvider(methods: [], consents: [])
        mockSectionProvider = MockPaymentSectionProvider(methodProvider: mockMethodProvider)
      
        let shipping = AWXPlaceDetails()
        shipping.firstName = "John"
        shipping.lastName = "Appleseed"
        shipping.phoneNumber = "1234567890"
        shipping.email = "abc@123.com"
        let address = AWXAddress()
        address.countryCode = "AU"
        address.postcode = "postcode"
        address.street = "street"
        address.state = "state"
        address.city = "city"
        shipping.address = address
        mockShippingInfo = shipping
        mockMethodProvider.session.billing = shipping

        mockManager = CollectionViewManager(
            viewController: mockViewController,
            sectionProvider: mockSectionProvider
        )
        let collectionView = mockManager.collectionView
        collectionView?.frame = mockViewController.view.bounds
        mockViewController.view.addSubview(mockManager.collectionView)
        collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
    }
    
}
