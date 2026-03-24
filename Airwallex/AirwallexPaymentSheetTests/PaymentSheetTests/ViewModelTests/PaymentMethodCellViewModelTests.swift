//
//  PaymentMethodCellViewModelTests.swift
//  AirwallexPaymentSheetTests
//
//  Created on 2025/2/4.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPaymentSheet
import UIKit
import XCTest

class PaymentMethodCellViewModelTests: XCTestCase {

    private var mockImageLoader: ImageLoader!

    override func setUp() {
        super.setUp()
        mockImageLoader = ImageLoader()
    }

    // MARK: - placeholder Tests

    func testPlaceholder_ForCard_ReturnsImage() {
        let viewModel = PaymentMethodCellViewModel(
            name: AWXCardKey,
            displayName: "Credit Card",
            imageURL: nil,
            isSelected: false,
            imageLoader: mockImageLoader,
            cardBrands: []
        )

        XCTAssertNotNil(viewModel.placeholder)
    }

    func testPlaceholder_ForApplePay_ReturnsImage() {
        let viewModel = PaymentMethodCellViewModel(
            name: AWXApplePayKey,
            displayName: "Apple Pay",
            imageURL: nil,
            isSelected: false,
            imageLoader: mockImageLoader,
            cardBrands: []
        )

        XCTAssertNotNil(viewModel.placeholder)
    }

    func testPlaceholder_ForUnknownMethod_ReturnsNil() {
        let viewModel = PaymentMethodCellViewModel(
            name: "alipaycn",
            displayName: "Alipay China",
            imageURL: nil,
            isSelected: false,
            imageLoader: mockImageLoader,
            cardBrands: []
        )

        XCTAssertNil(viewModel.placeholder)
    }
}
