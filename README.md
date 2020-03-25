# Airwallex iOS SDK

![Pod Version](https://img.shields.io/cocoapods/v/Airwallex.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/Airwallex.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/Airwallex.svg?style=flat)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-green.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)

The Airwallex iOS SDK is a framework for integrating easy, fast and secure payments inside your app with Airwallex. It provides simple functions to send sensitive credit card data directly to Airwallex, it also provides a powerful, customizable interface for collecting user payment details.

## Requirements
The Airwallex iOS SDK requires Xcode 10 or later and is compatible with apps targeting iOS 10 or above.

## Installation

### CocoaPods

```ruby
pod 'Airwallex'
```

### Carthage

```ogdl
github "airwallex/airwallex-payment-ios"
```

## Swift

Even though `Airwallex` is written in Objective-C, it can be used in Swift with no hassle. If you use [CocoaPods](http://cocoapods.org),  add the following line to your [Podfile](http://guides.cocoapods.org/using/using-cocoapods.html):

```ruby
use_frameworks!
```

## Usage

### Integration

### 1. Initialize AWPaymentConfiguration

These payment method specific configuration parameters can be set in an instance of `AWPaymentConfiguration`.

```
AWPaymentConfiguration *configuration = [AWPaymentConfiguration sharedConfiguration];
configuration.shipping = "Your shipping address";
configuration.totalNumber = "Your total amount";
configuration.delegate = self;
configuration.baseURL = "Payment server URL";
configuration.intentId = "Payment intent ID";
configuration.clientSecret = "Client secret";
configuration.currency = "Your currency";
configuration.customerId = "Your customer ID";
```

### 2. Present Shipping UI

Use AWPaymentUI to get an UINavigationController including `AWEditShippingViewController` and present it.

```
UINavigationController *navigationController = [AWPaymentUI shippingNavigationController];
[self presentViewController:navigationController animated:YES completion:nil];
```

### 3. Present Payment Method List UI

Use AWPaymentUI to get an UINavigationController including `AWPaymentMethodListViewController` and present it.

```
UINavigationController *navigationController = [AWPaymentUI paymentMethodListNavigationController];
[self presentViewController:navigationController animated:YES completion:nil];
```

### 4. Present New Credit Card UI

Use AWPaymentUI to get an UINavigationController including `AWCardViewController` and present it.

```
UINavigationController *navigationController = [AWPaymentUI newCardNavigationController];
[self presentViewController:navigationController animated:YES completion:nil];
```

### 5. Present Payment Detail UI to confirm

Use AWPaymentUI to get an UINavigationController including `AWPaymentViewController` and present it.

```
UINavigationController *navigationController = [AWPaymentUI paymentDetailNavigationController];
[self presentViewController:navigationController animated:YES completion:nil];
```

### Examples

There is an example app included in the repository and it provides the way how to check out with WeChat SDK and Credit Card.

### Calling APIs

Use `AWAPIClient` to send a request.

A request to confirm payment intent using: `AWConfirmPaymentIntentRequest`

A request to get payment intent using: `AWGetPaymentIntentRequest`

## Contributing
We welcome contributions of any kind including new features, bug fixes, and documentation improvements. The best way to contribute is by submitting a pull request – we'll do our best to respond to your patch as soon as possible. You can also submit an issue if you find bugs or have any questions.
