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

### 1. Initialize Airwallex SDK

The specific base URL can be set in an instance of `Airwallex`.

```
[Airwallex setDefaultBaseURL:[NSURL URLWithString:@"Airwallex payment base URL"]];
```

### 2. Show Shipping UI

Use `AWUIContext` to get an instance of `AWEditShippingViewController` and show it contained in a `UINavigationController`.

```
AWEditShippingViewController *controller = [AWUIContext shippingViewController];
```

### 3. Show Payment Method List UI

Use `AWUIContext` to get an instance of `AWPaymentMethodListViewController` and show it contanined in a `UINavigationController`.

```
AWPaymentMethodListViewController *controller = [AWUIContext paymentMethodListViewController];
```

### 4. Show New Card UI

Use `AWUIContext` to get an instance of `AWCardViewController` and show it contanined in a `UINavigationController`.

```
AWCardViewController *controller = [AWUIContext newCardViewController];
```

### 5. Show Payment Detail UI

Use `AWUIContext` to get an instance of `AWPaymentViewController` and show it contanined in a `UINavigationController`.

```
AWPaymentViewController *controller = [AWUIContext paymentDetailViewController];
```

### 5. Show Payment Flow

Use `[AWUIContext sharedContext]` to get an instance of `AWUIContext` and show the payment flow using function `presentPaymentFlow` or `pushPaymentFlow`.

```
AWUIContext *context = [AWUIContext sharedContext];
context.delegate = "The target to get the payment result";
context.hostViewController = "The host viewController present or push the payment UIs";
context.paymentIntent = "The payment intent merchant provides";
context.shipping = "The shipping address merchant provides";
[context presentPaymentFlow];
```

### Examples

There is an example app included in the repository and it provides the way how to check out with WeChat SDK and Credit Card.

### Calling APIs

Use `AWAPIClient` with an instance of `AWAPIClientConfiguration` including basic parameters such as `baseURL` and `client secret` to send a request.

A request to confirm payment intent using: `AWConfirmPaymentIntentRequest`

A request to get payment intent using: `AWRetrievePaymentIntentRequest`

## Contributing
We welcome contributions of any kind including new features, bug fixes, and documentation improvements. The best way to contribute is by submitting a pull request – we'll do our best to respond to your patch as soon as possible. You can also submit an issue if you find bugs or have any questions.
