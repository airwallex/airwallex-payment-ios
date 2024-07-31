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
            "cardOptions": [
                "autoCapture": true,
                "threeDs": [
                    "paRes": "somePaRes",
                    "returnURL": "https://example.com/return",
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
        threeDs.paRes = "somePaRes"
        threeDs.returnURL = "https://example.com/return"
        threeDs.attemptId = "attempt123"
        threeDs.deviceDataCollectionRes = "deviceData"
        threeDs.dsTransactionId = "dsTransaction123"

        let cardOptions = AWXCardOptions()
        cardOptions.autoCapture = true
        cardOptions.threeDs = threeDs

        let paymentOptions = AWXPaymentMethodOptions()
        paymentOptions.cardOptions = cardOptions

        let json = paymentOptions.encodeToJSON()

        let expectedJson: [String: Any] = [
            "cardOptions": [
                "autoCapture": true,
                "threeDs": [
                    "paRes": "somePaRes",
                    "returnURL": "https://example.com/return",
                    "attemptId": "attempt123",
                    "deviceDataCollectionRes": "deviceData",
                    "dsTransactionId": "dsTransaction123",
                ],
            ],
        ]

        XCTAssertEqual(json as NSDictionary, expectedJson as NSDictionary)
    }
}
