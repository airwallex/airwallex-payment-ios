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
        /// Display all available payment methods (default)
        case paymentSheet
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
        public var applePayButton = AWXPaymentElement.ApplePayButton()

        /// Configuration for the checkout button title.
        public var checkoutButton = AWXPaymentElement.CheckoutButton()

        /// Supported card brands. Only applies when paymentMethodName is "card".
        public var supportedCardBrands: [AWXCardBrand] = AWXCardBrand.allAvailable
    }
}
