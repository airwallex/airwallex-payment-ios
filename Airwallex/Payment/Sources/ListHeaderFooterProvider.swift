//
//  ListHeaderFooterProvider.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/20.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
import UIKit

struct BoundarySupplementaryItemProvider {
    let elementKind: String
    let layout: NSCollectionLayoutBoundarySupplementaryItem
    let reusableView: (UICollectionReusableView & ViewReusable).Type
}
