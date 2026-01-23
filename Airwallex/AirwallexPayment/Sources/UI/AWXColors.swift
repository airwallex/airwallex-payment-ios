//
//  AWXColors.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/23.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

/// Color customization for payment elements.
///
/// Use this class to customize the colors used throughout the payment UI.
/// Set individual color properties to override SDK defaults.
///
/// Example:
/// ```swift
/// let colors = AWXColors()
/// colors.backgroundPrimary = .systemBackground
/// colors.textPrimary = .label
/// ```
@objcMembers
public class AWXColors: NSObject {

    // MARK: - Global Current Colors

    /// Current custom color configuration. When nil, awxColor falls back to Palette defaults.
    @_spi(AWX) public
    static var current: AWXColors?

    // MARK: - Theme

    /// Primary theme/tint color used for interactive elements.
    public var theme: UIColor

    // MARK: - Background Colors

    /// Primary background color for main content areas.
    public var backgroundPrimary: UIColor

    /// Secondary background color for grouped content.
    public var backgroundSecondary: UIColor

    /// Background color for input fields.
    public var backgroundField: UIColor

    /// Background color for highlighted/hover states.
    public var backgroundHighlight: UIColor

    /// Background color for selected states.
    public var backgroundSelected: UIColor

    /// Background color for interactive buttons.
    public var backgroundInteractive: UIColor

    /// Background color for warning messages.
    public var backgroundWarning: UIColor

    // MARK: - Border Colors

    /// Decorative border color for subtle separation.
    public var borderDecorative: UIColor

    /// Perceivable border color for visible boundaries.
    public var borderPerceivable: UIColor

    /// Border color for interactive/focused elements.
    public var borderInteractive: UIColor

    /// Border color for error states.
    public var borderError: UIColor

    // MARK: - Icon Colors

    /// Primary icon color.
    public var iconPrimary: UIColor

    /// Secondary/muted icon color.
    public var iconSecondary: UIColor

    /// Icon color for links and interactive elements.
    public var iconLink: UIColor

    /// Icon color for disabled states.
    public var iconDisabled: UIColor

    /// Icon color for warning indicators.
    public var iconWarning: UIColor

    // MARK: - Text Colors

    /// Text color for links and interactive text.
    public var textLink: UIColor

    /// Primary text color for main content.
    public var textPrimary: UIColor

    /// Secondary text color for supporting content.
    public var textSecondary: UIColor

    /// Text color for placeholder text in inputs.
    public var textPlaceholder: UIColor

    /// Text color for error messages.
    public var textError: UIColor

    /// Inverse text color (for use on dark/colored backgrounds).
    public var textInverse: UIColor

    // MARK: - Initialization

    /// Creates a new colors instance with SDK defaults.
    /// Respects the current `AWXTheme.sharedTheme.tintColor` for theme-derived colors.
    public override init() {
        // Initialize with defaults from Palette
        theme = Palette.SemanticColor.theme.color
        backgroundPrimary = Palette.SemanticColor.backgroundPrimary.color
        backgroundSecondary = Palette.SemanticColor.backgroundSecondary.color
        backgroundField = Palette.SemanticColor.backgroundField.color
        backgroundHighlight = Palette.SemanticColor.backgroundHighlight.color
        backgroundSelected = Palette.SemanticColor.backgroundSelected.color
        backgroundInteractive = Palette.SemanticColor.backgroundInteractive.color
        backgroundWarning = Palette.SemanticColor.backgroundWarning.color
        borderDecorative = Palette.SemanticColor.borderDecorative.color
        borderPerceivable = Palette.SemanticColor.borderPerceivable.color
        borderInteractive = Palette.SemanticColor.borderInteractive.color
        borderError = Palette.SemanticColor.borderError.color
        iconPrimary = Palette.SemanticColor.iconPrimary.color
        iconSecondary = Palette.SemanticColor.iconSecondary.color
        iconLink = Palette.SemanticColor.iconLink.color
        iconDisabled = Palette.SemanticColor.iconDisabled.color
        iconWarning = Palette.SemanticColor.iconWarning.color
        textLink = Palette.SemanticColor.textLink.color
        textPrimary = Palette.SemanticColor.textPrimary.color
        textSecondary = Palette.SemanticColor.textSecondary.color
        textPlaceholder = Palette.SemanticColor.textPlaceholder.color
        textError = Palette.SemanticColor.textError.color
        textInverse = Palette.SemanticColor.textInverse.color
        super.init()
    }

    // MARK: - Internal

    /// Returns color for semantic color type.
    func color(for semanticColor: Palette.SemanticColor) -> UIColor {
        switch semanticColor {
        case .theme: return theme
        case .backgroundPrimary: return backgroundPrimary
        case .backgroundSecondary: return backgroundSecondary
        case .backgroundField: return backgroundField
        case .backgroundHighlight: return backgroundHighlight
        case .backgroundSelected: return backgroundSelected
        case .backgroundInteractive: return backgroundInteractive
        case .backgroundWarning: return backgroundWarning
        case .borderDecorative: return borderDecorative
        case .borderPerceivable: return borderPerceivable
        case .borderInteractive: return borderInteractive
        case .borderError: return borderError
        case .iconPrimary: return iconPrimary
        case .iconSecondary: return iconSecondary
        case .iconLink: return iconLink
        case .iconDisabled: return iconDisabled
        case .iconWarning: return iconWarning
        case .textLink: return textLink
        case .textPrimary: return textPrimary
        case .textSecondary: return textSecondary
        case .textPlaceholder: return textPlaceholder
        case .textError: return textError
        case .textInverse: return textInverse
        }
    }
}
