//
//  MockSectionProvider.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/27.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
@testable import Payment

@MainActor

enum Section: CaseIterable {
    case A
    case B
}

enum Item {
    case A1
    case A2
    case B1
    case B2
}

class MockSectionProvider: CollectionViewSectionProvider {
    
    enum Status {
        case A
        case B
        case AB
        case BA
        case None
    }
    
    var status = Status.A
    
    lazy var sectionControllerA: MockSectionController<Section, Item> = MockSectionController(
        section: Section.A,
        items: [Item.A1, Item.A2]
    )
    
    lazy var anySectionControllerA = sectionControllerA.anySectionController()
    
    lazy var sectionControllerB: MockSectionController<Section, Item> = MockSectionController(
        section: Section.B,
        items: [Item.B1, Item.B2]
    )
    lazy var anySectionControllerB = sectionControllerB.anySectionController()
    
    func sections() -> [Section] {
        switch status {
        case .A:
            [.A]
        case .B:
            [.B]
        case .AB:
            [.A, .B]
        case .BA:
            [.B, .A]
        case .None:
            []
        }
    }
    
    func sectionController(for section: Section) -> AnySectionController<Section, Item> {
        switch section {
        case .A:
            return anySectionControllerA
        case .B:
            return anySectionControllerB
        }
    }
    
    func listBoundaryItemProviders() -> [BoundarySupplementaryItemProvider]? {
        return [BoundarySupplementaryItemProvider(
            elementKind: "list-header",
            layout: .init(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)),
                elementKind: "list-header",
                alignment: .topLeading
            ),
            reusableView: LabelCell.self
        )]
    }
}
