# Airwallex iOS SDK

[![CocoaPods](https://img.shields.io/cocoapods/v/Airwallex.svg?style=flat)](http://cocoapods.org/?q=author%3AAirwallex%20name%3AAirwallex)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Airwallex.svg?style=flat)](https://github.com/airwallex/airwallex-payment-ios/blob/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/Airwallex.svg?style=flat)](https://github.com/airwallex/airwallex-payment-ios#)

The Airwallex iOS SDK makes it quick and easy to build an excellent payment experience in your iOS app. We provide powerful and customizable UI screens and elements that can be used out-of-the-box to collect your users’ payment details. We also expose the low-level APIs that power those UIs so that you can build fully custom experiences.

Get started with our integration guide and example project.

Table of contents
=================

<!--ts-->
   * [Features](#features)
   * [Releases](#releases)
   * [Requirements](#requirements)
   * [Getting Started](#getting-started)
      * [Integration](#integration)
      * [Examples](#examples)
   * [Contributing](#contributing)
   * [Running Tests](#running-tests)
<!--te-->

## Features

**Simplified Security**: We make it simple for you to collect sensitive data such as credit card numbers. This means the sensitive data is sent directly to Airwallex instead of passing through your server.

**WeChat Pay**: We provide a seamless integration with WeChat Pay.

**3DS**: The SDK automatically performs native 3D Secure authentication if needed.

**Airwallex API**: We provide low-level APIs that correspond to objects and methods in the Airwallex API. You can build your own entirely custom UI on top of this layer, while still taking advantage of utilities like `AWCardValidator` to validate your user’s input.

**Native UI**: We provide native screens to collect payment and shipping details. For example, `AWCardViewController` is a UIViewController that collects, validates card details and finishes saving.

You can use these individually, or take all of the prebuilt UI in one flow by following the Basic Integration guide.

From let to right: `AWCardViewController`, `AWPaymentMethodListViewController`, `AWEditShippingViewController`, `AWPaymentViewController`

## Releases

We recommend installing the Airwallex iOS SDK using a package manager such as Cocoapods or Carthage. If you link the library manually, use a version from our releases page.

If you’re reading this on GitHub.com, please make sure you are looking at the tagged version that corresponds to the release you have installed. Otherwise, the instructions and example code may be mismatched with your copy. You can read the latest tagged version of this README and browse the associated code on GitHub.

## Requirements
The Airwallex iOS SDK requires Xcode 10.0 or later and is compatible with apps targeting iOS 10 or above.

## Getting Started

### Integration

Get started with our [📚 integration guides](https://www.airwallex.com/docs/#overview) and [example projects](#examples), or [📘 browse the SDK reference](https://www.airwallex.com/docs/#overview) for fine-grained documentation of all the classes and methods in the SDK.

### Examples

There is an example app included in the repository and it provides the way how to check out with WeChat SDK.

## Contributing
We welcome contributions of any kind including new features, bug fixes, and documentation improvements. Please first open an issue describing what you want to build if it is a major change so that we can discuss how to move forward. Otherwise, go ahead and open a pull request for minor changes such as typo fixes and one liners.

## Running Tests
We will add some unit tests for this later.

