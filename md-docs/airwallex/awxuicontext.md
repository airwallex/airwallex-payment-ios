<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXUIContext",
  "metadataVersion" : "0.1.0",
  "role" : "Class",
  "symbol" : {
    "kind" : "Class",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)AWXUIContext"
  },
  "title" : "AWXUIContext"
}
-->

# AWXUIContext

**Class**

The main UI context for Airwallex payment flows.

```
@MainActor @objc class AWXUIContext
```

## Overview

`AWXUIContext` provides a high-level interface for launching pre-built payment flows.
It handles the presentation of payment forms, user interactions, and payment processing
with minimal integration effort.

## Usage

```swift
let context = AWXUIContext()
context.launchPayment(
    from: viewController,
    session: session
)
```

## Classes

[`AWXUIContext.Configuration`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext/configuration.md)

## Type Properties

[`shared`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext/shared.md)

## Type Methods

[`launchCardPayment(from:session:paymentResultDelegate:supportedBrands:launchStyle:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext/launchcardpayment(from-session-paymentresultdelegate-supportedbrands-launchstyle-).md)

[`launchCardPayment(from:session:supportedBrands:launchStyle:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext/launchcardpayment(from-session-supportedbrands-launchstyle-).md)

[`launchPayment(from:session:configuration:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext/launchpayment(from-session-configuration-).md)

[`launchPayment(from:session:filterBy:launchStyle:layout:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext/launchpayment(from-session-filterby-launchstyle-layout-).md)

[`launchPayment(from:session:paymentResultDelegate:configuration:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext/launchpayment(from-session-paymentresultdelegate-configuration-).md)

[`launchPayment(from:session:paymentResultDelegate:filterBy:launchStyle:layout:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext/launchpayment(from-session-paymentresultdelegate-filterby-launchstyle-layout-).md)

[`launchPayment(name:from:session:paymentResultDelegate:supportedBrands:launchStyle:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext/launchpayment(name-from-session-paymentresultdelegate-supportedbrands-launchstyle-).md)

## Enumerations

[`AWXUIContext.ElementType`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext/elementtype.md)

[`AWXUIContext.LaunchError`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext/launcherror.md)

[`AWXUIContext.LaunchStyle`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext/launchstyle.md)

[`AWXUIContext.PaymentLayout`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext/paymentlayout.md)
