# Airwallex iOS SDK

![Pod Version](https://img.shields.io/cocoapods/v/Airwallex.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/Airwallex.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/Airwallex.svg?style=flat)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-green.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)

The Airwallex iOS SDK is a framework for integrating easy, fast and secure payments inside your app with Airwallex.

## Requirements
The Airwallex iOS SDK requires Xcode 9.3 or later and is compatible with apps targeting iOS 10 or above.

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

### Initialize Airwallex SDK

The specific base URL can be set in an instance of `Airwallex`.

```
[Airwallex setDefaultBaseURL:[NSURL URLWithString:@"Airwallex payment base URL"]];
```

### Using `AWAPIClient`

Please set client secret before using `AWAPIClient` to send a request.

```
[AWAPIClientConfiguration sharedConfiguration].clientSecret = "The client secret merchant provides";
AWAPIClient *client = [[AWAPIClient alloc] initWithConfiguration:[AWAPIClientConfiguration sharedConfiguration]];
```

### Examples

There is an example app included in the repository and it provides the way how to check out with WeChat SDK.

### Calling APIs

Use `AWAPIClient` with an instance of `AWAPIClientConfiguration` including basic parameters such as `baseURL` and `client secret` to send a request.

A request to confirm payment intent using: `AWConfirmPaymentIntentRequest`

A request to get payment intent using: `AWRetrievePaymentIntentRequest`

## Contributing
We welcome contributions of any kind including new features, bug fixes, and documentation improvements. The best way to contribute is by submitting a pull request – we'll do our best to respond to your patch as soon as possible. You can also submit an issue if you find bugs or have any questions.
