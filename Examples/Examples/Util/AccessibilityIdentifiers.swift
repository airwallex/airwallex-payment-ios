//
//  AccessibilityIdentifiers.swift
//  Examples
//
//  Created by Weiping Li on 20/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

enum AccessibilityIdentifiers {
    enum SettingsScreen {
        static let optionButtonForPaymentType = "optionButtonForPaymentType"
        static let optionButtonForEnvironment = "optionButtonForEnvironment"
        static let optionButtonForLayout = "optionButtonForLayout"
        static let textFieldForCustomerID = "textFieldForCustomerID"
        static let actionButtonForCustomerID = "actionButtonForCustomerID"
        static let toggleFor3DS = "toggleFor3DS"
    }
    static let selectedConsentCell = "consentSelected"
    static let listedConsentCell = "consentListed"
}

enum UITestingEnvironmentVariable {
    static let isUITesting = "IS_UI_TESTING"
    static let customerID = "UI_TESTING_CUSTOMER_ID"
    static let mockApplePayToken = "UI_TESTING_MOCK_APPLEPAY_TOKEN"
}
