//
//  CGFloatExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

class CGFloatExtensionTests: XCTestCase {
    
    func testRadiusValues() {
        XCTAssertEqual(CGFloat.radius_s, 2)
        XCTAssertEqual(CGFloat.radius_m, 4)
        XCTAssertEqual(CGFloat.radius_l, 6)
    }
    
    func testUIEdgeInsets() {
        let insets1 = UIEdgeInsets(horizontal: 10, vertical: 20)
        XCTAssertEqual(insets1.top, 20)
        XCTAssertEqual(insets1.left, 10)
        XCTAssertEqual(insets1.bottom, -20)
        XCTAssertEqual(insets1.right, 10)
        
        let insets2 = UIEdgeInsets(inset: 15)
        XCTAssertEqual(insets2.top, 15)
        XCTAssertEqual(insets2.left, 15)
        XCTAssertEqual(insets2.bottom, -15)
        XCTAssertEqual(insets2.right, -15)
    }
    
    func testNSDirectionalEdgeInsets() {
        let insets1 = NSDirectionalEdgeInsets(horizontal: 10, vertical: 20)
        XCTAssertEqual(insets1.top, 20)
        XCTAssertEqual(insets1.leading, 10)
        XCTAssertEqual(insets1.bottom, 20)
        XCTAssertEqual(insets1.trailing, 10)
        
        let insets2 = NSDirectionalEdgeInsets(inset: 15)
        XCTAssertEqual(insets2.top, 15)
        XCTAssertEqual(insets2.leading, 15)
        XCTAssertEqual(insets2.bottom, 15)
        XCTAssertEqual(insets2.trailing, 15)
    }
    
    func testUIEdgeInsetsFunctions() {
        var insets = UIEdgeInsets(top: 10, left: 10, bottom: -10, right: 10)
        
        insets = insets.horizontal(20)
        XCTAssertEqual(insets.left, 20)
        XCTAssertEqual(insets.right, -20)
        
        insets = insets.vertical(30)
        XCTAssertEqual(insets.top, 30)
        XCTAssertEqual(insets.bottom, -30)
        
        insets = insets.top(40)
        XCTAssertEqual(insets.top, 40)
        
        insets = insets.bottom(50)
        XCTAssertEqual(insets.bottom, -50)
        
        insets = insets.left(60)
        XCTAssertEqual(insets.left, 60)
        
        insets = insets.right(70)
        XCTAssertEqual(insets.right, -70)
    }
    
    func testNSDirectionalEdgeInsetsFunctions() {
        var insets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        insets = insets.horizontal(20)
        XCTAssertEqual(insets.leading, 20)
        XCTAssertEqual(insets.trailing, 20)
        
        insets = insets.vertical(30)
        XCTAssertEqual(insets.top, 30)
        XCTAssertEqual(insets.bottom, 30)
        
        insets = insets.top(40)
        XCTAssertEqual(insets.top, 40)
        
        insets = insets.bottom(50)
        XCTAssertEqual(insets.bottom, 50)
        
        insets = insets.leading(60)
        XCTAssertEqual(insets.leading, 60)
        
        insets = insets.trailing(70)
        XCTAssertEqual(insets.trailing, 70)
    }
}
