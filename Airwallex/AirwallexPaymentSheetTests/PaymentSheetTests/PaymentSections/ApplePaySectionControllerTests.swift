//
//  ApplePaySectionControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet
import AirwallexCore

@MainActor class ApplePaySectionControllerTests: BasePaymentSectionControllerTests {
    
    override func setUp() {
        super.setUp()
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey
        mockMethodProvider.methods = [applePayMethod]
    }
    
    func testInit() {
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        
        XCTAssertEqual([PaymentSectionType.applePay], mockManager.sections)
        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay] else {
            XCTFail("apple pay section controller not initialized")
            return
        }
        let items = [controller.identifier(for: ApplePaySectionController.Item.applePayButton)]
        XCTAssertEqual(items, mockManager.diffableDataSource.snapshot().itemIdentifiers)
        XCTAssertEqual(controller.section, PaymentSectionType.applePay)
        XCTAssertEqual(controller.items, items)
    }
    
    func testSupplementaryView() {
        let mockCardMethod = AWXPaymentMethodType()
        mockCardMethod.name = AWXCardKey
        mockMethodProvider.methods.append(mockCardMethod)
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        
        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay] else {
            XCTFail("apple pay section controller not initialized")
            return
        }
        let itemIdentifier = controller.identifier(for: ApplePaySectionController.Item.applePayButton)
        guard let indexPath = mockManager.diffableDataSource.indexPath(for: itemIdentifier) else {
            XCTFail()
            return
        }
        guard controller.context.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionFooter,
            at: indexPath
        ) != nil else {
            XCTFail()
            return
        }
    }
}
