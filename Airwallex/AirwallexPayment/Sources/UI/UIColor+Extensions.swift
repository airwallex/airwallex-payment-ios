//
//  Colors.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

public extension UIColor {
    static func awxColor(_ color: Palette.SemanticColor) -> UIColor {
        color.color
    }
}

public extension CGColor {
    static func awxCGColor(_ cgColor: Palette.SemanticColor) -> CGColor {
        cgColor.cgColor
    }
}

extension UIColor {
    convenience init(hex: UInt) {
        let red = CGFloat((hex >> 16) & 0xFF) / 0xFF
        let green = CGFloat((hex >> 8) & 0xFF) / 0xFF
        let blue = CGFloat((hex >> 0) & 0xFF) / 0xFF
        let alpha = hex > 0xFFFFFF ? CGFloat((hex >> 24) & 0xFF) / 0xFF : 1
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// Initializes a `UIColor` from a hex string (e.g., `"#612FFF"`).
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    /// Converts UIColor -> Hex String.
    func toHex() -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int(r * 255) << 16) | (Int(g * 255) << 8) | Int(b * 255)
        return String(format: "#%06X", rgb)
    }
    
    /// Linearly interpolates with another color by a given fraction (0 to 1).
    /// - Parameters:
    ///   - color: The target color to interpolate with.
    ///   - fraction: A CGFloat from 0 to 1 representing the interpolation amount.
    /// - Returns: A new UIColor representing the interpolated color.
    func interpolates(with color: UIColor, fraction: CGFloat) -> UIColor {
        let color1 = self
        let color2 = color
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let newR = min(max(r1 + (r2 - r1) * fraction, 0), 1)
        let newG = min(max(g1 + (g2 - g1) * fraction, 0), 1)
        let newB = min(max(b1 + (b2 - b1) * fraction, 0), 1)
        let newA = min(max(a1 + (a2 - a1) * fraction, 0), 1)
        return UIColor(red: newR, green: newG, blue: newB, alpha: newA)
    }
}
