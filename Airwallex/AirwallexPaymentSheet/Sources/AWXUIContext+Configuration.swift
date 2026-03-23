//
//  AWXUIContext+Configuration.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/4/17.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexPayment)
import AirwallexCore
import AirwallexPayment
#endif

extension AWXUIContext {
    /// The type of payment flow to display.
    @objc(AWXUIContextElementType)
    public enum ElementType: Int {
        /// Display all available payment methods (default).
        case paymentSheet
        /// Display card paymenelementTypet element only (for adding new cards).
        case addCard
        /// Display a single payment method component.
        /// Requires `paymentMethodName` to be set on the configuration.
        case component
    }

    /// Configuration options for launching the payment UI.
    ///
    /// Use this class to customize the payment flow launched by `AWXUIContext`.
    @objc(AWXUIContextConfiguration)
    @objcMembers
    public class Configuration: NSObject {
        /// The type of payment flow to display.
        public var elementType: ElementType = .paymentSheet

        /// The payment method name to display when elementType is .component.
        /// Required for .component; ignored for .paymentSheet.
        /// If elementType is .component and this is nil, falls back to .paymentSheet.
        public var paymentMethodName: String?

        /// Layout style for payment sections.
        /// Only applies when elementType is .paymentSheet.
        public var layout: PaymentLayout = .tab

        /// Presentation style: .push or .present.
        public var launchStyle: LaunchStyle = .push

        /// Configuration for the Apple Pay button (buttonType, disableCardArt).
        /// Note: showsAsPrimaryButton has no effect in sheet context.
        public var applePayButton = AWXPaymentElement.Configuration.ApplePayButton()

        /// Configuration for the checkout button title.
        public var checkoutButton = AWXPaymentElement.Configuration.CheckoutButton()

        /// Appearance configuration for customizing the visual style.
        ///
        /// Use this to customize the tint color used throughout the payment UI.
        /// When launched with a configuration, `appearance.tintColor` overrides `AWXTheme.shared().tintColor`.
        public var appearance = AWXPaymentElement.Configuration.Appearance()

        /// Supported card brands. Only applies when paymentMethodName is "card".
        public var supportedCardBrands: [AWXCardBrand] = AWXCardBrand.allAvailable

        /// Internal flag indicating this configuration was created internally by a legacy API.
        /// When `true`, `appearance.tintColor` is NOT applied to `AWXTheme.shared().tintColor`,
        /// preserving backward compatibility for callers who set `AWXTheme.shared().tintColor` directly.
        var isCreatedByLegacyAPI = false
    }
}
