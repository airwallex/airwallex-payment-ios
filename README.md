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
      * [Customize Usage](#customize-usage)
      * [Set Up WeChat Pay](#set-up-wechat-pay)
      * [Theme Color](#theme-color)
   * [Examples](#examples)
   * [Contributing](#contributing)
<!--te-->

## Requirements
The Airwallex iOS SDK requires Xcode 10.0 or later and is compatible with apps targeting iOS 10 or above.

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
[Airwallex setMode:AirwallexSDKLiveMode];
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

- Generate client secret for customer service account

If you need create card, you should generate customer client secret and then pass it to the sdk.

```
[AWXCustomerAPIClientConfiguration sharedConfiguration].clientSecret = "The customer's client secret";
```

- Handle the payment flow

In your checkout screen, add a button to let the customer enter or change their payment method. When tapped, use `AWXUIContext` to present the payment flow.

```objective-c
AWXUIContext *context = [AWXUIContext sharedContext];
context.delegate = ”The target to handle AWXPaymentResultDelegate protocol”;
context.hostViewController = “The host viewController present or push the payment UIs”;
context.paymentIntent = “The payment intent merchant provides”;
context.shipping = “The shipping address merchant provides”;
[context presentPaymentFlow];
```

- Handle the payment result

After the user completes the payment successfully or with error, you need to handle the payment result.

```objective-c
/**
 A delegate which handles checkout results.
 */
@protocol AWXPaymentResultDelegate <NSObject>
 
/**
 This method is called when the user has completed the checkout.
 
 @param controller The controller handling payment result.
 @param status The status of checkout result.
 @param error The error if checkout failed.
 */
- (void)paymentViewController:(UIViewController *)controller didFinishWithStatus:(AWXPaymentStatus)status error:(nullable NSError *)error;
 
/**
 This method is called when the user has completed the checkout with wechat pay.
 
 @param controller The controller handling payment result.
 @param response The wechat object.
 */
- (void)paymentViewController:(UIViewController *)controller nextActionWithWeChatPaySDK:(AWXWeChatPaySDKResponse *)response;
 
@end
```

### Customize Usage

- Customize the usage of shipping info

Use `AWXUIContext` to get an instance of `AWXShippingViewController` and show it contained in a `UINavigationController`.

```objective-c
AWXShippingViewController *controller = [AWXUIContext shippingViewController];
controller.delegate = "The target to handle AWXShippingViewControllerDelegate protocol";
controller.shipping = "The shipping address merchant provides";
UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
[self presentViewController:navigationController animated:YES completion:nil];
```

- Handle the shipping result

```objective-c
/**
 A delegate which handles selected shipping.
 */
@protocol AWXShippingViewControllerDelegate <NSObject>
 
/**
 This method is called when a shipping has been saved.
 
 @param controller The shipping view controller.
 @param shipping The selected shipping.
 */
- (void)shippingViewController:(AWXShippingViewController *)controller didEditShipping:(AWXPlaceDetails *)shipping;
 
@end
```

- Customize the usage of card creation

Use `AWXUIContext` to get an instance of `AWXCardViewController` and show it contained in a `UINavigationController`.

```objective-c
AWXCardViewController *controller = [AWXUIContext newCardViewController];
controller.delegate = "The target to handle AWXCardViewControllerDelegate protocol";
controller.customerId = "The customer id merchant provides";
controller.sameAsShipping = YES;
controller.shipping = "The shipping address merchant provides";
UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
[self presentViewController:navigationController animated:YES completion:nil];
```

- Handle new card result

```objective-c
/**
 A delegate which handles card creation.
 */
@protocol AWXCardViewControllerDelegate <NSObject>
 
/**
 This method is called when a card has been created and saved to backend.
 
 @param controller The new card view controller.
 @param paymentMethod The saved card.
 */
- (void)cardViewController:(AWXCardViewController *)controller didCreatePaymentMethod:(AWXPaymentMethod *)paymentMethod;
 
@end
```

- Customize the usage of payment detail

Use `AWXUIContext` to get an instance of `AWXPaymentViewController` and show it contained in a `UINavigationController`.

```objective-c
AWXPaymentViewController *controller = [AWXUIContext paymentDetailViewController];
controller.delegate = "The target to handle AWXPaymentResultDelegate protocol";
controller.paymentIntent = "The payment intent merchant provides";
controller.paymentMethod = "The payment method merchant provides";
UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
[self presentViewController:navigationController animated:YES completion:nil];
```

- Customize the usage of confirming payment intent

Please set client secret before using `AWXAPIClient` to send a request.

```objective-c
[AWXAPIClientConfiguration sharedConfiguration].clientSecret = "The client secret merchant provides";
```

```objective-c
AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
request.intentId = "The payment intent id merchant provides";
request.paymentMethod = "The payment method merchant provides";
AWXPaymentMethodOptions *options = [AWXPaymentMethodOptions new];
options.autoCapture = YES;
options.threeDsOption = NO;
request.options = options;
request.requestId = NSUUID.UUID.UUIDString;

AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
[client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
	if (error) {
		return;
	}
 
	AWXConfirmPaymentIntentResponse *result = (AWXConfirmPaymentIntentResponse *)response;
	// Handle the payment result.
}];
```

- Customize the usage of 3ds flow

```
AWXThreeDSService *service = [AWXThreeDSService new];
service.customerId = "The customer id merchant provides";
service.intentId = "The intent id merchant provides";
service.paymentMethod = "The payment method merchant provides";
service.device = "The device id got by AWXSecurityService";
service.presentingViewController = “The host viewController present or push the payment UIs”;
service.delegate = ”The target to handle AWXThreeDSServiceDelegate protocol”;
[service presentThreeDSFlowWithServerJwt:"The server jwt backend provides"];
```

- Handle the result of 3ds flow

```objective-c
/**
 A delegate which handles 3ds results.
 */
@protocol AWXThreeDSServiceDelegate <NSObject>

/**
 This method is called when the user has completed the 3ds flow.
 
 @param service The service handling 3ds flow.
 @param response The response of 3ds auth.
 @param error The error if 3ds auth failed.
 */
- (void)threeDSService:(AWXThreeDSService *)service
 didFinishWithResponse:(nullable AWXConfirmPaymentIntentResponse *)response
                 error:(nullable NSError *)error;

@end
```

### Set Up WeChat Pay

Note: you can follow this official guide [WeChat In-App Pay](https://pay.weixin.qq.com/wiki/doc/api/wxpay/pay/In-AppPay/chapter6_2.shtml).

1. After the Merchant has successfully applied for an App in the WeChat Open Platform, the Platform will provide an unique APPID to the Merchant. When creating a project in Xcode, the developer should enter the APPID value in the “URL Schemes” field.

2. Before calling the API, you should register your APPID with WeChat.

```objective-c
[WXApi registerApp:@"Wechat app id" enableMTA:YES];
```

3. The merchant's server calls the Unified Order API to create an advanced transaction. After obtaining prepay_id and signing relevant parameters, the advanced transaction data is transferred to the app to start a payment.

```objective-c
- (void)paymentWithWechatPaySDK:(AWXWeChatPaySDKResponse *)response
{
	PayReq *request = [[PayReq alloc] init];
	request.partnerId = response.partnerId;
	request.prepayId = response.prepayId;
	request.package = response.package;
	request.nonceStr = response.nonceStr;
	request.timeStamp = response.timeStamp.doubleValue;
	request.sign = response.sign;

	[WXApi sendReq:request];
}
```

4. After completing payment, WeChat will be redirected to the merchant's app and do a callback using onResp(), then it can retrieve the payment intent status after the merchant server is notified, so please keep listening to the notification.

```objective-c
- (void)onResp:(BaseResp *)resp
{
	if ([resp isKindOfClass:[PayResp class]]) {
		PayResp *response = (PayResp *)resp;
		switch (response.errCode) {
			case WXSuccess:
				[SVProgressHUD showSuccessWithStatus:@"Succeed to pay"];
				break;
			default:
				[SVProgressHUD showErrorWithStatus:@"Failed to pay"];
				break;
		}
	}
}
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
