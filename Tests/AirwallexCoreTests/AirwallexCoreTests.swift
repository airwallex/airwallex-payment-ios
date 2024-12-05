//
//  Test.swift
//  AirWallexPaymentSDK
//
//  Created by Weiping Li on 2024/12/5.
//

import Testing
import AirwallexCore
import UIKit
import Foundation

struct AirwallexCoreTests {

    @Test func testPackageBundle() async throws {
        let bundle = Bundle.resource()
        #expect(bundle != nil)
        
        let image = UIImage(named: "close", in: bundle)
        #expect(image != nil)
    }

}
