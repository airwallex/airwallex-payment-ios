# Airwallex iOS SDK

![Pod Version](https://img.shields.io/cocoapods/v/Airwallex.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/Airwallex.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/Airwallex.svg?style=flat)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-green.svg?style=flat)](https://github.com/Carthage/Carthage)
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
	  * [Carthage](#carthage)
	  * [Swift](#swift)
      * [Basic Integration](#basic-integration)
      * [Set Up WeChat Pay](#set-up-wechat-pay)
      * [Theme Color](#theme-color)
   * [Examples](#examples)
   * [Contributing](#contributing)
<!--te-->

## Requirements
The Airwallex iOS SDK requires Xcode 11.0 or later and is compatible with apps targeting iOS 11.0 or above.

## Integration

### CocoaPods

Airwallex for iOS is available through either [CocoaPods](https://cocoapods.org/) or [Carthage](https://github.com/Carthage/Carthage).

If you haven't already, install the latest version of [CocoaPods](https://cocoapods.org/).
If you don't have an existing `Podfile`, run the following command to create one:
```ruby
pod init
```
Add this line to your Podfile:
```ruby
pod 'Airwallex'
```
Run the following command
```ruby
pod install
```
Don’t forget to use the `.xcworkspace` file to open your project in Xcode, instead of the `.xcodeproj` file, from here on out.
In the feature, to update to the latest version of the SDK, just run:
```ruby
pod update Airwallex
```

### Carthage

```ogdl
github "airwallex/airwallex-payment-ios"
```

### Swift

Even though `Airwallex` is written in Objective-C, it can be used in Swift with no hassle. If you use [CocoaPods](https://cocoapods.org/),  add the following line to your [Podfile](https://guides.cocoapods.org/using/using-cocoapods.html):

```ruby
use_frameworks!
```

### Basic Integration

When your app starts, configure the SDK with  `mode`.

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
Note: When checkoutMode is AirwallexCheckoutRecurringMode, no need to create payment intent, then you need generate client secret with customer id and pass it to AWXAPIClientConfiguration.
```
[AWXAPIClientConfiguration sharedConfiguration].clientSecret = "The client secret generated with customer id";
```

- Create session

If you want to make one-off payment, create one-off session.
```
AWXOneOffSession *session = [AWXOneOffSession new];
session.countryCode = "Your country code";
session.billing = "Your shipping address";
session.returnURL = "App return url";
session.paymentIntent = "Payment intent";
session.autoCapture = "Whether the card payment will be captured automatically (Default YES)";
```

If you want to make recurring, create recurring session.
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

If you want to make recurring with payment intent, create recurring with intent session.
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

- Handle the one-off payment or recurring flow

Add a button to let the customer enter or change their payment method. When tapped, use `AWXUIContext` to present the payment flow.

```objective-c
AWXUIContext *context = [AWXUIContext sharedContext];
context.delegate = ”The target to handle AWXPaymentResultDelegate protocol”;
context.session = session;
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

### Theme Color

You can customize the theme color.

```
UIColor *tintColor = [UIColor colorWithRed:97.0f/255.0f green:47.0f/255.0f blue:255.0f/255.0f alpha:1];
[AWXTheme sharedTheme].tintColor = tintColor;
[UIView.appearance setTintColor:tintColor];
```

## Examples

To run the example project, you should follow these steps.

- Preparing

1. Install the [lastest version](https://itunes.apple.com/us/app/xcode/id497799835?mt=12) of Xcode and iOS SDK from Mac Store.

2. Install [Bundle](https://bundler.io/)

```ruby
gem install bundler
```

- Clone source code

Run the following script to clone this project to your local disk.

```
git clone git@github.com:airwallex/airwallex-payment-ios.git
```

- Install dependencies and open project

1. Go into the project directory

```
cd airwallex-payment-ios
```

2. Install dependencies

```
bundle install
```

```
pod install
```

3. Open `Airwallex.xcworkspace` from Xcode or run the following script to open it. **Be sure you always open the project from the work space.**

```
open Airwallex.xcworkspace
```

- Build Configurations

There are two schemes `Airwallex` and `Examples`. You can switch the schemes in project scheme settings.

`Airwallex` will generate a framework for developer

`Examples` will build and run an example application

- Run the app on your iOS device

Select your target device from the top left panel, then press "Command + R" on your keyboard (or "Product > Run" from the top menu bar) to run this project on your iOS device.

## Contributing

We welcome contributions of any kind including new features, bug fixes, and documentation improvements. The best way to contribute is by submitting a pull request – we'll do our best to respond to your patch as soon as possible. You can also submit an issue if you find bugs or have any questions.
