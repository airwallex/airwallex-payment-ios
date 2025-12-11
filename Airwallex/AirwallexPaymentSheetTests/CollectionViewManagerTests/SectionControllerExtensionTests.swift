//
//  SectionControllerExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/12/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

@MainActor
class SectionControllerExtensionTests: XCTestCase {

    // MARK: - Test Helper Section Controller

    enum TestSection: Hashable, Sendable {
        case simple
        case withParameter(String)
    }

    enum TestItem: String {
        case item1
        case item2
        case item3
    }

    class TestSectionController: SectionController {
        var context: CollectionViewContext<TestSection, String>!
        let section: TestSection
        var items: [String] = []

        init(section: TestSection) {
            self.section = section
        }

        func bind(context: CollectionViewContext<TestSection, String>) {
            self.context = context
        }

        func cell(for item: String, at indexPath: IndexPath) -> UICollectionViewCell {
            return UICollectionViewCell()
        }

        func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            return NSCollectionLayoutSection(
                group: NSCollectionLayoutGroup.horizontal(
                    layoutSize: size,
                    subitems: [NSCollectionLayoutItem(layoutSize: size)]
                )
            )
        }
    }

    // MARK: - Tests for identifier<T: RawRepresentable<String>>(for:)

    func testIdentifierWithRawRepresentable_simpleSection() {
        let controller = TestSectionController(section: .simple)

        let identifier = controller.identifier(for: TestItem.item1)

        XCTAssertEqual(identifier, "simple-item1")
    }

    func testIdentifierWithRawRepresentable_multiplItems() {
        let controller = TestSectionController(section: .simple)

        let identifier1 = controller.identifier(for: TestItem.item1)
        let identifier2 = controller.identifier(for: TestItem.item2)
        let identifier3 = controller.identifier(for: TestItem.item3)

        XCTAssertEqual(identifier1, "simple-item1")
        XCTAssertEqual(identifier2, "simple-item2")
        XCTAssertEqual(identifier3, "simple-item3")
    }

    func testIdentifierWithRawRepresentable_sectionWithParameter() {
        let controller = TestSectionController(section: .withParameter("test"))

        let identifier = controller.identifier(for: TestItem.item1)

        XCTAssertEqual(identifier, "withParameter(\"test\")-item1")
    }

    // MARK: - Tests for identifier(for: String)

    func testIdentifierWithString_simpleSection() {
        let controller = TestSectionController(section: .simple)

        let identifier = controller.identifier(for: "customItem")

        XCTAssertEqual(identifier, "simple-customItem")
    }

    func testIdentifierWithString_emptyString() {
        let controller = TestSectionController(section: .simple)

        let identifier = controller.identifier(for: "")

        XCTAssertEqual(identifier, "simple-")
    }

    func testIdentifierWithString_specialCharacters() {
        let controller = TestSectionController(section: .simple)

        let identifier = controller.identifier(for: "item-with-dashes")

        XCTAssertEqual(identifier, "simple-item-with-dashes")
    }

    func testIdentifierWithString_sectionWithParameter() {
        let controller = TestSectionController(section: .withParameter("payment"))

        let identifier = controller.identifier(for: "card")

        XCTAssertEqual(identifier, "withParameter(\"payment\")-card")
    }

    // MARK: - Tests for rawItemValue(for:)

    func testRawItemValue_validIdentifier() {
        let controller = TestSectionController(section: .simple)

        let rawValue = controller.rawItemValue(for: "simple-item1")

        XCTAssertEqual(rawValue, "item1")
    }

    func testRawItemValue_invalidPrefix() {
        let controller = TestSectionController(section: .simple)

        let rawValue = controller.rawItemValue(for: "other-item1")

        XCTAssertNil(rawValue)
    }

    func testRawItemValue_noPrefix() {
        let controller = TestSectionController(section: .simple)

        let rawValue = controller.rawItemValue(for: "item1")

        XCTAssertNil(rawValue)
    }

    func testRawItemValue_emptyAfterPrefix() {
        let controller = TestSectionController(section: .simple)

        let rawValue = controller.rawItemValue(for: "simple-")

        XCTAssertEqual(rawValue, "")
    }

    func testRawItemValue_sectionWithParameter() {
        let controller = TestSectionController(section: .withParameter("test"))

        let rawValue = controller.rawItemValue(for: "withParameter(\"test\")-item1")

        XCTAssertEqual(rawValue, "item1")
    }

    func testRawItemValue_complexRawValue() {
        let controller = TestSectionController(section: .simple)

        let rawValue = controller.rawItemValue(for: "simple-item-with-dashes")

        XCTAssertEqual(rawValue, "item-with-dashes")
    }

    // MARK: - Tests for prefix property

    func testPrefix_simpleSection() {
        let controller = TestSectionController(section: .simple)

        // Access prefix indirectly through identifier
        let identifier = controller.identifier(for: "")

        XCTAssertEqual(identifier, "simple-")
    }

    func testPrefix_sectionWithParameter() {
        let controller = TestSectionController(section: .withParameter("test"))

        // Access prefix indirectly through identifier
        let identifier = controller.identifier(for: "")

        XCTAssertEqual(identifier, "withParameter(\"test\")-")
    }

    func testPrefix_consistencyAcrossMultipleCalls() {
        let controller = TestSectionController(section: .simple)

        let identifier1 = controller.identifier(for: "item1")
        let identifier2 = controller.identifier(for: "item2")

        // Both should have the same prefix
        XCTAssertTrue(identifier1.hasPrefix("simple-"))
        XCTAssertTrue(identifier2.hasPrefix("simple-"))
    }

    // MARK: - Integration Tests

    func testRoundTrip_rawRepresentableToIdentifierAndBack() {
        let controller = TestSectionController(section: .simple)

        let identifier = controller.identifier(for: TestItem.item1)
        let rawValue = controller.rawItemValue(for: identifier)

        XCTAssertEqual(rawValue, TestItem.item1.rawValue)
    }

    func testRoundTrip_stringToIdentifierAndBack() {
        let controller = TestSectionController(section: .simple)
        let originalString = "customItem"

        let identifier = controller.identifier(for: originalString)
        let extractedValue = controller.rawItemValue(for: identifier)

        XCTAssertEqual(extractedValue, originalString)
    }

    func testUniqueIdentifiers_acrossDifferentSections() {
        let controller1 = TestSectionController(section: .simple)
        let controller2 = TestSectionController(section: .withParameter("test"))

        let identifier1 = controller1.identifier(for: TestItem.item1)
        let identifier2 = controller2.identifier(for: TestItem.item1)

        XCTAssertNotEqual(identifier1, identifier2)
    }

    func testSameIdentifier_sameSectionAndItem() {
        let controller1 = TestSectionController(section: .simple)
        let controller2 = TestSectionController(section: .simple)

        let identifier1 = controller1.identifier(for: TestItem.item1)
        let identifier2 = controller2.identifier(for: TestItem.item1)

        XCTAssertEqual(identifier1, identifier2)
    }
}
