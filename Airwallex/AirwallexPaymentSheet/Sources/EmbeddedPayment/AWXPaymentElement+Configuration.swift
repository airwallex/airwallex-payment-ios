//
//  AWXPaymentElement+Configuration.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/1/23.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
import AirwallexPayment
#endif

extension AWXPaymentElement {
    /// Configuration for customizing the payment element appearance.
    ///
    /// Example:
    /// ```swift
    /// let config = AWXPaymentElement.Configuration()
    /// config.colors.backgroundPrimary = .systemRed
    /// config.colors.textPrimary = .white
    ///
    /// let element = try await AWXPaymentElement.create(
    ///     session: session,
    ///     hostViewController: self,
    ///     delegate: self,
    ///     configuration: config
    /// )
    /// ```
    @objcMembers
    @objc(AWXPaymentElementConfiguration)
    public class Configuration: NSObject {

        /// Color configuration for the payment element.
        public var colors: AWXColors

        /// Creates a new configuration with SDK default colors.
        /// Respects the current `AWXTheme.sharedTheme.tintColor`.
        public override init() {
            self.colors = AWXColors()
            super.init()
        }

        /// Creates a configuration with custom colors.
        /// - Parameter colors: Custom color configuration.
        public init(colors: AWXColors) {
            self.colors = colors
            super.init()
        }
    }
}
