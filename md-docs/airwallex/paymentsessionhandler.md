<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentSessionHandler",
  "metadataVersion" : "0.1.0",
  "role" : "Class",
  "symbol" : {
    "kind" : "Class",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)PaymentSessionHandler"
  },
  "title" : "PaymentSessionHandler"
}
-->

# PaymentSessionHandler

**Class**

A low-level API handler for managing Airwallex payment sessions.

```
@MainActor class PaymentSessionHandler
```

## Overview

`PaymentSessionHandler` provides direct control over payment processing without pre-built UI components.
It’s designed for developers who want to implement custom payment flows while leveraging Airwallex’s
payment processing capabilities.

## Usage

```swift
let handler = PaymentSessionHandler(
    session: session,
    viewController: self,
    paymentResultDelegate: self
)

// Handle card payment
handler.startCardPayment(
    card: card,
    billing: billing,
    saveCard: true
)

// Handle Apple Pay
handler.startApplePay()
```

This class handles:

- Direct payment method processing
- Payment result callbacks
- Error handling and validation
- Custom payment flow integration

## Initializers

[`init(session:viewController:methodType:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentsessionhandler/init(session-viewcontroller-methodtype-).md)

[`init(session:viewController:paymentResultDelegate:methodType:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentsessionhandler/init(session-viewcontroller-paymentresultdelegate-methodtype-).md)

## Instance Properties

[`showIndicator`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentsessionhandler/showindicator.md)

## Instance Methods

[`startApplePay()`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentsessionhandler/startapplepay().md)

[`startCardPayment(with:billing:saveCard:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentsessionhandler/startcardpayment(with-billing-savecard-).md)

[`startConsentPayment(with:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentsessionhandler/startconsentpayment(with-).md)

[`startConsentPayment(withId:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentsessionhandler/startconsentpayment(withid-).md)

[`startConsentPayment(withId:requiresCVC:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentsessionhandler/startconsentpayment(withid-requirescvc-).md)

[`startRedirectPayment(with:additionalInfo:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentsessionhandler/startredirectpayment(with-additionalinfo-).md)

## Type Methods

[`canHandle(methodType:session:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentsessionhandler/canhandle(methodtype-session-).md)

## Default Implementations

[`AWXProviderDelegate Implementations`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentsessionhandler/awxproviderdelegate-implementations.md)
