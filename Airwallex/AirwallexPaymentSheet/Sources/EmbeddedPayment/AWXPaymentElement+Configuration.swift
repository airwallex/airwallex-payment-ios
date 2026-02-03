//
//  AWXPaymentElement+Configuration.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/1/28.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

extension AWXPaymentElement {
    /// Configuration options for the embedded payment element.
    ///
    /// Use this class to customize the appearance and behavior of the payment element.
    @objc(AWXPaymentElementConfiguration)
    public class Configuration: NSObject {
        /// The layout style for payment sections.
        ///
        /// - `.tab`: Displays payment methods in a horizontal tab bar (default)
        /// - `.accordion`: Displays payment methods in an expandable accordion layout
        @objc public var layout: AWXUIContext.PaymentLayout = .tab

        @objc public override init() {
            super.init()
        }
    }
}
