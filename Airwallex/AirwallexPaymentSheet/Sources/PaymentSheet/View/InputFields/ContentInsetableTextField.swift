//
//  ContentInsetableTextField.swift
//  Payment
//
//  Created by Weiping Li on 2025/3/19.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class ContentInsetableTextField: UITextField {
    
    var textInsets: UIEdgeInsets {
        didSet {
            setNeedsLayout()
        }
    }
    
    init(textInsets: UIEdgeInsets = .zero) {
        self.textInsets = textInsets
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Rect for text already in the field
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let textRect = super.textRect(forBounds: bounds)
        let rect = bounds.inset(by: textInsets)
        let result = textRect.intersection(rect)
        guard !(result.isEmpty || result.isEmpty || result.isInfinite) else {
            return rect
        }
        return result
    }
    
    // Rect for text when editing
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let editingRect = super.editingRect(forBounds: bounds)
        let rect = bounds.inset(by: textInsets)
        let result = editingRect.intersection(rect)
        guard !(result.isEmpty || result.isEmpty || result.isInfinite) else {
            return rect
        }
        return result
    }
    
    // Optionally adjust the placeholder's rectangle
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let placeholderRect = super.placeholderRect(forBounds: bounds)
        let rect = bounds.inset(by: textInsets)
        let result = placeholderRect.intersection(rect)
        guard !(result.isEmpty || result.isEmpty || result.isInfinite) else {
            return rect
        }
        return result
    }
}
