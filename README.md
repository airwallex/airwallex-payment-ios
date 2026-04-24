# Airwallex iOS SDK

![Pod Version](https://img.shields.io/cocoapods/v/Airwallex.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/Airwallex.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/Airwallex.svg?style=flat)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)

- [Chinese Tutorial](README_zh_CN.md)

## Overview
The Airwallex iOS SDK is a flexible tool that enables you to integrate payment methods into your iOS app. It provides native UI screens to facilitate payment functions on top of your existing purchase flow. You can also choose to build your own custom UI using API integration.

We support the following localizations: English, Chinese Simplified, Chinese Traditional, French, German, Japanese, Korean, Portuguese Portugal, Portuguese Brazil, Russian, Spanish, Thai

## Supported Payment Methods

| Category | Methods | Notes |
|----------|---------|-------|
| Cards | Visa, Mastercard, UnionPay, Discover, JCB, Diners Club, Amex | PCI-DSS compliance is required when using Low-level API Integration|
| Apple Pay | Apple Pay | [Setup](#apple-pay) |
| E-Wallets | Alipay, AlipayHK, DANA, GCash, Kakao Pay, Touch 'n Go, WeChat Pay, and [more](https://www.airwallex.com/docs/payments__payment-methods__payment-methods-overview) | |

## Integration Options

Choose the integration option that best suits your needs:

| Option | Description | Multiple payment methods | Single payment method |
|--------|-------------|--------------------------|------------------------|
| [UI Integration - Hosted Payment Page (HPP)](#ui-integration---hpp-hosted-payment-page) | Launch a complete, SDK-managed payment flow with prebuilt screens for payment method selection, card input, and checkout. Supports customizable theming and dark mode. **Recommended for most use cases.** | <img src="Screenshots/hpp_tab.png" width="300" alt="HPP - Multiple payment methods"> | <img src="Screenshots/hpp_card.png" width="300" alt="HPP - Single payment method"> |
| [UI Integration - Embedded Element](#ui-integration---embedded) | Embed Airwallex's `AWXPaymentElement` directly into your own view hierarchy using UIKit. You retain full control over the host layout and navigation while leveraging the SDK's payment UI components. | <img src="Screenshots/embedded_tab.png" width="300" alt="Embedded - Multiple payment methods"> | <img src="Screenshots/embedded_card.png" width="300" alt="Embedded - Single payment method"> |
| [Low-level API Integration](#low-level-api-integration) | Build a fully custom payment UI using the SDK's core APIs. Gives you direct access to payment method retrieval, card tokenization, payment confirmation, and consent management. | <img src="Screenshots/api_method_list.png" width="300" alt="API - Multiple payment methods"> | <img src="Screenshots/api_applepay.png" width="300" alt="API - Single payment method"> |

Table of contents
=================

<!--ts-->
- [Airwallex iOS SDK](#airwallex-ios-sdk)
  - [Overview](#overview)
  - [Supported Payment Methods](#supported-payment-methods)
  - [Integration Options](#integration-options)
- [Table of contents](#table-of-contents)
  - [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Examples](#examples)
  - [Integration](#integration)
    - [Installation](#installation)
      - [Swift Package Manager](#swift-package-manager)
      - [CocoaPods](#cocoapods)
    - [Required Setup](#required-setup)
      - [Customer ID](#customer-id)
      - [Payment Intent](#payment-intent)
      - [Client Secret](#client-secret)
      - [Payment session](#payment-session)
    - [Optional Setup](#optional-setup)
      - [WeChat Pay](#wechat-pay)
      - [Apple Pay](#apple-pay)
    - [UI Integration - Hosted Payment Page (HPP)](#ui-integration---hosted-payment-page-hpp)
      - [Launch Payment Sheet (Recommended)](#launch-payment-sheet-recommended)
      - [Launch Card Payment Directly](#launch-card-payment-directly)
      - [Launch Payment Method by Name](#launch-payment-method-by-name)
      - [Configuration Options](#configuration-options)
      - [Handle Payment Result](#handle-payment-result)
    - [UI Integration - Embedded](#ui-integration---embedded)
      - [Create Embedded Payment Sheet](#create-embedded-payment-sheet)
      - [Create Embedded Card Element](#create-embedded-card-element)
      - [Configuration Options](#configuration-options-1)
      - [Handle Payment Element Events](#handle-payment-element-events)
    - [Low-level API Integration](#low-level-api-integration)
      - [Create PaymentSessionHandler](#create-paymentsessionhandler)
      - [Pay with card](#pay-with-card)
      - [Pay with saved card (consent)](#pay-with-saved-card-consent)
      - [Pay with Apple Pay](#pay-with-apple-pay)
      - [Pay with Redirect](#pay-with-redirect)
      - [Handle Payment Result](#handle-payment-result-1)
  - [Contributing](#contributing)
<!--te-->

## Getting Started
Follow our [integration guide](#integration) and explore the [example project](#examples) to quickly set up payments using the Airwallex SDK.
> [!TIP] 
> Updating to a newer version of the SDK? See our [migration guide](MIGRATION.md)

## Requirements
- iOS 13.0+
- Xcode 15.4+ (For older Xcode versions, refer to release 5.4.3)

## Examples

<img src="Screenshots/demo.gif" width="300" alt="Demo">

The Examples can be run on the latest Xcode. To run the example app, you should follow these steps.

- Clone source code

```
git clone git@github.com:airwallex/airwallex-payment-ios.git
```

- Install dependencies and open project

Make sure you have installed Cocoapods and then run the following command in the project directory:

```
pod install
```

> [!TIP] 
> Update key file (Optional)
>- In the `Examples/Keys` folder, edit `Keys.json` with proper keys.
>- Build and run `Examples` schema
>
> The key file provides default values for settings. You can update these settings anytime using the in-app settings screen.

## Integration

### Installation

#### Swift Package Manager
Airwallex for iOS is available via Swift Package Manager. To integrate it into your project, follow these steps:
1. Follow [Apple's guide](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) on how to add a package dependency in Xcode.

2. Use the following URL for the Airwallex package:
https://github.com/airwallex/airwallex-payment-ios

3. Ensure you specify version 6.1.1 or later.

You can add `Airwallex` for a comprehensive integration that includes everything except WeChat Pay. Alternatively, you can selectively add specific products to your project for a more modular setup, depending on your payment needs:

- `AirwallexPaymentSheet`: For UI integration. 
- `AirwallexPayment`: For low-level API integration.
- `AirwallexWeChatPay`: Required for WeChat Pay integration.

**Size Impact**

| Integration Style| Components Included | IPA Size Increase |
|-----------------|----------------------|------------------:|
| Low-Level API Integration | AirwallexCore <br> AirwallexPayment | 0.4 MB  |
| UI Integration | AirwallexCore  <br> AirwallexPayment <br> AirwallexPaymentSheet | 1.3 MB |
| Full Integration | AirwallexCore  <br> AirwallexPayment  <br> AirwallexPaymentSheet  <br> AirwallexWeChatPay | 1.5 MB |

> The above size increase (compressed) was calculated based on Xcode’s App Thinning Size Report for a minimal iOS project integrating AirwallexSDK via Swift Package Manager (SPM).
#### CocoaPods

Airwallex for iOS is available via [CocoaPods](https://cocoapods.org/).

You can add `Airwallex` for a comprehensive integration that includes everything except WeChat Pay:
```ruby
pod 'Airwallex', '~> 6.4.1'
```

Alternatively, you can selectively add specific products to your project for a more modular setup, depending on your payment needs:
```ruby
pod 'Airwallex/AirwallexPaymentSheet' # For UI integration. 
pod 'Airwallex/AirwallexPayment' # For low-level API integration
pod 'Airwallex/AirwallexWeChatPay' # Required for WeChat Pay integration
```

Run the following command:
```ruby
pod install
```

### Required Setup

When your app starts, configure the SDK with `mode`.

``` swift
Airwallex.setMode(.demoMode) // .demoMode, .previewMode, .stagingMode, .productionMode
```
---
#### Customer ID 

Generate or retrieve a customer ID for your user on your server-side. 
Refer to the [Airwallex API Doc](https://www.airwallex.com/docs/api#/Payment_Acceptance/Customers/) for more details

> [!NOTE]
> If you only support guest checkout, you can skip this step
---
#### Payment Intent

The Payment Intent is a required object for all transaction modes in the Airwallex iOS SDK. 
It represents a specific payment attempt and must be created before initiating a payment from the mobile app.
Create payment intent on your **server-side** and then pass the payment intent to the mobile-side to confirm the payment intent with the payment method selected.

Please refer to the [Airwallex API Doc](https://www.airwallex.com/docs/api#/Payment_Acceptance/Payment_Intents/) for details of the payment intent API.

While creating payment intent using `payment_intents/create`:
- If **amount = 0**, only a payment consent will be created (no funds will be deducted).
- If **amount > 0**, a payment consent will be created and a deduction will be made at the same time.
- For guest checkout, `customer_id` parameter can be omitted.

---
#### Client Secret

If you are using `Session` object, you don't need to manually update client secret, it will be automatically handled by the SDK internally

> [!NOTE]
> If you are using deprecated subclasses of  `AWXSession`, please refer to [integration guide 6.1.9](https://github.com/airwallex/airwallex-payment-ios/tree/6.1.9?tab=readme-ov-file#integration) 
---
#### Payment session

The new `Session` type introduced in version 6.2.0 provides a unified and simplified way for integration and there are some internal optimization as well. We recommend using `Session` instead of the legacy `AWXOneOffSession`, `AWXRecurringSession`, and `AWXRecurringWithIntentSession`.

**Option 1: Initialize with a pre-created payment intent**

``` swift
let paymentConsentOptions = if /* one-off transaction */  {
    nil
} else {
    /* recurring transaction */
    PaymentConsentOptions(
        nextTriggeredBy: ".customer/.merchant",
        merchantTriggerReason: "nil/.scheduled/.unscheduled/...."
    )
}
let session = Session(
    paymentIntent: paymentIntent, // payment intent created on your server
    countryCode: "Your country code",readme
    applePayOptions: applePayOptions, // required if you want to support apple pay
    autoCapture: true, // Only applicable for card payment. If true the payment will be captured immediately after authorization succeeds.
    billing: billing, // prefilled billing address
    paymentConsentOptions: paymentConsentOptions, // info for recurring transactions
    requiredBillingContactFields: [.name, .email], // customize billing contact fields for card payment
    returnURL: "myapp://payment/return" // App return url
)
```

**Option 2: Initialize with a payment intent provider (Express Checkout)**

Using a `PaymentIntentProvider` allows the SDK to delay payment intent creation until just before payment confirmation or when clientSecret is required to request some airwallex API. 

``` swift
// 1. Implement PaymentIntentProvider
class MyPaymentIntentProvider: NSObject, PaymentIntentProvider {
    let amount = NSDecimalNumber(string: "99.99")
    let currency: String = "USD"
    let customerId: String? = "customer_123"

    func createPaymentIntent() async throws -> AWXPaymentIntent {
        // Call your backend to create the payment intent
        let response = try await MyBackendAPI.createPaymentIntent(
            amount: amount,
            currency: currency,
            customerId: customerId
        )
        return response.paymentIntent
    }
}

// 2. Create session with the provider
let provider = MyPaymentIntentProvider()
let session = Session(
    paymentIntentProvider: provider, // Payment intent will be created when needed
    countryCode: "US"
)
```

> [!NOTE]
> We will continue to support integrations using legacy session types until the next major version release. For integration steps, please refer to [integration guide](https://github.com/airwallex/airwallex-payment-ios/tree/6.1.9?tab=readme-ov-file#integration) 
```mermaid
---
title: Mapping between Session and Legacy Sessions
---
flowchart LR
    A{Session}
    B1[AWXOneOffSession]
    B2{Recurring transaction}
    C1[AWXRecurringSession]
    C2[AWXRecurringWithIntentSession]

subgraph Session.swift
    A
end 

A -- paymentConsentOptions == nil --> B1
A -- paymentConsentOptions != nil --> B2

subgraph Legacy Sessions
    B1;C1;C2
end

B2 -- amount = 0 --> C1
B2 -- amount \> 0 --> C2
```

### Optional Setup
---
#### WeChat Pay
- make sure you add dependency for `AirwallexWeChatPay` (Swift package manager) or `Airwallex/AirwallexWechatPay` (Cocoapods)
- setup `WechatOpenSDK` following the [Wechat document](https://developers.weixin.qq.com/doc/oplatform/en/Mobile_App/Access_Guide/iOS.html)

``` swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        WXApi.registerApp("WeChat app ID", universalLink: "universal link of your app")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
}

extension AppDelegate: WXApiDelegate {
    func onResp(_ resp: BaseResp) {
        if let response = resp as? PayResp {
            switch response.errCode {
                // handle payment result
            }
        }
    }
}
```
After completing payment, WeChat will be redirected to the merchant's app and do a callback using `onResp()`, then it can retrieve the payment intent status after the merchant server is notified, so please keep listening to the notification.
  
> [!NOTE]
> We use internal dynamic framework `WechatOpenSDKDynamic.xcframework` for WeChat Pay integration.
> which is a dynamic framework build from original `WechatOpenSDK.xcframework`  2.0.4.
> By doing this, we can
> 1. Remove unsafe flag `-ObjC`, `-all_load` from SPM target `AirwallexWeChatPay`
> 2. Stripe architecture `armv7` and `i386` which is no longer needed for modern apps.

---
#### Apple Pay

The Airwallex iOS SDK allows merchants to provide Apple Pay as a payment method to their customers. 

- Make sure Apple Pay is set up correctly in the app. 
  - For more information, refer to [Apple's official doc](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay).
- Make sure Apple Pay is enabled on your Airwallex account.
- Prepare the [Merchant Identifier](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay) and configure `applePayOptions` on the payment session object.

You can customize the Apple Pay options to restrict it as well as provide extra context. For more information, please refer to the `AWXApplePayOptions.h` header file.
```swift
let options = AWXApplePayOptions(merchantIdentifier: applePayMerchantId)
options.additionalPaymentSummaryItems = [
    .init(label: "goods", amount: 10),
    .init(label: "tax", amount: 1)
]
options.merchantCapabilities = [.threeDSecure, .debit]
options.requiredBillingContactFields = [.postalAddress]
options.supportedCountries = ["AU"]
options.totalPriceLabel = "COMPANY, INC."

let session = Session(
    //  ...
    applePayOptions: options// required for Apple Pay
)
```

> [!IMPORTANT]
> Be aware that we currently support the following payment networks for Apple Pay:
>- Visa
>- MasterCard
>- ChinaUnionPay
>- Maestro
>- Amex
>- Discover
>- JCB
>
> Coupon is also not supported at this stage.


### UI Integration - Hosted Payment Page (HPP)

#### Launch Payment Sheet (Recommended)
> [!NOTE]
> This is **recommended usage**, it builds a complete user flow on top of your app with our prebuilt UI to collect payment details, billing details, and confirming the payment.

Make sure you add dependency for `Airwallex` or `AirwallexPaymentSheet`.
Upon checkout, use [AWXUIContext](https://airwallex.github.io/airwallex-payment-ios/6.4.1/documentation/airwallex/awxuicontext) to present the payment flow where the user will be able to select the payment method.

``` swift
let configuration = AWXUIContext.Configuration()
configuration.layout = .tab // or .accordion
configuration.launchStyle = .push // or .present

AWXUIContext.launchPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: "The session created above",
    configuration: configuration
)
```

We provide `tab` and `accordion` styles for our payment sheet:
<p align="left">
<img src="Screenshots/hpp_tab.png" width="200">
<img src="Screenshots/hpp_accordion.png" width="200">
</p>

---
#### Launch Card Payment Directly
```swift
let configuration = AWXUIContext.Configuration()
configuration.elementType = .addCard
configuration.supportedCardBrands = [.visa, .mastercard, .unionPay]

AWXUIContext.launchPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: "The session created above",
    configuration: configuration
)
```

> [!Tip]
> If you want to show card payment only but still want to be able to pay with saved cards, you can use
> `session.paymentMethods` to filter by passing `[AWXCardKey]`:
``` swift
let session = Session(...)
session.paymentMethods = [AWXCardKey]

AWXUIContext.launchPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: session,
    configuration: AWXUIContext.Configuration()
)
```

---
#### Launch Payment Method by Name
```swift
let configuration = AWXUIContext.Configuration()
configuration.elementType = .component
configuration.paymentMethodName = "payment method name"

AWXUIContext.launchPayment(
    from: "hosting view controller",
    session: "The session created above",
    paymentResultDelegate: "object handles AWXPaymentResultDelegate",
    configuration: configuration
)
```
> [!TIP]
> Available payment method names can be found in [Airwallex API doc](https://www.airwallex.com/docs/api#/Payment_Acceptance/Config/_api_v1_pa_config_payment_method_types/get)
>
---
#### Configuration Options

| Property | Description | Default |
|----------|-------------|---------|
| `elementType` | `.paymentSheet` (all methods), `.addCard` (card only), or `.component` (single method) | `.paymentSheet` |
| `paymentMethodName` | Payment method name (required for `.component`) | `nil` |
| `layout` | `.tab` or `.accordion` (only applies to `.paymentSheet`) | `.tab` |
| `launchStyle` | `.push` or `.present` | `.push` |
| `supportedCardBrands` | Accepted card brands (only applies to `.addCard`) | All available brands |
| `applePayButton` | Customize Apple Pay button appearance (e.g. `buttonType`, `disableCardArt`) | — |
| `checkoutButton` | Customize checkout button (e.g. `title`) | — |

#### Handle Payment Result

Handle the payment result in the callback of `AWXPaymentResultDelegate`.
``` swift
func paymentViewController(_ controller: UIViewController?, didCompleteWith status: AirwallexPaymentStatus, error: Error?) {
    // call back for status success/in progress/ failure / cancel
}
```

> [!TIP]
> If the payment consent is created during payment process, you can implement this optional function to get the ID of this payment consent for any further usage.
```swift
func paymentViewController(_ controller: UIViewController?, didCompleteWithPaymentConsentId paymentConsentId: String) {
    // To do anything with this ID.
}
```

### UI Integration - Embedded

`AWXPaymentElement` provides a flexible way to embed payment UI directly into your own view hierarchy.
Unlike `AWXUIContext.launchPayment()` which presents a full payment sheet as a view controller,
`AWXPaymentElement` returns a `UIView` that you can place anywhere in your layout.

Make sure you add dependency for `Airwallex` or `AirwallexPaymentSheet`.

We provide tab and accordion styles for our embedded payment sheet:

<p align="left">
<img src="Screenshots/embedded_tab.png" width="200">
<img src="Screenshots/embedded_accordion_inline_applepay.png" width="200">
</p>

> [!NOTE]
> - The embedded view requires Auto Layout constraints for proper sizing.
> - The view's height updates automatically based on content.
> - Keyboard handling is the host app's responsibility.

---
#### Create Embedded Payment Sheet

Display a list of available payment methods inside your own view hierarchy.

``` swift
let configuration = AWXPaymentElement.Configuration()
configuration.layout = .tab // or .accordion

let element = try await AWXPaymentElement.create(
    session: session,
    delegate: self, // AWXPaymentElementDelegate
    configuration: configuration
)

// Add the element's view to your view hierarchy
let paymentView = element.view
paymentView.translatesAutoresizingMaskIntoConstraints = false
containerView.addSubview(paymentView)
```

---
#### Create Embedded Card Element

Display only the card payment form for adding new cards.

``` swift
let configuration = AWXPaymentElement.Configuration()
configuration.elementType = .addCard
configuration.supportedCardBrands = [.visa, .mastercard, .unionPay] // defaults to all available brands

let element = try await AWXPaymentElement.create(
    session: session,
    delegate: self, // AWXPaymentElementDelegate
    configuration: configuration
)

// Add the element's view to your view hierarchy
let paymentView = element.view
paymentView.translatesAutoresizingMaskIntoConstraints = false
containerView.addSubview(paymentView)
```

---
#### Configuration Options

| Property | Description | Default |
|----------|-------------|---------|
| `elementType` | `.paymentSheet` (all payment methods) or `.addCard` (card only) | `.paymentSheet` |
| `layout` | `.tab` or `.accordion` (only applies to `.paymentSheet`) | `.tab` |
| `supportedCardBrands` | Accepted card brands (only applies to `.addCard`) | All available brands |
| `applePayButton` | Customize Apple Pay button appearance (e.g. `showsAsPrimaryButton`, `buttonType`, `disableCardArt`) | — |
| `checkoutButton` | Customize checkout button (e.g. `title`) | — |
| `appearance.tintColor` | Primary brand color used throughout the payment element | SDK default |

---
#### Handle Payment Element Events

Implement `AWXPaymentElementDelegate` to receive payment lifecycle callbacks from the embedded element.

``` swift
extension YourViewController: AWXPaymentElementDelegate {
    // Required - called when payment completes
    func paymentElement(
        _ element: AWXPaymentElement,
        didCompleteFor paymentMethod: String,
        with status: AirwallexPaymentStatus,
        error: Error?
    ) {
        // call back for status success/in progress/ failure / cancel
    }

    // Optional - show/hide your own loading indicator
    func paymentElement(
        _ element: AWXPaymentElement,
        onProcessingStateChangedFor paymentMethod: String,
        isProcessing: Bool
    ) {
        // Show or hide loading indicator
    }

    // Optional - called when a payment consent is created
    func paymentElement(
        _ element: AWXPaymentElement,
        didCompleteFor paymentMethod: String,
        withPaymentConsentId paymentConsentId: String
    ) {
        // Store consent ID for future use
    }

    // Optional - scroll invalid input field into view
    func paymentElement(
        _ element: AWXPaymentElement,
        validationFailedFor paymentMethod: String,
        invalidInputView: UIView
    ) {
        let rect = invalidInputView.convert(invalidInputView.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
}
```

### Low-level API Integration

Make sure you add dependency for `Airwallex` or `AirwallexPayment`.
You can build your own entirely custom UI on top of our low-level APIs.

> [!NOTE]
> You still need all required steps listed in [Required Setup](#required-setup) section above to set up configurations, payment intent and payment session.
> 
> you may find [Airwallex API Docs](https://www.airwallex.com/docs/api#/Payment_Acceptance) useful if you are using this integration style
---
#### Create PaymentSessionHandler 
[PaymentSessionHandler](https://airwallex.github.io/airwallex-payment-ios/6.4.1/documentation/airwallex/paymentsessionhandler) is at the center of the API integration.
```swift
let paymentSessionHandler = PaymentSessionHandler(
    session: "The session created above", 
    viewController: "hosting view controller which also handles AWXPaymentResultDelegate"
)
// store the `paymentSessionHandler` in your view controller or class that is tied to your view's lifecycle
self.paymentSessionHandler = paymentSessionHandler
```
---
#### Pay with card
```swift
// Confirm intent with card and billing
paymentSessionHandler.startCardPayment(
    with: "The AWXCard object collected by your custom UI",
    billing: "The AWXPlaceDetails object collected by your custom UI"
)
```
---
#### Pay with saved card (consent)

- Pay with consent object - Confirm intent with a payment consent object `AWXPaymentConsent`)
``` swift
paymentSessionHandler.startConsentPayment(with: "payment consent")
```

- Pay with consent ID - Confirm intent with a valid payment consent ID only when the card is save as **network token**
``` swift
paymentSessionHandler.startConsentPayment(withId: "consent ID")
```
---
#### Pay with Apple Pay
> [!IMPORTANT]
> Make sure you have [Set Up Apple Pay](#Apple-Pay) correctly.
``` swift
paymentSessionHandler.startApplePay()
```
---
#### Pay with Redirect
> [!IMPORTANT] 
> You should provide all required fields defined in "/api/v1/pa/config/payment_method_types/${payment method name}" in `additionalInfo`
``` swift
paymentSessionHandler.startRedirectPayment(
    with: "payment method name",
    additionalInfo: "all required information"
)
```

#### Handle Payment Result

Handle the payment result in the callback of `AWXPaymentResultDelegate`.
``` swift
func paymentViewController(_ controller: UIViewController?, didCompleteWith status: AirwallexPaymentStatus, error: Error?) {
    // call back for status success/in progress/ failure / cancel
}
```

> [!TIP]
> If the payment consent is created during payment process, you can implement this optional function to get the ID of this payment consent for any further usage.
```swift
func paymentViewController(_ controller: UIViewController?, didCompleteWithPaymentConsentId paymentConsentId: String) {
    // To do anything with this ID.
}
```

## Contributing

We welcome contributions of any kind including new features, bug fixes, and documentation improvements. The best way to contribute is by submitting a pull request – we'll do our best to respond to your patch as soon as possible. You can also submit an issue if you find bugs or have any questions.

