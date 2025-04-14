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

@MainActor class BasePaymentSectionControllerTests: XCTestCase {

    var mockManager: CollectionViewManager<PaymentSectionType, String, MockPaymentSectionProvider>!
    var mockSectionProvider: MockPaymentSectionProvider!
    var mockMethodProvider: MockMethodProvider!
    var mockViewController: MockPaymentResultDelegate!
    
    override func setUp() {
        super.setUp()
        mockViewController = MockPaymentResultDelegate()
        mockMethodProvider = MockMethodProvider(methods: [], consents: [])
        mockSectionProvider = MockPaymentSectionProvider(methodProvider: mockMethodProvider)
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
