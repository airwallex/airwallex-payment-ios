//
//  RoundedCornerDecorationView.swift
//  Payment
//
//  Created by Weiping Li on 2025/4/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class RoundedCornerDecorationView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = .awxCGColor(.borderDecorative)
        layer.borderWidth = 1
        layer.cornerRadius = 6
    }
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
}
