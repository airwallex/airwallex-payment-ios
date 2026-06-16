<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/Session",
  "metadataVersion" : "0.1.0",
  "role" : "Class",
  "symbol" : {
    "kind" : "Class",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)Session"
  },
  "title" : "Session"
}
-->

# Session

**Class**

`Session` is a specialized subclass of `AWXSession`

```
@objc final class Session
```

## Overview

This class provides a unified interface for working with the simplified consent flow,
abstracting away the complexity of different payment scenarios (one-off and recurring payments).
It handles both standard payment intents and recurring payment configurations through a
consistent API, making it easier to implement payment processing in your application.

> SeeAlso: `AWXSession`, `PaymentConsentOptions`

## Initializers

[`init(paymentIntent:countryCode:applePayOptions:autoCapture:autoSaveCardForFuturePayments:billing:hidePaymentConsents:lang:paymentMethods:paymentConsentOptions:requiredBillingContactFields:returnURL:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/session/init(paymentintent-countrycode-applepayoptions-autocapture-autosavecardforfuturepayments-billing-hidepaymentconsents-lang-paymentmethods-paymentconsentoptions-requiredbillingcontactfields-returnurl-).md)

[`init(paymentIntentProvider:countryCode:applePayOptions:autoCapture:autoSaveCardForFuturePayments:billing:hidePaymentConsents:lang:paymentMethods:paymentConsentOptions:requiredBillingContactFields:returnURL:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/session/init(paymentintentprovider-countrycode-applepayoptions-autocapture-autosavecardforfuturepayments-billing-hidepaymentconsents-lang-paymentmethods-paymentconsentoptions-requiredbillingcontactfields-returnurl-).md)

## Instance Properties

[`autoCapture`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/session/autocapture.md)

[`autoSaveCardForFuturePayments`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/session/autosavecardforfuturepayments.md)

[`paymentConsentOptions`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/session/paymentconsentoptions.md)

[`paymentIntent`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/session/paymentintent.md)

[`paymentIntentProvider`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/session/paymentintentprovider.md)

## Instance Methods

[`amount()`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/session/amount().md)

[`currency()`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/session/currency().md)

[`customerId()`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/session/customerid().md)

[`paymentIntentId()`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/session/paymentintentid().md)

[`transactionMode()`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/session/transactionmode().md)
