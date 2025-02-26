//
//  Spacing.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/16.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

extension CGFloat {
    static let spacing_4: CGFloat = 4
    static let spacing_8: CGFloat = 8
    static let spacing_12: CGFloat = 12
    static let spacing_16: CGFloat = 16
    static let spacing_20: CGFloat = 20
    static let spacing_24: CGFloat = 24
    static let spacing_32: CGFloat = 32
    static let spacing_40: CGFloat = 40
    static let spacing_48: CGFloat = 48
    static let spacing_56: CGFloat = 56
    static let spacing_64: CGFloat = 64
    static let spacing_80: CGFloat = 80
    static let spacing_96: CGFloat = 96
}

extension CGFloat {
    /// 2.0
    static let radius_s: CGFloat = 2
    /// 4.0
    static let radius_m: CGFloat = 4
    /// 6.0
    static let radius_l: CGFloat = 6
}

extension UIEdgeInsets {
    init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
        self.init(top: vertical, left: horizontal, bottom: -vertical, right: horizontal)
    }
    
    init(inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: -inset, right: -inset)
    }
    
    func horizontal(_ inset: CGFloat) -> UIEdgeInsets {
        var insets = self
        insets.left = inset
        insets.right = -inset
        return insets
    }
    
    func vertical(_ inset: CGFloat) -> UIEdgeInsets {
        var insets = self
        insets.top = inset
        insets.bottom = -inset
        return insets
    }
    
    func top(_ inset: CGFloat) -> UIEdgeInsets {
        var insets = self
        insets.top = inset
        return insets
    }
    
    func bottom(_ inset: CGFloat) -> UIEdgeInsets {
        var insets = self
        insets.bottom = -inset
        return insets
    }
    
    func left(_ inset: CGFloat) -> UIEdgeInsets {
        var insets = self
        insets.left = inset
        return insets
    }
    
    func right(_ inset: CGFloat) -> UIEdgeInsets {
        var insets = self
        insets.right = -inset
        return insets
    }
}

extension NSDirectionalEdgeInsets {
    init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
    
    init(inset: CGFloat) {
        self.init(top: inset, leading: inset, bottom: inset, trailing: inset)
    }
    
    func horizontal(_ inset: CGFloat) -> NSDirectionalEdgeInsets {
        var insets = self
        insets.leading = inset
        insets.trailing = inset
        return insets
    }
    
    func vertical(_ inset: CGFloat) -> NSDirectionalEdgeInsets {
        var insets = self
        insets.top = inset
        insets.bottom = inset
        return insets
    }
    
    func top(_ inset: CGFloat) -> NSDirectionalEdgeInsets {
        var insets = self
        insets.top = inset
        return insets
    }
    
    func bottom(_ inset: CGFloat) -> NSDirectionalEdgeInsets {
        var insets = self
        insets.bottom = inset
        return insets
    }
    
    func leading(_ inset: CGFloat) -> NSDirectionalEdgeInsets {
        var insets = self
        insets.leading = inset
        return insets
    }
    
    func trailing(_ inset: CGFloat) -> NSDirectionalEdgeInsets {
        var insets = self
        insets.trailing = inset
        return insets
    }
}
