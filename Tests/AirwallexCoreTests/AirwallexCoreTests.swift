//
//  AirwallexCoreTests.swift
//  AirwallexPaymentSDK
//
//  Created by Weiping Li on 2024/12/5.
//

import XCTest
import AirwallexCore

final class AirwallexCoreTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        let bundle = Bundle.resource()
        XCTAssertNotNil(bundle)
        
        let image = UIImage(named: "close", in: bundle)
        XCTAssertNotNil(image)
    }
}
