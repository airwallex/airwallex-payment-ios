//
//  UIStackViewExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

class UIStackViewExtensionTests: XCTestCase {
    
    func testInsertSpacer() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        let spacer = stackView.insertSpacer(10, at: 0)
        
        XCTAssertEqual(stackView.arrangedSubviews.first, spacer)
        XCTAssertEqual(spacer.constraints.count, 2)
        XCTAssertTrue(spacer.constraints.contains { $0.firstAttribute == .width && $0.constant == 10 })
    }
    
    func testInsertSpacerAtIndex() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        let view1 = UIView()
        let view2 = UIView()
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(view2)
        
        let spacer = stackView.insertSpacer(15, at: 1)
        
        XCTAssertEqual(stackView.arrangedSubviews[1], spacer)
        XCTAssertEqual(spacer.constraints.count, 2)
        XCTAssertTrue(spacer.constraints.contains { $0.firstAttribute == .width && $0.constant == 15 })
    }
    
    func testInsertSpacerWithPriority() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        let priority = UILayoutPriority.defaultHigh
        let spacer = stackView.insertSpacer(20, at: 0, priority: priority)
        
        XCTAssertEqual(stackView.arrangedSubviews.first, spacer)
        XCTAssertEqual(spacer.constraints.count, 2)
        XCTAssertTrue(spacer.constraints.contains { $0.firstAttribute == .width && $0.constant == 20 && $0.priority == priority })
    }
    
    func testInsertSpacerVertical() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        let spacer = stackView.insertSpacer(10, at: 0)
        
        XCTAssertEqual(stackView.arrangedSubviews.first, spacer)
        XCTAssertEqual(spacer.constraints.count, 2)
        XCTAssertTrue(spacer.constraints.contains { $0.firstAttribute == .height && $0.constant == 10 })
    }
    
    func testInsertSpacerAtIndexVertical() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        let view1 = UIView()
        let view2 = UIView()
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(view2)
        
        let spacer = stackView.insertSpacer(15, at: 1)
        
        XCTAssertEqual(stackView.arrangedSubviews[1], spacer)
        XCTAssertEqual(spacer.constraints.count, 2)
        XCTAssertTrue(spacer.constraints.contains { $0.firstAttribute == .height && $0.constant == 15 })
    }
    
    func testInsertSpacerWithPriorityVertical() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        let priority = UILayoutPriority.defaultHigh
        let spacer = stackView.insertSpacer(20, at: 0, priority: priority)
        
        XCTAssertEqual(stackView.arrangedSubviews.first, spacer)
        XCTAssertEqual(spacer.constraints.count, 2)
        XCTAssertTrue(spacer.constraints.contains { $0.firstAttribute == .height && $0.constant == 20 && $0.priority == priority })
    }
    
    func testAddSpacer() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        let spacer = stackView.addSpacer(10)
        
        XCTAssertEqual(stackView.arrangedSubviews.last, spacer)
        XCTAssertEqual(spacer.constraints.count, 2)
        XCTAssertTrue(spacer.constraints.contains { $0.firstAttribute == .width && $0.constant == 10 })
    }
    
    func testAddSpacerWithPriority() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        let priority = UILayoutPriority.defaultHigh
        let spacer = stackView.addSpacer(20, priority: priority)
        
        XCTAssertEqual(stackView.arrangedSubviews.last, spacer)
        XCTAssertEqual(spacer.constraints.count, 2)
        XCTAssertTrue(spacer.constraints.contains { $0.firstAttribute == .width && $0.constant == 20 && $0.priority == priority })
    }
    
    func testAddSpacerVertical() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        let spacer = stackView.addSpacer(10)
        
        XCTAssertEqual(stackView.arrangedSubviews.last, spacer)
        XCTAssertEqual(spacer.constraints.count, 2)
        XCTAssertTrue(spacer.constraints.contains { $0.firstAttribute == .height && $0.constant == 10 })
    }
    
    func testAddSpacerWithPriorityVertical() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        let priority = UILayoutPriority.defaultHigh
        let spacer = stackView.addSpacer(20, priority: priority)
        
        XCTAssertEqual(stackView.arrangedSubviews.last, spacer)
        XCTAssertEqual(spacer.constraints.count, 2)
        XCTAssertTrue(spacer.constraints.contains { $0.firstAttribute == .height && $0.constant == 20 && $0.priority == priority })
    }
}
