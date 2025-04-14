//
//  CellSeparator.swift
//  Payment
//
//  Created by Weiping Li on 2025/4/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class CellSeparator: UICollectionReusableView, ViewReusable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .awxColor(.borderDecorative)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
