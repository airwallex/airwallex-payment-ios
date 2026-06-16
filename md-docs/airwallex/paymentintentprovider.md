<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentIntentProvider",
  "metadataVersion" : "0.1.0",
  "role" : "Protocol",
  "symbol" : {
    "kind" : "Protocol",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(pl)PaymentIntentProvider"
  },
  "title" : "PaymentIntentProvider"
}
-->

# PaymentIntentProvider

**Protocol**

A protocol for providing payment intents on-demand during the payment flow.

```
@objc protocol PaymentIntentProvider
```

## Overview

`PaymentIntentProvider` enables delayed payment intent creation, allowing you to defer
the creation of a payment intent until just before payment confirmation or when it is required.

## Overview

When using `Session` with a payment intent provider instead of a pre-created intent,
the SDK will call `createPaymentIntent()` asynchronously when needed. The provider
must also supply the basic payment information (amount, currency, customerId) synchronously.

## Usage Example

```swift
class MyPaymentIntentProvider: NSObject, PaymentIntentProvider {
    let amount: NSDecimalNumber = NSDecimalNumber(string: "99.99")
    let currency: String = "USD"
    let customerId: String? = "customer_123"

    func createPaymentIntent() async throws -> AWXPaymentIntent {
        // Call your backend to create the payment intent
        let response = try await MyBackendAPI.createPaymentIntent(
            amount: amount.decimalValue,
            currency: currency,
            customerId: customerId
        )
        return response.paymentIntent
    }
}

// Use with Session
let provider = MyPaymentIntentProvider()
let session = Session(
    paymentIntentProvider: provider,
    countryCode: "US",
    returnURL: "myapp://payment/return"
)
```

## Important Notes

- The `amount`, `currency` and `customerId` properties must return values immediately (they cannot be async)
- The values returned by `amount`, `currency` and `customerId` must match the values
  in the `AWXPaymentIntent` returned by `createPaymentIntent()`
- The `amount` should be zero for recurring-only payments (no immediate charge)
- The `createPaymentIntent()` method will only be called once, and the result is cached
- If `createPaymentIntent()` throws an error, the payment flow will fail

> SeeAlso: `Session`, `AWXPaymentIntent`

## Instance Properties

[`amount`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentintentprovider/amount.md)

[`currency`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentintentprovider/currency.md)

[`customerId`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentintentprovider/customerid.md)

## Instance Methods

[`createPaymentIntent()`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentintentprovider/createpaymentintent().md)
