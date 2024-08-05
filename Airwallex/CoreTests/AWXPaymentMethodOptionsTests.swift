//
//  AWXPaymentMethodOptionsTests.swift
//  CoreTests
//
//  Created by Tony He (CTR) on 2024/7/31.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import XCTest

@testable import Core

class AWXPaymentMethodOptionsTests: XCTestCase {
    func testDecodeFromJSON() {
        let json: [String: Any] = [
            "card": [
                "auto_capture": true,
                "three_ds": [
                    "paRes": "somePaRes",
                    "return_url": "https://example.com/return",
                    "attemptId": "attempt123",
                    "deviceDataCollectionRes": "deviceData",
                    "dsTransactionId": "dsTransaction123",
                ],
            ],
        ]

        let paymentOptions = AWXPaymentMethodOptions.decodeFromJSON(json)

        XCTAssertNotNil(paymentOptions.cardOptions)
        XCTAssertEqual(paymentOptions.cardOptions?.autoCapture, true)

        let threeDs = paymentOptions.cardOptions?.threeDs
        XCTAssertEqual(threeDs?.paRes, "somePaRes")
        XCTAssertEqual(threeDs?.returnURL, "https://example.com/return")
        XCTAssertEqual(threeDs?.attemptId, "attempt123")
        XCTAssertEqual(threeDs?.deviceDataCollectionRes, "deviceData")
        XCTAssertEqual(threeDs?.dsTransactionId, "dsTransaction123")
    }

    func testEncodeToJSON() {
        let threeDs = AWXThreeDs()
        threeDs.returnURL = "https://example.com/return"
        threeDs.setValue("somePaRes", forKey: "paRes")
        threeDs.setValue("attempt123", forKey: "attemptId")
        threeDs.setValue("deviceData", forKey: "deviceDataCollectionRes")
        threeDs.setValue("dsTransaction123", forKey: "dsTransactionId")

        let cardOptions = AWXCardOptions()
        cardOptions.autoCapture = true
        cardOptions.threeDs = threeDs

        let paymentOptions = AWXPaymentMethodOptions()
        paymentOptions.cardOptions = cardOptions

        let json = paymentOptions.encodeToJSON()

        let expectedJson: [String: Any] = [
            "card": [
                "auto_capture": true,
                "three_ds": [
                    "paRes": "somePaRes",
                    "return_url": "https://example.com/return",
                    "attemptId": "attempt123",
                    "deviceDataCollectionRes": "deviceData",
                    "dsTransactionId": "dsTransaction123",
                ],
            ],
        ]

        XCTAssertEqual(json as NSDictionary, expectedJson as NSDictionary)
    }
}
