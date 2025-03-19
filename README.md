# Airwallex iOS SDK

![Pod Version](https://img.shields.io/cocoapods/v/Airwallex.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/Airwallex.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/Airwallex.svg?style=flat)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)

- [Chinese Tutorial](README_zh_CN.md)

The Airwallex iOS SDK is a framework for integrating easy, fast and secure payments inside your app with Airwallex. It provides simple functions to send sensitive credit card data directly to Airwallex, it also provides a powerful, customizable interface for collecting user payment details.

<p align="left">
<img src="https://github.com/user-attachments/assets/babf2af3-d59b-49fc-8b86-26e85df28a0c" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/c86b7f3f-d2bc-4326-b82e-145f52d35c72" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/938e6101-edb2-4fcf-89fa-07936e4af5a9" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/5556a6af-882d-4474-915e-2c9d5953aaa8" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/eb6f0b38-d88b-4c27-b843-9948bc25c5a0" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/1de983a9-b062-4108-82f5-917e0fc0fb57" width="200" hspace="10">
</p>
Get started with our integration guide and example project.

Table of contents
=================

<!--ts-->
- [Airwallex iOS SDK](#airwallex-ios-sdk)
- [Table of contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Integration](#integration)
    - [CocoaPods](#cocoapods)
    - [Swift Package Manager](#swift-package-manager)
      - [Components Available for Integration](#components-available-for-integration)
    - [Basic Integration](#basic-integration)
      - [Create payment intent](#create-payment-intent)
      - [Create payment session](#create-payment-session)
    - [UI Integration](#ui-integration)
      - [Launch Payment Sheet](#launch-payment-sheet)
      - [Launch Card Payment Directly](#launch-card-payment-directly)
      - [Launch Payment Method by Name](#launch-payment-method-by-name)
    - [Low-level API Integration](#low-level-api-integration)
      - [Create PaymentSessionHandler](#create-paymentsessionhandler)
      - [Pay with card](#pay-with-card)
      - [Pay with saved card (consent)](#pay-with-saved-card-consent)
      - [Pay with Apple Pay](#pay-with-apple-pay)
      - [Pay with Redirect](#pay-with-redirect)
    - [Handle Payment Result](#handle-payment-result)
    - [Set Up WeChat Pay](#set-up-wechat-pay)
    - [Set Up Apple Pay](#set-up-apple-pay)
      - [Customize Apple Pay](#customize-apple-pay)
    - [Theme Color](#theme-color)
  - [Examples](#examples)
  - [Contributing](#contributing)
<!--te-->

## Requirements
The Airwallex iOS SDK supports iOS 13.0 and above. You need to upgrade to XCode 15.4 or above, otherwise please refer to our previous release [5.4.3](https://github.com/airwallex/airwallex-payment-ios/releases/tag/5.4.3).

## Integration

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
### Swift Package Manager
Airwallex for iOS is available via Swift Package Manager. To integrate it into your project, follow these steps:
1. Add the Package Dependency
[Follow Apple's guide on how to add a package dependency in Xcode.](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)
2. Repository URL
Use the following URL for the Airwallex package:
https://github.com/airwallex/airwallex-payment-ios
3. Version Requirement
Ensure you specify version 5.7.0 or later.

#### Components Available for Integration
You can add `Airwallex` to include all components, or selectively add the following components to your project, depending on your payment needs:

- `AirwallexPayment`: For UI integration. 
- `AirwallexApplePay`: For integrating Apple Pay.    
- `AirwallexCard`: For card payments.
- `AirwallexRedirect`: To support payments via url/deeplink redirection.
- `AirwallexWeChatpay`: For a native WeChat Pay experience.

### Basic Integration

When your app starts, configure the SDK with `mode`.

``` swift
// swift
Airwallex.setMode(.demoMode) // .demoMode, .stagingMode, .productionMode
```
```objc
// objc
[Airwallex setMode:AirwallexSDKStagingMode]; // AirwallexSDKDemoMode, AirwallexSDKStagingMode, AirwallexSDKProductionMode
```

> [!TIP]
> If you want to test on different endpoint, you can customize mode and payment URL.

``` swift
// swift
Airwallex.setDefaultBaseURL("Airwallex payment base URL")
```
```objc
// objc
[Airwallex setDefaultBaseURL:[NSURL URLWithString:@”Airwallex payment base URL”]];
```

#### Create payment intent

> [!NOTE] For one-off and recurring-with-intent payment you should create **payment intent** on your server-side 
> and then pass the payment intent to the mobile-side to confirm the payment intent with the payment method selected.

``` swift
// swift
let paymentIntent = "The payment intent created on your server"
AWXAPIClientConfiguration.shared().clientSecret = paymentIntent.clientSecret
```
```objc
// objc
id paymentIntent = "The payment intent created on your server"
[AWXAPIClientConfiguration sharedConfiguration].clientSecret = paymentIntent.clientSecret;
```

> [!NOTE]
> For recurring payment, there is no need to create a payment intent. Instead, you'll need to generate
> a **client secret** with the customer id on your server-sideand pass it to `AWXAPIClientConfiguration`.

``` swift
// swift
let clientSecret = "The client secret generated with customer id on your server"
AWXAPIClientConfiguration.shared().clientSecret = clientSecret
```
```objc
// objc
NSString *clientSecret = "The client secret generated with customer id on your server"
[AWXAPIClientConfiguration sharedConfiguration].clientSecret = clientSecret;
```

#### Create payment session

- If you want to make a one-off payment, create a one-off session.
``` swift
// swift
let session = AWXOneOffSession()
session.countryCode = "Your country code"
session.billing = "Your shipping address"
session.returnURL = "App return url"
session.paymentIntent = "Payment intent"
session.autoCapture = "Whether the card payment will be captured automatically (Default YES)"
session.hidePaymentConsents = "Whether the stored cards should be hidden on the list (Default NO)"
session.paymentMethods = "An array of payment method type names" (Optional)
```
``` objc
// objc
AWXOneOffSession *session = [AWXOneOffSession new];
session.countryCode = "Your country code";
session.billing = "Your shipping address";
session.returnURL = "App return url";
session.paymentIntent = "Payment intent";
session.autoCapture = "Whether the card payment will be captured automatically (Default YES)";
session.hidePaymentConsents = "Whether the stored cards should be hidden on the list (Default NO)";
session.paymentMethods = "An array of payment method type names"; (Optional)
```

- If you want to make a recurring payment, create a recurring session.
``` swift
// swift
let session = AWXRecurringSession()
session.countryCode = "Your country code";
session.billing = "Your shipping address";
session.returnURL = "App return url";
session.currency = "Currency code";
session.amount = "Total amount";
session.customerId = "Customer id";
session.nextTriggerByType = "customer or merchant";
session.requiresCVC = "Whether it requires CVC (Default NO)";
session.merchantTriggerReason = "Unscheduled or scheduled";
session.paymentMethods = "An array of payment method type names" (Optional)
```
``` objc
// objc
AWXRecurringSession *session = [AWXRecurringSession new];
session.countryCode = "Your country code";
session.billing = "Your shipping address";
session.returnURL = "App return url";
session.currency = "Currency code";
session.amount = "Total amount";
session.customerId = "Customer id";
session.nextTriggerByType = "customer or merchant";
session.requiresCVC = "Whether it requires CVC (Default NO)";
session.merchantTriggerReason = "Unscheduled or scheduled";
session.paymentMethods = "An array of payment method type names"; (Optional)
```

- If you want to make a recurring with payment intent, create a recurring with intent session.

``` swift
// swift
let session = AWXRecurringWithIntentSession()
session.countryCode = "Your country code"
session.billing = "Your shipping address"
session.returnURL = "App return url"
session.paymentIntent = "Payment intent"
session.autoCapture = "Whether the card payment will be captured automatically (Default YES)"
session.nextTriggerByType = "customer or merchant"
session.requiresCVC = "Whether it requires CVC (Default NO)"
session.merchantTriggerReason = "Unscheduled or scheduled"
session.paymentMethods = "An array of payment method type names" (Optional)
```
``` objc
// objc
AWXRecurringWithIntentSession *session = [AWXRecurringWithIntentSession new];
session.countryCode = "Your country code";
session.billing = "Your shipping address";
session.returnURL = "App return url";
session.paymentIntent = "Payment intent";
session.autoCapture = "Whether the card payment will be captured automatically (Default YES)";
session.nextTriggerByType = "customer or merchant";
session.requiresCVC = "Whether it requires CVC (Default NO)";
session.merchantTriggerReason = "Unscheduled or scheduled";
session.paymentMethods = "An array of payment method type names" (Optional)
```

> [!IMPORTANT]
> Make sure to generate a customerID in `SettingsViewController` first before continuing with recurring or recurring with intent checkouts.

### UI Integration

#### Launch Payment Sheet
> [!NOTE]
> This is **recommended usage**, it builds a complete user flow on top of your app with our prebuilt UI to collect payment details, billing details, and confirming the payment.

Upon checkout, use `AWXUIContext` to present the payment flow where the user will be able to select the payment method.
swift
``` swift
// swift
AWXUIContext.launchPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: "The session created above",
    filterBy: "An optional array of payment method names used to filter the payment methods returned by the server"
)
```
```objc
// objc
[AWXUIContext launchPaymentFrom: "hosting view controller which also handles AWXPaymentResultDelegate"
                        session: "The session created above"
                       filterBy: "An optional array of payment method names used to filter the payment methods returned by the server"
                          style: "push/present"];
```

#### Launch Card Payment Directly
```swift
// swift
AWXUIContext.launchCardPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: "The session created above",
    supportedBrands: "accepted card brands"
)
```
```objc
// objc
[AWXUIContext launchCardPaymentFrom:"hosting view controller which also handles AWXPaymentResultDelegate"
                            session:"The session created above" 
                    supportedBrands:"accepted card brands"
                              style:"push or present"]
```
> [!Tip]
> If you want to show card payment only but still want to be able to pay with saved cards, you can launch
> payment sheet by passing [AWXCardKey] as parameter of `filterBy:`

#### Launch Payment Method by Name
> [!TIP]
> all available payment method name can be found in [API reference](https://www.airwallex.com/docs/api#/Payment_Acceptance/Config/_api_v1_pa_config_payment_method_types/get)  - JSON Object field: items.name
> 
```swift
// swift
AWXUIContext.launchPayment(
    name: "payment method name",
    from: "hosting view controller",
    session: "The session created above",
    paymentResultDelegate: "object handles AWXPaymentResultDelegate"
)
```
```objc
// objc
[AWXUIContext launchPaymentWithName:"payment method name"
                               from:"hosting view controller which also handles AWXPaymentResultDelegate"
                            session:"The session created above" 
              paymentResultDelegate:"object handles AWXPaymentResultDelegate"
                    supportedBrands:"accepted card brands - required for card payment"
                              style:"push or present"]
```

### Low-level API Integration

You can build your own entirely custom UI on top of our low-level APIs.

> [!NOTE]
> You still need all the other steps in [Basic Integration](#basic-integration) section to set up configurations, intent and session,
> except the Airwallex UI Integration is replace by `PaymentSessionHandler` and low level API integration:
> you may find [Airwallex API Docs](https://www.airwallex.com/docs/api#/Payment_Acceptance) useful if you are using this integration style

#### Create PaymentSessionHandler 

```swift
// swift
let paymentSessionHandler = PaymentSessionHandler(
    session: "The session created above", 
    viewController: "hosting view controller which also handles AWXPaymentResultDelegate"
)
self.paymentSessionHandler = paymentSessionHandler
```
```objc
// objc
PaymentSessionHandler *paymentSessionHandler = [[PaymentSessionHandler alloc] initWithSession:"The session created above"
                                                                               viewController:"hosting view controller which also handles AWXPaymentResultDelegate" 
                                                                                   methodType:nil];
self.paymentSessionHandler = paymentSessionHandler;
```
> [!TIPS]
> After initialization, you will need to store the `paymentSessionHandler` in your view controller or class that is tied to your view's lifecycle

#### Pay with card
```swift
// swift
// Confirm intent with card and billing
paymentSessionHandler.startCardPayment(
    with: "The AWXCard object collected by your custom UI",
    billing: "The AWXPlaceDetails object collected by your custom UI"
)
```
```objc
// objc
// Confirm intent with card and billing
[paymentSessionHandler startCardPaymentWith: "The AWXCard object collected by your custom UI" 
                                    billing: "The AWXPlaceDetails object collected by your custom UI" 
                                   saveCard: "Whether you want the card to be saved as payment consent for future payments"];
```
#### Pay with saved card (consent)

- Pay with consent object - Confirm intent with a payment consent object AWXPaymentConsent)
``` swift
// swift
paymentSessionHandler.startConsentPayment(with: "payment consent")
```
```objc
// objc
[paymentSessionHandler startConsentPaymentWith:"payment consent"];
``` 

- Pay with consent ID - Confirm intent with a valid payment consent ID only when the saved card is **network token**
``` swift
// swift
paymentSessionHandler.startConsentPayment(withId: "consent id")
```
```objc
// objc
[paymentSessionHandler startConsentPaymentWithId:"cst_xxxxxxxxxx"];
``` 

#### Pay with Apple Pay
> [!IMPORTANT]
> make sure `session.applePayOptions` is setup correctly
> [Set Up Apple Pay](#set-up-apple-pay) 
``` swift
// swift
paymentSessionHandler.startApplePay()
```
```objc
// objc
[paymentSessionHandler startApplePay];
```

#### Pay with Redirect
``` swift
// swift
paymentSessionHandler.startSchemaPayment(
    with: "payment method name",
    additionalInfo: "dictionary of all required information by this payment method"
)
```
```objc
// objc
[paymentSessionHandler startSchemaPaymentWith:"payment method name"
                               additionalInfo:"dictionary of all required information by this payment method"];
```
> [!IMPORTANT] 
> you should provide info for all required fields defined in "/api/v1/pa/config/payment_method_types/${payment method name}"

### Handle Payment Result

After the user completes the payment successfully or with error, you need to handle the payment result call back of `AWXPaymentresultDelegate`.
``` swift
// swift
func paymentViewController(_ controller: UIViewController?, didCompleteWith status: AirwallexPaymentStatus, error: Error?) {
    // Status may be success/in progress/ failure / cancel
}
```

```objc
// objc
- (void)paymentViewController:(UIViewController *_Nullable)controller 
        didCompleteWithStatus:(AirwallexPaymentStatus)status 
                        error:(nullable NSError *)error {
    // Status may be success/in progress/ failure / cancel
}
```

> [!TIP]
> If the payment consent is created during payment process, you can implement this optional function to get the id of this payment consent for any further usage.
```swift
// swift
func paymentViewController(_ controller: UIViewController?, didCompleteWithPaymentConsentId paymentConsentId: String) {
    // To do anything with this id.
}
```
```objc
// objc
- (void)paymentViewController:(UIViewController *)controller didCompleteWithPaymentConsentId:(NSString *)Id {
    // To do anything with this id.
}
```

### Set Up WeChat Pay
After completing payment, WeChat will be redirected to the merchant's app and do a callback using onResp(), then it can retrieve the payment intent status after the merchant server is notified, so please keep listening to the notification.
- make sure you add dependency for `AirwallexWeChatpay` (Swift package manager) or `Airwallex/WechatPay` (Cocoapods)
- setup `WechatOpenSDK` following the [official integration document](https://developers.weixin.qq.com/doc/oplatform/en/Mobile_App/Access_Guide/iOS.html)
  
> [!NOTE]
> We use internal dynamic framework `WechatOpenSDKDynamic.xcframework` for WeChat Pay integration.
> `WechatOpenSDKDynamic.xcframework` is a dynamic framework build from original `WechatOpenSDK.xcframework`  2.0.4.
> By doing this, we can
> 1. Remove unsafe flag `-ObjC`, `-all_load` from SPM target `AirwallexWeChatPay`
> 2. Stripe architecture `armv7` and `i386` which is no longer needed for modern apps.

``` swift
// swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        WXApi.registerApp("WeChat app id", universalLink: "universal link of your app")
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

```objc
// objc
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [WXApi registerApp:@"WeChat app id" universalLink:"universal link of your app"];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [WXApi handleOpenURL:url delegate:self];
}

// You can retrieve the payment intent status after your server is notified
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *)resp;
        switch (response.errCode) {
            // handle payment result
        }
    }
}

@end
```
> [!TIP]
> for more details please refer to:[Wechat document](https://developers.weixin.qq.com/doc/oplatform/en/Mobile_App/Access_Guide/iOS.html)

### Set Up Apple Pay

The Airwallex iOS SDK allows merchants to provide Apple Pay as a payment method to their customers. 

- Make sure Apple Pay is set up correctly in the app. For more information, refer to Apple's official [doc](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay).
- Make sure Apple Pay is enabled on your Airwallex account.
- Include the Apple Pay module when installing the SDK.
- Prepare the [Merchant Identifier](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay) and configure `applePayOptions` on the payment session object.

Apple Pay will now be presented as an option in the payment method sheet.
``` swift
// swift
let session = AWXOneOffSession()
...
... configure other properties
...
session.applePayOptions = AWXApplePayOptions(merchantIdentifier: "Your Merchant Identifier")
```
```objc
// objc
AWXOneOffSession *session = [AWXOneOffSession new];
...
... configure other properties
...
session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"Merchant Identifier"];
```

#### Customize Apple Pay

You can customize the Apple Pay options to restrict it as well as provide extra context. For more information, please refer to the `AWXApplePayOptions.h` header file.
```swift
// swift
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
``` objc
// objc
AWXApplePayOptions *options = ...;
options.additionalPaymentSummaryItems = @[
    [PKPaymentSummaryItem summaryItemWithLabel:@"goods" amount:[NSDecimalNumber decimalNumberWithString:@"10"]],
    [PKPaymentSummaryItem summaryItemWithLabel:@"tax" amount:[NSDecimalNumber decimalNumberWithString:@"5"]]
];
options.merchantCapabilities = PKMerchantCapability3DS | PKMerchantCapabilityDebit;
options.requiredBillingContactFields = [NSSet setWithObjects:PKContactFieldPostalAddress, nil];
options.supportedCountries = [NSSet setWithObjects:@"AU", nil];
options.totalPriceLabel = @"COMPANY, INC.";
```

> [!IMPORTANT]
> Be aware that we currently support the following payment networks for Apple Pay:
> - Visa
> - MasterCard
> - ChinaUnionPay
> - Maestro (iOS 12+)
> - Amex
> - Discover
> - JCB
>
> Customers will only be able to select the cards of the above payment networks during Apple Pay.
>
> Coupon is also not supported at this stage.

### Theme Color

You can customize the theme color.
``` swift
// swift
AWXTheme.shared().tintColor = .red
```
``` objc
// objc
[AWXTheme sharedTheme].tintColor = UIColor.red;
```

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

## Contributing

We welcome contributions of any kind including new features, bug fixes, and documentation improvements. The best way to contribute is by submitting a pull request – we'll do our best to respond to your patch as soon as possible. You can also submit an issue if you find bugs or have any questions.
