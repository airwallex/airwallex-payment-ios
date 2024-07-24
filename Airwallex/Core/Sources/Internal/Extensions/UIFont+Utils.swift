//
//  UIFont+Utils.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation


@objc
public extension UIFont {
    class var airwallexTitle: UIFont {
        UIFont.systemFont(ofSize: 28.0, weight: .bold)
    }

    class var airwallexHeadline: UIFont {
        UIFont.systemFont(ofSize: 17.0, weight: .bold)
    }

    class var airwallexBody: UIFont {
        UIFont.systemFont(ofSize: 17.0, weight: .regular)
    }

    class var airwallexBody2: UIFont {
        UIFont.systemFont(ofSize: 14.0, weight: .regular)
    }

    class var airwallexSubhead1: UIFont {
        UIFont.systemFont(ofSize: 15.0, weight: .regular)
    }

    class var airwallexSubhead2: UIFont {
        UIFont.systemFont(ofSize: 15.0, weight: .medium)
    }

    class var airwallexCaption1: UIFont {
        UIFont.systemFont(ofSize: 12.0, weight: .regular)
    }

    class var airwallexCaption2: UIFont {
        UIFont.systemFont(ofSize: 12.0, weight: .semibold)
    }
}
