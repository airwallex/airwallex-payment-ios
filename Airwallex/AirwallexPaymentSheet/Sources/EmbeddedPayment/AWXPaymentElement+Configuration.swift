//
//  AWXPaymentElement+Configuration.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/1/28.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import PassKit
import UIKit
#if canImport(AirwallexPayment)
import AirwallexCore
import AirwallexPayment
#endif

extension AWXPaymentElement {
    /// The type of element to display.
    @objc(AWXPaymentElementType)
    public enum ElementType: Int {
        /// Display a list of available payment methods (default)
        case paymentSheet
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
        public var tintColor: UIColor = .awxColor(.theme)
    }

    /// Configuration for the Apple Pay button appearance and behavior.
    @objc(AWXPaymentElementApplePayButton)
    @objcMembers
    public class ApplePayButton: NSObject {
        /// Whether to prioritize Apple Pay by showing it prominently at the top.
        ///
        /// When `true` (default), Apple Pay is displayed as a separate button at the top.
        /// When `false`, Apple Pay is grouped with other payment methods:
        /// - In tab layout: shown in the horizontal method tab
        /// - In accordion layout: shown as an accordion key
        public var showsAsPrimaryButton: Bool = true

        /// Custom button type for the Apple Pay button.
        /// When `nil` (default), the SDK automatically selects based on session type:
        /// `.plain` for one-off payments, `.subscribe` for recurring.
        @nonobjc
        public var buttonType: PKPaymentButtonType?

        /// Whether to disable card art on the Apple Pay button.
        /// Only applies on iOS 26+. Default is `true`.
        public var disableCardArt: Bool = true
    }

    /// Configuration for the checkout button title.
    @objc(AWXPaymentElementCheckoutButton)
    @objcMembers
    public class CheckoutButton: NSObject {
        /// Custom title for the checkout button.
        /// When `nil` (default), the SDK automatically selects based on session type:
        /// "Pay" for one-off payments, "Confirm" for recurring.
        public var title: String?
    }

    /// Configuration options for the embedded payment element.
    ///
    /// Use this class to customize the appearance and behavior of the payment element.
    @objc(AWXPaymentElementConfiguration)
    @objcMembers
    public class Configuration: NSObject {
        /// The type of element to display.
        ///
        /// - `.paymentSheet`: Displays a list of available payment methods (default)
        /// - `.addCard`: Displays only card payment for adding new cards
        public var elementType: ElementType = .paymentSheet

        /// The layout style for payment sections.
        ///
        /// Only applies when `elementType` is `.paymentSheet`.
        /// - `.tab`: Displays payment methods in a horizontal tab bar (default)
        /// - `.accordion`: Displays payment methods in an expandable accordion layout
        public var layout: AWXUIContext.PaymentLayout {
            get {
                if elementType == .addCard {
                    return .tab
                } else {
                    return _layout
                }
            }
            set {
                _layout = newValue
            }
        }

        private var _layout: AWXUIContext.PaymentLayout = .tab

        /// Supported card brands for card payment.
        ///
        /// Only applies when `elementType` is `.addCard`.
        /// Defaults to all available card brands.
        public var supportedCardBrands: [AWXCardBrand] = AWXCardBrand.allAvailable

        /// Configuration for the Apple Pay button appearance and behavior.
        public var applePayButton = ApplePayButton()

        /// Configuration for the checkout button title.
        public var checkoutButton = CheckoutButton()

        /// Appearance configuration for customizing the visual style.
        public var appearance: Appearance = Appearance()
    }
}
