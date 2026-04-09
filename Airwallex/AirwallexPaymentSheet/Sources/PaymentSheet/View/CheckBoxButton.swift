//
//  CheckBoxButton.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class CheckBoxButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        setTitleColor(.awxColor(.textPrimary), for: .normal)
        titleLabel?.font = .awxFont(.caption2)

        let config = UIImage.SymbolConfiguration(pointSize: 16)
        let normalImage = UIImage(systemName: "square", withConfiguration: config)!
            .withTintColor(.awxColor(.borderPerceivable), renderingMode: .alwaysOriginal)
        let selectedImage = UIImage(systemName: "checkmark.square.fill", withConfiguration: config)!
            .withTintColor(.awxColor(.backgroundInteractive), renderingMode: .alwaysOriginal)

        setImage(normalImage, for: .normal)
        setImage(selectedImage, for: .selected)
        setImage(selectedImage, for: [.selected, .highlighted])

        contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let isRTL = effectiveUserInterfaceLayoutDirection == .rightToLeft
        let spacing: CGFloat = 4
        imageEdgeInsets = UIEdgeInsets(
            top: 0,
            left: isRTL ? spacing : -spacing,
            bottom: 0,
            right: isRTL ? -spacing : spacing
        )
        titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: isRTL ? -spacing : spacing,
            bottom: 0,
            right: isRTL ? spacing : -spacing
        )
    }
}
