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
        static let optionButtonForNextTriggerBy = "optionButtonForNextTriggerBy"
        static let optionButtonForLayout = "optionButtonForLayout"
        static let textFieldForCustomerID = "textFieldForCustomerID"
        static let actionButtonForCustomerID = "actionButtonForCustomerID"
        static let toggleFor3DS = "toggleFor3DS"
        static let toggleForUnifiedSession = "toggleForUnifiedSession"
        static let versionLabel = "versionLabel"
    }
    static let selectedConsentCell = "consentSelected"
    static let listedConsentCell = "consentListed"
    static let listedCITConsentCell = "consentListed-cit"
    static let listedMITConsentCell = "consentListed-mit"
}

enum UITestingEnvironmentVariable {
    static let isUITesting = "IS_UI_TESTING"
    static let customerID = "UI_TESTING_CUSTOMER_ID"
    static let customerID_2 = "UI_TESTING_CUSTOMER_ID_2"
    static let mockApplePayToken = "UI_TESTING_MOCK_APPLEPAY_TOKEN"
}
