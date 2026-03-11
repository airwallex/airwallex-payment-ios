//
//  MockCollectionViewContext.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import UIKit

class MockCollectionViewContext: CollectionViewContext<String, String> {

    typealias SectionItem = CompoundItem<String, String>

    private var mockCollectionView: UICollectionView
    init() {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let mockSectionLayout = NSCollectionLayoutSection(
            group: NSCollectionLayoutGroup.horizontal(
                layoutSize: size,
                subitems: [NSCollectionLayoutItem(layoutSize: size)]
            )
        )
        let mockCollectionViewLayout = UICollectionViewCompositionalLayout(section: mockSectionLayout)
        mockCollectionView = UICollectionView(frame: .zero, collectionViewLayout: mockCollectionViewLayout)
        let mockDataSource = UICollectionViewDiffableDataSource<String, SectionItem>(collectionView: mockCollectionView) { _, _, _ in return nil }

        super.init(
            collectionView: mockCollectionView,
            layout: mockCollectionViewLayout,
            dataSource: mockDataSource,
            performSectionUpdates: { _, _, _, _ in },
            performUpdates: { _, _ in }
        )
    }
    
    var mockCell: UICollectionViewCell?
    
    override func cellForItem(_ item: SectionItem) -> UICollectionViewCell? {
        return mockCell
    }
    
    override func dequeueReusableCell<T>(_ cellClass: T.Type, for sectionItem: SectionItem, indexPath: IndexPath) -> T where T: UICollectionViewCell, T: ViewReusable {
        return T()
    }
    
    override func dequeueReusableSupplementaryView<T>(ofKind elementKind: String, viewClass: T.Type, indexPath: IndexPath) -> T where T: UICollectionReusableView, T: ViewReusable {
        return T()
    }
}
