//
//  MockCollectionViewContext.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
@testable import Payment

class MockCollectionViewContext: CollectionViewContext<String, String> {
    
    private var mockCollectionView: UICollectionView
    private var mockViewController: UIViewController
    init() {
        mockViewController = UIViewController()
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
        let mockDataSource = UICollectionViewDiffableDataSource<String, String>(collectionView: mockCollectionView) { _, _, _ in return nil }
        
        super.init(
            viewController: mockViewController,
            collectionView: mockCollectionView,
            layout: mockCollectionViewLayout,
            dataSource: mockDataSource,
            performSectionUpdates: { _, _, _, _ in },
            performUpdates: { _, _ in }
        )
    }
    
    var mockCell: UICollectionViewCell?
    
    override func cellForItem(_ item: String) -> UICollectionViewCell? {
        return mockCell
    }
    
    override func dequeueReusableCell<T>(_ cellClass: T.Type, for item: String, indexPath: IndexPath) -> T where T : UICollectionViewCell, T : ViewReusable {
        return T()
    }
    
    override func dequeueReusableSupplementaryView<T>(ofKind elementKind: String, viewClass: T.Type, indexPath: IndexPath) -> T where T : UICollectionReusableView, T : ViewReusable {
        return T()
    }
}
