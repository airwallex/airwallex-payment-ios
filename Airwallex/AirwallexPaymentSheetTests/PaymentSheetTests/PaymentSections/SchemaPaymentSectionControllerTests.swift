//
//  SchemaPaymentSectionControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/15.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet
@testable @_spi(AWX) import AirwallexPayment
import AirwallexCore

class SchemaPaymentSectionControllerTests: BasePaymentSectionControllerTests {

    
    var mockSchemaMethod: AWXPaymentMethodType!
    override func setUp() {
        super.setUp()
        
        mockSchemaMethod = AWXPaymentMethodType()
        mockSchemaMethod.name = "axs_kiosk"
        mockSchemaMethod.displayName = "AXS Kiosk"
        mockSchemaMethod.resources = AWXResources()
        mockSchemaMethod.resources.hasSchema = true
        
        let mockAXSKioskData = Bundle.dataOfFile("method_type_axs_kiosk")!
        let methodDetails = AWXGetPaymentMethodTypeResponse.parse(mockAXSKioskData) as! AWXGetPaymentMethodTypeResponse
        mockMethodProvider.mockSchemaDetails = methodDetails
        mockMethodProvider.methods = [mockSchemaMethod]
        mockMethodProvider.selectedMethod = mockSchemaMethod
    }
    
    private func getSchemaPaymentSectionController() -> SchemaPaymentSectionController? {
        guard let sectionController = mockManager.sectionControllers[.schemaPayment("axs_kiosk")]?.embededSectionController as? SchemaPaymentSectionController else {
            XCTFail()
            return nil
        }
        return sectionController
    }
    
    func testInit() async {
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getSchemaPaymentSectionController() else { return }
        XCTAssertEqual(sectionController.section, .schemaPayment("axs_kiosk"))
        XCTAssertEqual(sectionController.layout, .tab)
        try? await Task.sleep(nanoseconds: 10_000)
        XCTAssert(sectionController.items.contains("shopper_name"))
        XCTAssert(sectionController.items.contains("shopper_email"))
        XCTAssert(sectionController.items.contains("shopper_phone"))
        mockViewController.view.layoutIfNeeded()
        guard let cell = sectionController.context.cellForItem("shopper_name") else {
            XCTFail()
            return
        }
    }
    
    func testInit_Accordionlayout() async {
        mockSectionProvider.layout = .accordion
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getSchemaPaymentSectionController() else { return }
        XCTAssertEqual(sectionController.section, .schemaPayment("axs_kiosk"))
        XCTAssertEqual(sectionController.layout, .accordion)
        try? await Task.sleep(nanoseconds: 10_000)
        XCTAssert(sectionController.items.contains(SchemaPaymentSectionController.Item.accordionKey))
        mockViewController.view.layoutIfNeeded()
        guard let cell = sectionController.context.cellForItem(SchemaPaymentSectionController.Item.accordionKey) as? AccordionPaymentMethodCell else {
            XCTFail()
            return
        }
        XCTAssert(cell.viewModel?.isSelected == true)
    }
}
