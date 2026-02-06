//
//  AWXPaymentElement+Configuration.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/1/28.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
import AirwallexCore
@_spi(AWX) import AirwallexPayment
#endif

extension AWXPaymentElement {
    /// The type of element to display.
    @objc(AWXPaymentElementType)
    public enum ElementType: Int {
        /// Display a list of available payment methods (default)
        case standard
        /// Display card payment element only (for adding new cards)
        case addCard
    }

    /// Appearance configuration for customizing the visual style.
    @objc(AWXPaymentElementAppearance)
    @objcMembers
    public class Appearance: NSObject {
        /// The primary brand color used throughout the payment element.
        ///
        /// Defaults to the SDK's built-in theme color.
        public var colorBrand: UIColor = .awxColor(.theme)
    }

    /// Configuration options for the embedded payment element.
    ///
    /// Use this class to customize the appearance and behavior of the payment element.
    @objc(AWXPaymentElementConfiguration)
    @objcMembers
    public class Configuration: NSObject {
        /// The type of element to display.
        ///
        /// - `.standard`: Displays a list of available payment methods (default)
        /// - `.addCard`: Displays only card payment for adding new cards
        public var elementType: ElementType = .standard

        /// The layout style for payment sections.
        ///
        /// Only applies when `elementType` is `.standard`.
        /// - `.tab`: Displays payment methods in a horizontal tab bar (default)
        /// - `.accordion`: Displays payment methods in an expandable accordion layout
        public var layout: AWXUIContext.PaymentLayout = .tab

        /// Supported card brands for card payment.
        ///
        /// Only applies when `elementType` is `.addCard`.
        /// Defaults to all available card brands.
        public var supportedCardBrands: [AWXCardBrand] = AWXCardBrand.allAvailable

        /// Whether to prioritize Apple Pay by showing it prominently at the top.
        ///
        /// When `true` (default), Apple Pay is displayed as a separate button at the top.
        /// When `false`, Apple Pay is grouped with other payment methods:
        /// - In tab layout: shown in the horizontal method tab
        /// - In accordion layout: shown as an accordion key
        public var showsApplePayAsPrimaryButton: Bool = true

        /// Appearance configuration for customizing the visual style.
        public var appearance: Appearance = Appearance()
    }
}
