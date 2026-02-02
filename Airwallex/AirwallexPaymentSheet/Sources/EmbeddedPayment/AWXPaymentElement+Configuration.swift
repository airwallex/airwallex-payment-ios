//
//  AWXPaymentElement+Configuration.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/1/28.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexPayment)
import AirwallexCore
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

    /// Configuration options for the embedded payment element.
    ///
    /// Use this class to customize the appearance and behavior of the payment element.
    @objc(AWXPaymentElementConfiguration)
    public class Configuration: NSObject {
        /// The type of element to display.
        ///
        /// - `.standard`: Displays a list of available payment methods (default)
        /// - `.addCard`: Displays only card payment for adding new cards
        @objc public var elementType: ElementType = .standard

        /// The layout style for payment sections.
        ///
        /// Only applies when `elementType` is `.standard`.
        /// - `.tab`: Displays payment methods in a horizontal tab bar (default)
        /// - `.accordion`: Displays payment methods in an expandable accordion layout
        @objc public var layout: AWXUIContext.PaymentLayout = .tab

        /// Supported card brands for card payment.
        ///
        /// Only applies when `elementType` is `.addCard`.
        /// Defaults to all available card brands.
        @objc public var supportedCardBrands: [AWXCardBrand] = AWXCardBrand.allAvailable
    }
}
