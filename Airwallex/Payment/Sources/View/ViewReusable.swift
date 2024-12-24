//
//  ViewReusable.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

protocol ViewReusable: UIView {
    static var reuseIdentifier: String { get }
}

extension ViewReusable {
    static var reuseIdentifier: String {
        return String(String(describing: self))
    }
}

protocol ViewConfigurable {
    associatedtype ViewModel
    var viewModel: ViewModel? { get }
    func setup(_ viewModel: ViewModel)
}


extension UICollectionView {
    
    func registerReusableCell<T: UICollectionViewCell & ViewReusable>(_ cellClass: T.Type) {
        register(cellClass, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
    }
    
    func register<T: UICollectionReusableView & ViewReusable>(_ viewClass: T.Type, forSupplementaryViewOfKind elementKind: String) {
        register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: viewClass.reuseIdentifier)
    }
    
    func registerSectionHeader<T: UICollectionReusableView & ViewReusable>(_ viewClass: T.Type) {
        register(viewClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: viewClass.reuseIdentifier)
    }
    
    func registerSectionFooter<T: UICollectionReusableView & ViewReusable>(_ viewClass: T.Type) {
        register(viewClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: viewClass.reuseIdentifier)
    }
}
