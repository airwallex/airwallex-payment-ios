//
//  AccordionPaymentSectionControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/14.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet
import AirwallexCore

class AccordionPaymentSectionControllerTests: BasePaymentSectionControllerTests {
    
    private let mockMethodNames = [ "axs_kiosk", "alipaycn", AWXCardKey, "atome", "wechatpay"]
    
    override func setUp() {
        super.setUp()
        mockSectionProvider.layout = .accordion
        let data = Bundle.dataOfFile("method_types")!
        let methodTypesResponse = AWXGetPaymentMethodTypesResponse.parse(data) as! AWXGetPaymentMethodTypesResponse
        var methodTypes = [AWXPaymentMethodType]()
        for name in mockMethodNames {
            if let methodType = methodTypesResponse.items.first(where: { $0.name == name }) {
                methodTypes.append(methodType)
            }
        }
        mockMethodProvider.methods = methodTypes
    }
    
    func testMethodsForAccordionPosition() {
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = mockManager.sectionControllers[PaymentSectionType.accordion(.top)] else {
            XCTFail()
            return
        }
        XCTAssertNil(mockManager.sectionControllers[PaymentSectionType.accordion(.bottom)])
        XCTAssertEqual(sectionController.items, mockMethodNames.map { sectionController.identifier(for: $0) })
    }
    
    func testMethodsForAccordionPosition_withSelectedMethod() {
        mockMethodProvider.selectedMethod = mockMethodProvider.method(named: AWXCardKey)
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let accordionTop = mockManager.sectionControllers[PaymentSectionType.accordion(.top)] else {
            XCTFail()
            return
        }
        guard let accordionBot = mockManager.sectionControllers[PaymentSectionType.accordion(.bottom)] else {
            XCTFail()
            return
        }
        
        let index = mockMethodNames.firstIndex(of: AWXCardKey)!
        XCTAssertEqual(accordionTop.items, Array(mockMethodNames[..<index].map { accordionTop.identifier(for: $0) }))
        XCTAssertEqual(accordionBot.items, Array(mockMethodNames[(index+1)...].map { accordionBot.identifier(for: $0) }))
    }
    
    func testHandleUserSelection() {
        mockManager.performUpdates()
        XCTAssertEqual(mockManager.sections, [PaymentSectionType.accordion(.top)])
        guard let accordionTop = mockManager.sectionControllers[PaymentSectionType.accordion(.top)] else {
            XCTFail()
            return
        }
        accordionTop.collectionView(didSelectItem: accordionTop.identifier(for: AWXCardKey), at: IndexPath())
        mockManager.performUpdates()
        XCTAssertEqual(mockManager.sections, [PaymentSectionType.accordion(.top), PaymentSectionType.cardPaymentNew, PaymentSectionType.accordion(.bottom)])
    }
}
