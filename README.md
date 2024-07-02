# Airwallex iOS SDK

![Pod Version](https://img.shields.io/cocoapods/v/Airwallex.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/Airwallex.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/Airwallex.svg?style=flat)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)

- [Chinese Tutorial](README_zh_CN.md)
- [API Reference](https://airwallex.github.io/airwallex-payment-ios/)

The Airwallex iOS SDK is a framework for integrating easy, fast and secure payments inside your app with Airwallex. It provides simple functions to send sensitive credit card data directly to Airwallex, it also provides a powerful, customizable interface for collecting user payment details.

<p align="center">
<img src="./Screenshots/shipping.png" width="200" alt="AWXShippingViewController" hspace="10">
<img src="./Screenshots/card.png" width="200" alt="AWXCardViewController" hspace="10">
<img src="./Screenshots/payment method list.png" width="200" alt="AWXPaymentMethodListViewController" hspace="10">
<img src="./Screenshots/payment.png" width="200" alt="AWXPaymentViewController" hspace="10">
</p>

Get started with our integration guide and example project.

Table of contents
=================

<!--ts-->
   * [Requirements](#requirements)
   * [Integration](#integration)
      * [CocoaPods](#cocoapods)
	  * [Swift](#swift)
      * [Basic Integration](#basic-integration)
      * [Set Up WeChat Pay](#set-up-wechat-pay)
      * [Set Up Apple Pay](#set-up-apple-pay)
      * [Theme Color](#theme-color)
   * [Examples](#examples)
   * [Contributing](#contributing)
<!--te-->

## Requirements
The Airwallex iOS SDK supports iOS 13.0 and above.

## Integration

### CocoaPods

Airwallex for iOS is available through [CocoaPods](https://cocoapods.org/).

Add this line to your `Podfile`:
```ruby
pod 'Airwallex'
```

Optionally, you can also include the modules directly (This is recommended to ensure minimal dependency):

```ruby
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

### Swift

Even though `Airwallex` is written in Objective-C, it can be used in Swift with no hassle. If you use [CocoaPods](https://cocoapods.org/),  add the following line to your [Podfile](https://guides.cocoapods.org/using/using-cocoapods.html):

```ruby
use_frameworks!
```

### Basic Integration

This is **recommended usage**, it builds a complete user flow on top of your app with our prebuilt UI to collect payment details, billing details, and confirming the payment.

When your app starts, configure the SDK with `mode`.

```objective-c
[Airwallex setMode:AirwallexSDKStagingMode]; // AirwallexSDKDemoMode, AirwallexSDKStagingMode, AirwallexSDKProductionMode
```

If you want to test on different endpoint, you can customize mode and payment URL.

```objective-c
[Airwallex setDefaultBaseURL:[NSURL URLWithString:@”Airwallex payment base URL”]];
```

- Create a payment intent

When the customer wants to checkout an order, you should create a payment intent on your server-side and then pass the payment intent to the mobile-side to confirm the payment intent with the payment method selected.

```
[AWXAPIClientConfiguration sharedConfiguration].clientSecret = "The payment intent's client secret";
```

Note: When `checkoutMode` is `AirwallexCheckoutRecurringMode`, there is no need to create a payment intent. Instead, you'll need to generate a client secret with the customer id and pass it to `AWXAPIClientConfiguration`.
```
[AWXAPIClientConfiguration sharedConfiguration].clientSecret = "The client secret generated with customer id";
```

- Create session

If you want to make a one-off payment, create a one-off session.
```
AWXOneOffSession *session = [AWXOneOffSession new];
session.countryCode = "Your country code";
session.billing = "Your shipping address";
session.returnURL = "App return url";
session.paymentIntent = "Payment intent";
session.autoCapture = "Whether the card payment will be captured automatically (Default YES)";
```

If you want to make a recurring payment, create a recurring session.
```
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
```

If you want to make a recurring with payment intent, create a recurring with intent session.
```
AWXRecurringWithIntentSession *session = [AWXRecurringWithIntentSession new];
session.countryCode = "Your country code";
session.billing = "Your shipping address";
session.returnURL = "App return url";
session.paymentIntent = "Payment intent";
session.autoCapture = "Whether the card payment will be captured automatically (Default YES)";
session.nextTriggerByType = "customer or merchant";
session.requiresCVC = "Whether it requires CVC (Default NO)";
session.merchantTriggerReason = "Unscheduled or scheduled";
```

- Present one-off payment or recurring flow

Upon checkout, use `AWXUIContext` to present the payment flow where the user will be able to select the payment method.

```objective-c
AWXUIContext *context = [AWXUIContext sharedContext];
context.delegate = "The target to handle AWXPaymentResultDelegate protocol";
context.session = "The session created above";
[context presentPaymentFlowFrom:self];
```

- Handle the payment result

After the user completes the payment successfully or with error, you need to handle the payment result.

```objective-c
#pragma mark - AWXPaymentResultDelegate

- (void)paymentViewController:(UIViewController *)controller didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:^{
        // Status may be success/in progress/ failure / cancel
    }];
}
```

If the payment consent is created during payment process, you can implement this optional function to get the id of this payment consent for any further usage.

```objective-c
- (void)paymentViewController:(UIViewController *)controller didCompleteWithPaymentConsentId:(NSString *)Id {
    // To do anything with this id.
}
```

### Low-level API Integration

You can build your own entirely custom UI on top of our low-level APIs.

#### Confirm card payment with card and billing details or payment consent ID

You still need all the other steps in [Basic Integration](#basic-integration) section to set up configurations, intent and session, except the step **Present one-off payment or recurring flow** is replaced by:

```objective-c
AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:"The target to handle AWXProviderDelegate protocol" session:"The session created above"];
// After initialization, you will need to store the provider in your view controller or class that is tied to your view's lifecycle
self.provider = provider;

// Confirm intent with card and billing
[provider confirmPaymentIntentWithCard:"The AWXCard object collected by your custom UI" billing:"The AWXPlaceDetails object collected by your custom UI" saveCard:"Whether you want the card to be saved as payment consent for future payments"];

// Or to confirm intent with a valid payment consent ID
[provider confirmPaymentIntentWithPaymentConsentId:@"cst_xxxxxxxxxx"];
``` 

You also need to provide your host view controller which we use to present additional UI (e.g. 3DS page, alert) on top
```objective-c
#pragma mark - AWXProviderDelegate

- (UIViewController *)hostViewController {
    // Your host view controller
}

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error {
    // You can handle different payment statuses and perform UI action respectively here
}
```

If the payment consent is created during payment process, you can implement this optional function to get the id of this payment consent for any further usage.

```objective-c
- (void)provider:(AWXDefaultProvider *)provider didCompleteWithPaymentConsentId:(NSString *)Id {
    // To do anything with this id.
}
```

#### Launch payment with Apple Pay provider

You still need all the other steps in [Basic Integration](#basic-integration) section to set up configurations, intent and session, except the step **Present one-off payment or recurring flow** is replaced by:

```objective-c
AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:"The target to handle AWXProviderDelegate protocol" session:"The one off session created with apple pay options"];

// After initialization, you will need to store the provider in your view controller or class that is tied to your view's lifecycle
self.provider = provider;

// Initiate the apple pay flow
 [provider startPayment];

``` 

You need to implement the delegate method to handle the result
```objective-c
#pragma mark - AWXProviderDelegate

- (void)provider:(nonnull AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error {
    switch (status) {
    case AirwallexPaymentStatusSuccess:
       // handle success
        break;
    case AirwallexPaymentStatusFailure:
       // handle failure
        break;
    case AirwallexPaymentStatusCancel:
       // handle Apple Pay cancelled by the user
        break;
    default:
        break;
    }
}
```

### Set Up WeChat Pay

After completing payment, WeChat will be redirected to the merchant's app and do a callback using onResp(), then it can retrieve the payment intent status after the merchant server is notified, so please keep listening to the notification.

```objective-c
@interface AppDelegate () <WXApiDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [WXApi registerApp:@"WeChat app id" universalLink:@"https://airwallex.com/"];
    
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
                message = NSLocalizedString(@"Succeed to pay", nil);
                break;
            case WXErrCodeUserCancel:
                message = NSLocalizedString(@"User cancelled.", nil);
                break;
            default:
                message = NSLocalizedString(@"Failed to pay", nil);
                break;
        }
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil]];
        [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
    }
}

@end
```

### Set Up Apple Pay

The Airwallex iOS SDK allows merchants to provide Apple Pay as a payment method to their customers. 

- Make sure Apple Pay is set up correctly in the app. For more information, refer to Apple's official [doc](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay).
- Make sure Apple Pay is enabled on your Airwallex account.
- Include the Apple Pay module when installing the SDK.
- Prepare the [Merchant Identifier](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay) and configure `applePayOptions` on the payment session object.

Apple Pay will now be presented as an option in the payment method sheet.

```objective-c
AWXOneOffSession *session = [AWXOneOffSession new];
...
... configure other properties
...

session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"Merchant Identifier"];
```

> Please note that Apple Pay only supports `AWXOneOffSession` at the moment. We'll add support for recurring payment sessions in the future.

#### Customize Apple Pay

You can customize the Apple Pay options to restrict it as well as provide extra context. For more information, please refer to the `AWXApplePayOptions.h` header file.

```
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

Customers will only be able to select the cards of the above payment networks during Apple Pay.

Coupon is also not supported at this stage.

### Theme Color

You can customize the theme color.

```
UIColor *tintColor = [UIColor colorWithRed:97.0f/255.0f green:47.0f/255.0f blue:255.0f/255.0f alpha:1];
[AWXTheme sharedTheme].tintColor = tintColor;
[UIView.appearance setTintColor:tintColor];
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

In the `Examples/Keys` folder, edit `Keys_sample.json` with proper keys and then rename it to `Keys.json`.

- Build and run `Examples` schema

If you didn't update the key file, you can use the in-app setting screen to update the keys.
Make sure to tap `Generate customer` button first before continuing with checkouts.

## Contributing

We welcome contributions of any kind including new features, bug fixes, and documentation improvements. The best way to contribute is by submitting a pull request – we'll do our best to respond to your patch as soon as possible. You can also submit an issue if you find bugs or have any questions.
