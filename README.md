# Airwallex iOS SDK

![Pod Version](https://img.shields.io/cocoapods/v/Airwallex.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/Airwallex.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/Airwallex.svg?style=flat)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)

- [Chinese Tutorial](README_zh_CN.md)

The Airwallex iOS SDK is a framework for integrating easy, fast and secure payments inside your app with Airwallex. It provides simple functions to send sensitive credit card data directly to Airwallex, it also provides a powerful, customizable interface for collecting user payment details.

<p align="left">
<img src="https://github.com/user-attachments/assets/6f7c2a32-b7fb-409d-bf40-06d276f57a51" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/5556a6af-882d-4474-915e-2c9d5953aaa8" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/c86b7f3f-d2bc-4326-b82e-145f52d35c72" width="200" hspace="10">
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
    - [Swift](#swift)
    - [Basic Integration](#basic-integration)
    - [Airwallex UI Integration](#airwallex-ui-integration)
      - [Launch Payment Method List](#launch-payment-method-list)
      - [Launch Card Payment](#launch-card-payment)
      - [Launch payment method by name](#launch-payment-method-by-name)
    - [Handle payment result](#handle-payment-result)
    - [Low-level API Integration](#low-level-api-integration)
      - [Initialize PaymentSessionHandler](#initialize-paymentsessionhandler)
      - [Pay with card](#pay-with-card)
      - [Pay with saved card (consent)](#pay-with-saved-card-consent)
      - [Pay with Apple Pay](#pay-with-apple-pay)
      - [Pay with Redirect](#pay-with-redirect)
    - [Set Up WeChat Pay](#set-up-wechat-pay)
    - [Set Up Apple Pay](#set-up-apple-pay)
      - [Customize Apple Pay](#customize-apple-pay)
      - [Limitations](#limitations)
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
Airwallex.setMode(.demoMode) // .demoMode, .stagingMode, .productionMode
```
```objc
[Airwallex setMode:AirwallexSDKStagingMode]; // AirwallexSDKDemoMode, AirwallexSDKStagingMode, AirwallexSDKProductionMode
```

If you want to test on different endpoint, you can customize mode and payment URL.

``` swift
Airwallex.setDefaultBaseURL("Airwallex payment base URL")
```
```objc
[Airwallex setDefaultBaseURL:[NSURL URLWithString:@”Airwallex payment base URL”]];
```

- Create a payment intent

When the customer wants to checkout an order, you should create a payment intent on your server-side and then pass the payment intent to the mobile-side to confirm the payment intent with the payment method selected.

``` swift
AWXAPIClientConfiguration.shared().clientSecret = "The payment intent's client secret"
```
```objc
[AWXAPIClientConfiguration sharedConfiguration].clientSecret = "The payment intent's client secret";
```

Note: When `checkoutMode` is `AirwallexCheckoutRecurringMode`, there is no need to create a payment intent. Instead, you'll need to generate a client secret with the customer id and pass it to `AWXAPIClientConfiguration`.

``` swift
AWXAPIClientConfiguration.shared().clientSecret = "The client secret generated with customer id"
```
```objc
[AWXAPIClientConfiguration sharedConfiguration].clientSecret = "The client secret generated with customer id";
```

- Create session

If you want to make a one-off payment, create a one-off session.
``` swift
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
AWXOneOffSession *session = [AWXOneOffSession new];
session.countryCode = "Your country code";
session.billing = "Your shipping address";
session.returnURL = "App return url";
session.paymentIntent = "Payment intent";
session.autoCapture = "Whether the card payment will be captured automatically (Default YES)";
session.hidePaymentConsents = "Whether the stored cards should be hidden on the list (Default NO)";
session.paymentMethods = "An array of payment method type names"; (Optional)
```

If you want to make a recurring payment, create a recurring session.
``` swift
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

If you want to make a recurring with payment intent, create a recurring with intent session.

``` swift
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

### Airwallex UI Integration

#### Launch Payment Method List

This is **recommended usage**, it builds a complete user flow on top of your app with our prebuilt UI to collect payment details, billing details, and confirming the payment.

Upon checkout, use `AWXUIContext` to present the payment flow where the user will be able to select the payment method.
swift
``` swift
// swift
AWXUIContext.shared().launchPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate", 
    filterBy: "An optional array of payment method names used to filter the payment methods returned by the server"
    session: "The session created above"
)
```
```objc
[[AWXUIContext sharedContext] launchPaymentFrom: "hosting view controller which also handles AWXPaymentResultDelegate"
                                        session: "The session created above"
                                       filterBy: "An optional array of payment method names used to filter the payment methods returned by the server"
                                          style: "push/present"];
```

#### Launch Card Payment 
```swift
AWXUIContext.shared().launchCardPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: "The session created above",
    supportedBrands: "accepted card brands"
)
```
```objc
[AWXUIContext.sharedContext launchCardPaymentFrom:"hosting view controller which also handles AWXPaymentResultDelegate"
                                          session:"The session created above" 
                                  supportedBrands:"accepted card brands"
                                            style:"push or present"]
```

#### Launch payment method by name
all available payment method name can be found in [API reference](https://www.airwallex.com/docs/api#/Payment_Acceptance/Config/_api_v1_pa_config_payment_method_types/get)  - JSON Object field: items.name
```swift
AWXUIContext.shared().launchPayment(
    name: "payment method name",
    from: "hosting view controller",
    session: "The session created above",
    paymentResultDelegate: "object handles AWXPaymentResultDelegate"
)
```
```objc
[AWXUIContext.sharedContext launchPaymentWithName:"payment method name"
                                             from:"hosting view controller which also handles AWXPaymentResultDelegate"
                                          session:"The session created above" 
                            paymentResultDelegate:"object handles AWXPaymentResultDelegate"
                                  supportedBrands:"accepted card brands - required for card payment"
                                            style:"push or present"]
```

### Handle payment result

After the user completes the payment successfully or with error, you need to handle the payment result.
``` swift
// MARK: - AWXPaymentresultDelegate
func paymentViewController(_ controller: UIViewController?, didCompleteWith status: AirwallexPaymentStatus, error: Error?) {
    // Status may be success/in progress/ failure / cancel
}
```

```objc
#pragma mark - AWXPaymentResultDelegate

- (void)paymentViewController:(UIViewController *_Nullable)controller didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error
{
// Status may be success/in progress/ failure / cancel
}
```

If the payment consent is created during payment process, you can implement this optional function to get the id of this payment consent for any further usage.
```swift
func paymentViewController(_ controller: UIViewController?, didCompleteWithPaymentConsentId paymentConsentId: String) {
    // To do anything with this id.
}
```
```objc
- (void)paymentViewController:(UIViewController *)controller didCompleteWithPaymentConsentId:(NSString *)Id {
    // To do anything with this id.
}
```

### Low-level API Integration

You can build your own entirely custom UI on top of our low-level APIs.

You still need all the other steps in [Basic Integration](#basic-integration) section to set up configurations, intent and session, except the Airwallex UI Integration is replace by PaymentSessionHandler and low level API integration:

#### Initialize PaymentSessionHandler 

```swift
let paymentSessionHandler = PaymentSessionHandler(
    session: "The session created above", 
    viewController: "hosting view controller which also handles AWXPaymentResultDelegate"
)
// After initialization, you will need to store the `paymentSessionHandler` in your view controller or class that is tied to your view's lifecycle
self.paymentSessionHandler = paymentSessionHandler
```
```objc
PaymentSessionHandler *paymentSessionHandler = [[PaymentSessionHandler alloc] initWithSession:"The session created above"
                                                                        viewController:"hosting view controller which also handles AWXPaymentResultDelegate" 
                                                                            methodType:nil];
// After initialization, you will need to store the `sessionHandler` in your view controller or class that is tied to your view's lifecycle
self.paymentSessionHandler = paymentSessionHandler;
```
#### Pay with card
```swift
// Confirm intent with card and billing
paymentSessionHandler.startCardPayment(
    with: "The AWXCard object collected by your custom UI",
    billing: "Billing info collected by your custom UI"
)
```
```objc
// Confirm intent with card and billing
[sessionHandler startCardPaymentWith: "The AWXCard object collected by your custom UI" 
                             billing: "The AWXPlaceDetails object collected by your custom UI" 
                            saveCard: "Whether you want the card to be saved as payment consent for future payments"];
```
#### Pay with saved card (consent)
``` swift
// Confirm intent with a payment consent object (AWXPaymentConsent)
paymentSessionHandler.startConsentPayment(with: "paymentConsent")
// Confirm intent with a valid payment consent ID only when the saved card is **network token**
paymentSessionHandler.startConsentPayment(withId: "consent id")
```
```objc
// Confirm intent with a payment consent object (AWXPaymentConsent)
[paymentSessionHandler startConsentPaymentWith:"payment consent object"];
// Confirm intent with a valid payment consent ID only when the saved card is **network token**
[paymentSessionHandler startConsentPaymentWithId:"cst_xxxxxxxxxx"];
``` 
#### Pay with Apple Pay
``` swift
// start apple pay flow
paymentSessionHandler.startApplePay()
```
```objc
[paymentSessionHandler startApplePay];
```
// Confirm intent with a valid payment method name that supports redirect pay
// [provider confirmPaymentIntentWithPaymentMethodName:@"payment method name"];

#### Pay with Redirect
``` swift
paymentSessionHandler.startSchemaPayment(
    with: "payment method name",
    additionalInfo: "dictionary of all required information by this payment method"
)
```
```objc
[handler startSchemaPaymentWith:"payment method name"
                 additionalInfo:"dictionary of all required information by this payment method"];
```

### Set Up WeChat Pay
After completing payment, WeChat will be redirected to the merchant's app and do a callback using onResp(), then it can retrieve the payment intent status after the merchant server is notified, so please keep listening to the notification.
* make sure you correctly integrate `AirwallexWeChatpay` (Swift package manager) or `Airwallex/WechatPay` (Cocoapods)
* integrate `WechatOpenSDK` following the [official integration document](https://developers.weixin.qq.com/doc/oplatform/en/Mobile_App/Access_Guide/iOS.html)

``` swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        WXApi.registerApp("WeChat app id", universalLink: "universal link of your app")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NotificationCenter.default.post(name: PaymentResultViewController.paymentResultNotification, object: nil)
        return WXApi.handleOpen(url, delegate: self)
    }
}

extension AppDelegate: WXApiDelegate {
    func onResp(_ resp: BaseResp) {
        if let response = resp as? PayResp {
            switch response.errCode {
            case WXSuccess.rawValue:
                // handle success
            case WXErrCodeUserCancel.rawValue:
                // handle cancel
            default:
                // handle failure
            }
        }
    }
}
```

```objc
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [WXApi registerApp:@"WeChat app id" universalLink:"universal link of your app"];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [WXApi handleOpenURL:url delegate:self];
}

/**
 You can retrieve the payment intent status after your server is notified
 */
- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayResp class]]) {
        NSString *message = nil;
        PayResp *response = (PayResp *)resp;
        switch (response.errCode) {
            case WXSuccess:
                // handle success
                break;
            case WXErrCodeUserCancel:
                // handle cancel
                break;
            default:
                // handle failure
                break;
        }
    }
}
for more details please refer to:[Wechat document](https://developers.weixin.qq.com/doc/oplatform/en/Mobile_App/Access_Guide/iOS.html)

@end
```

### Set Up Apple Pay

The Airwallex iOS SDK allows merchants to provide Apple Pay as a payment method to their customers. 

- Make sure Apple Pay is set up correctly in the app. For more information, refer to Apple's official [doc](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay).
- Make sure Apple Pay is enabled on your Airwallex account.
- Include the Apple Pay module when installing the SDK.
- Prepare the [Merchant Identifier](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay) and configure `applePayOptions` on the payment session object.

Apple Pay will now be presented as an option in the payment method sheet.
``` swift
let session = AWXOneOffSession()
...
... configure other properties
...
session.applePayOptions = AWXApplePayOptions(merchantIdentifier: "Your Merchant Identifier")
```
```objc
AWXOneOffSession *session = [AWXOneOffSession new];
...
... configure other properties
...
session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"Merchant Identifier"];
```

#### Customize Apple Pay

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
``` objc
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

#### Limitations

Be aware that we currently support the following payment networks for Apple Pay:
- Visa
- MasterCard
- ChinaUnionPay
- Maestro (iOS 12+)
- Amex
- Discover
- JCB

Customers will only be able to select the cards of the above payment networks during Apple Pay.

Coupon is also not supported at this stage.

### Theme Color

You can customize the theme color.
``` swift
AWXTheme.shared().tintColor = .red
```
``` objc
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

- Update key file (Optional)

In the `Examples/Keys` folder, edit `Keys.json` with proper keys.

- Build and run `Examples` schema

If you didn't update the key file, you can use the in-app setting screen to update the keys.
Make sure to tap `Generate customer` button first before continuing with checkouts.

## Contributing

We welcome contributions of any kind including new features, bug fixes, and documentation improvements. The best way to contribute is by submitting a pull request – we'll do our best to respond to your patch as soon as possible. You can also submit an issue if you find bugs or have any questions.
