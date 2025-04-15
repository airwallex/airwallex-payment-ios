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
    
    func testInit() {
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = mockManager.sectionControllers[.schemaPayment("axs_kiosk")] else {
            XCTFail()
            return
        }
    }
}
