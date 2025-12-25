//
//  CompoundItem.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/12/19.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

/// A compound type that pairs a section identifier with an item identifier.
/// This ensures global uniqueness of item identifiers across all sections
/// in a UICollectionViewDiffableDataSource.
///
/// For example, if two sections both have an item "checkoutButton",
/// they become distinct identifiers:
/// - CompoundItem(section: .cardPaymentNew, item: "checkoutButton")
/// - CompoundItem(section: .cardPaymentConsent, item: "checkoutButton")
struct CompoundItem<SectionType: Hashable & Sendable, ItemType: Hashable & Sendable>: Hashable, Sendable {
    let section: SectionType
    let item: ItemType

    init(_ section: SectionType, _ item: ItemType) {
        self.section = section
        self.item = item
    }
}
