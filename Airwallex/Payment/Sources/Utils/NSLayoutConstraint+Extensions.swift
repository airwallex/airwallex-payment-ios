//
//  NSLayoutConstraint+Extensions.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    @discardableResult
    func priority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
