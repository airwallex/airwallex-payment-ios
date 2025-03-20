# Airwallex iOS SDK

![Pod Version](https://img.shields.io/cocoapods/v/Airwallex.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/Airwallex.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/Airwallex.svg?style=flat)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)

- [Chinese Tutorial](README_zh_CN.md)

## Overview
The Airwallex iOS SDK is a framework for integrating easy, fast and secure payments inside your app with Airwallex. It provides simple functions to send sensitive credit card data directly to Airwallex, it also provides a powerful, customizable interface for collecting user payment details.

<p align="left">
<img src="https://github.com/user-attachments/assets/babf2af3-d59b-49fc-8b86-26e85df28a0c" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/c86b7f3f-d2bc-4326-b82e-145f52d35c72" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/938e6101-edb2-4fcf-89fa-07936e4af5a9" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/5556a6af-882d-4474-915e-2c9d5953aaa8" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/eb6f0b38-d88b-4c27-b843-9948bc25c5a0" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/1de983a9-b062-4108-82f5-917e0fc0fb57" width="200" hspace="10">
</p>

Table of contents
=================

<!--ts-->
- [Airwallex iOS SDK](#airwallex-ios-sdk)
  - [Overview](#overview)
- [Table of contents](#table-of-contents)
  - [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Examples](#examples)
  - [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)
    - [CocoaPods](#cocoapods)
  - [Integration](#integration)
    - [Required Setup](#required-setup)
      - [Customer ID](#customer-id)
      - [Create payment session](#create-payment-session)
      - [Create Payment Intent](#create-payment-intent)
      - [Update Client Secret](#update-client-secret)
    - [Optional Setup](#optional-setup)
      - [WeChat Pay](#wechat-pay)
      - [Apple Pay](#apple-pay)
    - [UI Integration](#ui-integration)
      - [Launch Payment Sheet (Recommended)](#launch-payment-sheet-recommended)
      - [Launch Card Payment Directly](#launch-card-payment-directly)
      - [Launch Payment Method by Name](#launch-payment-method-by-name)
    - [Low-level API Integration](#low-level-api-integration)
      - [Create PaymentSessionHandler](#create-paymentsessionhandler)
      - [Pay with card](#pay-with-card)
      - [Pay with saved card (consent)](#pay-with-saved-card-consent)
      - [Pay with Apple Pay](#pay-with-apple-pay)
      - [Pay with Redirect](#pay-with-redirect)
    - [Handle Payment Result](#handle-payment-result)
  - [Customization](#customization)
    - [Theme Color](#theme-color)
  - [Contributing](#contributing)
<!--te-->

## Getting Started
Follow our integration guide and explore the [example project](#examples) to quickly set up payments using the Airwallex SDK.
Get started with our integration guide and example project.

## Requirements
- iOS 13.0+
- Xcode 15.4+ (For older Xcode versions, refer to release 5.4.3)
- Compatible with Objective-C

## Examples

The Examples can be run on the latest Xcode. To run the example app, you should follow these steps.

- Clone source code

Run the following script to clone this project to your local disk.

```
git clone git@github.com:airwallex/airwallex-payment-ios.git
```

- Install dependencies and open project

Make sure you have installed Cocoapods and then run the following command in the project directory:

```
pod install
```

> [!TIP]
>  Update key file (Optional)
>
> In the `Examples/Keys` folder, edit `Keys.json` with proper keys.

- Build and run `Examples` schema

If you didn't update the key file, you can use the in-app setting screen to update the keys.

## Installation

### Swift Package Manager
Airwallex for iOS is available via Swift Package Manager. To integrate it into your project, follow these steps:
1. Add the Package Dependency
[Follow Apple's guide on how to add a package dependency in Xcode.](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)
2. Repository URL
Use the following URL for the Airwallex package:
https://github.com/airwallex/airwallex-payment-ios
3. Version Requirement
Ensure you specify version 5.7.0 or later.

You can add `Airwallex` to include all components, or selectively add the following components to your project, depending on your payment needs:

- `AirwallexPayment`: For UI integration. 
- `AirwallexApplePay`: For integrating Apple Pay.    
- `AirwallexCard`: For card payments.
- `AirwallexRedirect`: To support payments via url/deeplink redirection.
- `AirwallexWeChatpay`: For a native WeChat Pay experience.

### CocoaPods

Airwallex for iOS is available through [CocoaPods](https://cocoapods.org/).

Add this line to your `Podfile`:
```ruby
pod 'Airwallex'
```

Optionally, you can also include the modules directly (This is recommended to ensure minimal dependency):

```ruby
pod 'Airwallex/Payment'
pod 'Airwallex/Core'
pod 'Airwallex/Card'
pod 'Airwallex/WechatPay'
pod 'Airwallex/Redirect'
pod 'Airwallex/ApplePay'
```

Run the following command:
```ruby
pod install
```
## Integration
### Required Setup

When your app starts, configure the SDK with `mode`.

``` swift
Airwallex.setMode(.demoMode) // .demoMode, .stagingMode, .productionMode
```
#### Customer ID 
> [!IMPORTANT]
> customer ID is required for **recurring** or **recurring with intent** checkouts

Generate or retrieve a customer ID for your user on your server-side. 
Refer to the Airwallex API Documentation for details.
[Airwallex API Doc](https://www.airwallex.com/docs/api#/Payment_Acceptance/Customers/)

#### Create payment session

- If you want to make a one-off payment, create a one-off session.
``` swift
let session = AWXOneOffSession()
session.countryCode = "Your country code"
session.billing = "Your shipping address"
session.returnURL = "App return url"
```
- If you want to make a recurring payment, create a recurring session.
``` swift
let session = AWXRecurringSession()
session.countryCode = "Your country code"
session.billing = "Your shipping address"
session.returnURL = "App return url"
session.setCurrency("Currency code")
session.setAmount("Total amount")
session.setCustomerId("Customer ID")
session.nextTriggerByType = "customer or merchant";
session.merchantTriggerReason = "Unscheduled or scheduled";
```
- If you want to make a recurring with payment intent, create a recurring with intent session.

``` swift
let session = AWXRecurringWithIntentSession()
session.countryCode = "Your country code"
session.billing = "Your shipping address"
session.returnURL = "App return url"
session.nextTriggerByType = "customer or merchant"
session.merchantTriggerReason = "Unscheduled or scheduled"
```
> [!TIP] 
> You only need to explicitly set the customer ID for a recurring session.
> For **one-off** session and **recurring-with-intent** session, the customer ID is automatically retrieved from `session.paymentIntent`

#### Create Payment Intent

For **one-off** or **recurring-with-intent** checkout, create **payment intent** on your server-side and then pass the payment intent to the mobile-side to confirm the payment intent with the payment method selected.

Refer to the Airwallex API Documentation for details.
[Airwallex API Doc](https://www.airwallex.com/docs/api#/Payment_Acceptance/Customers/)

``` swift
let paymentIntent = "The payment intent created on your server"
// update session you created above
session.paymentIntent = paymentIntent
```
> [!NOTE]
> For **recurring payment** there is no need to create a payment intent.

#### Update Client Secret
For **one-off** and **recurring-with-intent** payment, you can use `paymentIntent.clientSecret`
``` swift
AWXAPIClientConfiguration.shared().clientSecret = paymentIntent.clientSecret
```

For **recurring payment**, you'll need to generate
a **client secret** with the **customer ID** on your server-side and pass it to `AWXAPIClientConfiguration`.

Refer to the Airwallex API Documentation for details.
[Airwallex API Doc](https://www.airwallex.com/docs/api#/Payment_Acceptance/Customers/)

``` swift
let clientSecret = "The client secret generated with customer ID on your server"
AWXAPIClientConfiguration.shared().clientSecret = clientSecret
```

### Optional Setup
#### WeChat Pay
After completing payment, WeChat will be redirected to the merchant's app and do a callback using `onResp()`, then it can retrieve the payment intent status after the merchant server is notified, so please keep listening to the notification.
- make sure you add dependency for `AirwallexWeChatpay` (Swift package manager) or `Airwallex/WechatPay` (Cocoapods)
- setup `WechatOpenSDK` following the [official integration document](https://developers.weixin.qq.com/doc/oplatform/en/Mobile_App/Access_Guide/iOS.html)

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
  
> [!NOTE]
> We use internal dynamic framework `WechatOpenSDKDynamic.xcframework` for WeChat Pay integration.
> `WechatOpenSDKDynamic.xcframework` is a dynamic framework build from original `WechatOpenSDK.xcframework`  2.0.4.
> By doing this, we can
> 1. Remove unsafe flag `-ObjC`, `-all_load` from SPM target `AirwallexWeChatPay`
> 2. Stripe architecture `armv7` and `i386` which is no longer needed for modern apps.
>
> For more details please refer to: [Wechat document](https://developers.weixin.qq.com/doc/oplatform/en/Mobile_App/Access_Guide/iOS.html)

#### Apple Pay

The Airwallex iOS SDK allows merchants to provide Apple Pay as a payment method to their customers. 

- Make sure Apple Pay is set up correctly in the app. For more information, refer to Apple's official [doc](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay).
- Make sure Apple Pay is enabled on your Airwallex account.
- Include the Apple Pay module when installing the SDK.
- Prepare the [Merchant Identifier](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay) and configure `applePayOptions` on the payment session object.

Apple Pay will now be presented as an option in the payment method sheet.
``` swift
let session = AWXOneOffSession()
//  configure other properties
...
session.applePayOptions = AWXApplePayOptions(merchantIdentifier: "Your Merchant Identifier")
```
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
```

> [!IMPORTANT]
> Be aware that we currently support the following payment networks for Apple Pay:
>- Visa
>- MasterCard
>- ChinaUnionPay
>- Maestro (iOS 12+)
>- Amex
>- Discover
>- JCB

Customers will only be able to select the cards of the above payment networks during Apple Pay.
>[!IMPORTANT]
> Coupon is also not supported at this stage.


### UI Integration

#### Launch Payment Sheet (Recommended)
> [!NOTE]
> This is **recommended usage**, it builds a complete user flow on top of your app with our prebuilt UI to collect payment details, billing details, and confirming the payment.

Upon checkout, use `AWXUIContext` to present the payment flow where the user will be able to select the payment method.
swift
``` swift
AWXUIContext.launchPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: "The session created above",
    filterBy: "An optional array of payment method names used to filter the payment methods returned by the server"
)
```

#### Launch Card Payment Directly
```swift
AWXUIContext.launchCardPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: "The session created above",
    supportedBrands: "accepted card brands, should not be empty"
)
```

> [!Tip]
> If you want to show card payment only but still want to be able to pay with saved cards, you can launch
> payment sheet by passing [AWXCardKey] as parameter of `filterBy:`

#### Launch Payment Method by Name
> [!TIP]
> Available payment method names can be found in [API reference](https://www.airwallex.com/docs/api#/Payment_Acceptance/Config/_api_v1_pa_config_payment_method_types/get)  
> 
```swift
AWXUIContext.launchPayment(
    name: "payment method name",
    from: "hosting view controller",
    session: "The session created above",
    paymentResultDelegate: "object handles AWXPaymentResultDelegate"
)
```

### Low-level API Integration

You can build your own entirely custom UI on top of our low-level APIs.

> [!NOTE]
> You still need all required steps listed in [Basic Integration](#basic-integration) section above to set up configurations, intent and session, except the [UI Integration](#ui-integration) is replace by `PaymentSessionHandler` and [low-level API integration](#low-level-api-integration)
> 
> you may find [Airwallex API Docs](https://www.airwallex.com/docs/api#/Payment_Acceptance) useful if you are using this integration style

#### Create PaymentSessionHandler 

```swift
let paymentSessionHandler = PaymentSessionHandler(
    session: "The session created above", 
    viewController: "hosting view controller which also handles AWXPaymentResultDelegate"
)
self.paymentSessionHandler = paymentSessionHandler
```

> [!TIP]
> After initialization, you will need to store the `paymentSessionHandler` in your view controller or class that is tied to your view's lifecycle

#### Pay with card
```swift
// Confirm intent with card and billing
paymentSessionHandler.startCardPayment(
    with: "The AWXCard object collected by your custom UI",
    billing: "The AWXPlaceDetails object collected by your custom UI"
)
```
#### Pay with saved card (consent)

- Pay with consent object - Confirm intent with a payment consent object AWXPaymentConsent)
``` swift
paymentSessionHandler.startConsentPayment(with: "payment consent")
```

- Pay with consent ID - Confirm intent with a valid payment consent ID only when the saved card is **network token**
``` swift
paymentSessionHandler.startConsentPayment(withId: "consent ID")
```

#### Pay with Apple Pay
> [!IMPORTANT]
> Make sure `session.applePayOptions` is setup correctly.
> 
> Refer to section [Set Up Apple Pay](#set-up-apple-pay) for more details.
``` swift
paymentSessionHandler.startApplePay()
```

#### Pay with Redirect
> [!IMPORTANT] 
> You should provide all required fields defined in "/api/v1/pa/config/payment_method_types/${payment method name}" in `additionalInfo`
``` swift
paymentSessionHandler.startSchemaPayment(
    with: "payment method name",
    additionalInfo: "all required information"
)
```

### Handle Payment Result

After the user completes the payment successfully or with error, you need to handle the payment result call back of `AWXPaymentresultDelegate`.
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
## Customization
### Theme Color

You can customize the theme color.
``` swift
AWXTheme.shared().tintColor = .red
```

## Contributing

We welcome contributions of any kind including new features, bug fixes, and documentation improvements. The best way to contribute is by submitting a pull request – we'll do our best to respond to your patch as soon as possible. You can also submit an issue if you find bugs or have any questions.
