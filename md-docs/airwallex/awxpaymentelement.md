<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentElement",
  "metadataVersion" : "0.1.0",
  "role" : "Class",
  "symbol" : {
    "kind" : "Class",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)AWXPaymentElement"
  },
  "title" : "AWXPaymentElement"
}
-->

# AWXPaymentElement

**Class**

An embeddable payment element that can be added to any view hierarchy.

```
@MainActor @objc class AWXPaymentElement
```

## Overview

`AWXPaymentElement` provides a flexible way to integrate Airwallex payment UI into your app.
Unlike `AWXUIContext.launchPayment()` which presents a full payment sheet as a view controller,
`AWXPaymentElement` returns a `UIView` that you can embed in your own view hierarchy.

## Usage

```swift
let configuration = AWXPaymentElement.Configuration()
configuration.layout = .accordion

let element = try await AWXPaymentElement.create(
    session: session,
    delegate: self,
    configuration: configuration
)
containerView.addSubview(element.view)
```

## Important Notes

- The embedded view requires Auto Layout constraints for proper sizing
- The view’s height updates automatically based on content
- Keyboard handling is the host app’s responsibility

## Classes

[`AWXPaymentElement.Configuration`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentelement/configuration.md)

## Instance Properties

[`delegate`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentelement/delegate.md)

[`view`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentelement/view.md)

## Type Methods

[`create(session:delegate:configuration:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentelement/create(session-delegate-configuration-).md)

## Enumerations

[`AWXPaymentElement.ElementType`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentelement/elementtype.md)

## Default Implementations

[`AWXPaymentResultDelegate Implementations`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentelement/awxpaymentresultdelegate-implementations.md)
