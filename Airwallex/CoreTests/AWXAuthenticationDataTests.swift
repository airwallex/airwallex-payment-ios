//
//  AWXAuthenticationDataTests.swift
//  CoreTests
//
//  Created by Tony He (CTR) on 2024/7/31.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import XCTest

@testable import Core

class AWXAuthenticationDataTests: XCTestCase {
    func testIsThreeDSVersion2ReturnsTrue() {
        // Given
        let dsData = AWXAuthenticationDataDsData()
        dsData.version = "2.1.0"

        let authenticationData = AWXAuthenticationData()
        authenticationData.dsData = dsData

        // When
        let isThreeDSVersion2 = authenticationData.isThreeDSVersion2()

        // Then
        XCTAssertTrue(isThreeDSVersion2)
    }

    func testIsThreeDSVersion2ReturnsFalseForVersion1() {
        // Given
        let dsData = AWXAuthenticationDataDsData()
        dsData.version = "1.0.0"

        let authenticationData = AWXAuthenticationData()
        authenticationData.dsData = dsData

        // When
        let isThreeDSVersion2 = authenticationData.isThreeDSVersion2()

        // Then
        XCTAssertFalse(isThreeDSVersion2)
    }

    func testIsThreeDSVersion2ReturnsFalseForNilVersion() {
        // Given
        let authenticationData = AWXAuthenticationData()
        authenticationData.dsData = nil

        // When
        let isThreeDSVersion2 = authenticationData.isThreeDSVersion2()

        // Then
        XCTAssertFalse(isThreeDSVersion2)
    }
}
