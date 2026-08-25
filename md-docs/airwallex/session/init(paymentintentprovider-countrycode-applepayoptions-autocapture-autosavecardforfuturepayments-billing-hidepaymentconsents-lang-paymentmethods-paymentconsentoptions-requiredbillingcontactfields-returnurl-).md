<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/Session/init(paymentIntentProvider:countryCode:applePayOptions:autoCapture:autoSaveCardForFuturePayments:billing:hidePaymentConsents:lang:paymentMethods:paymentConsentOptions:requiredBillingContactFields:returnURL:)",
  "metadataVersion" : "0.1.0",
  "role" : "Initializer",
  "symbol" : {
    "kind" : "Initializer",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)Session(im)initWithPaymentIntentProvider:countryCode:applePayOptions:autoCapture:autoSaveCardForFuturePayments:billing:hidePaymentConsents:lang:paymentMethods:paymentConsentOptions:requiredBillingContactFields:returnURL:"
  },
  "title" : "init(paymentIntentProvider:countryCode:applePayOptions:autoCapture:autoSaveCardForFuturePayments:billing:hidePaymentConsents:lang:paymentMethods:paymentConsentOptions:requiredBillingContactFields:returnURL:)"
}
-->

# init(paymentIntentProvider:countryCode:applePayOptions:autoCapture:autoSaveCardForFuturePayments:billing:hidePaymentConsents:lang:paymentMethods:paymentConsentOptions:requiredBillingContactFields:returnURL:)

**Initializer**

Creates a new unified Session with delayed payment intent creation.

```
@objc init(paymentIntentProvider: PaymentIntentProvider, countryCode: String, applePayOptions: AWXApplePayOptions? = nil, autoCapture: Bool = true, autoSaveCardForFuturePayments: Bool = true, billing: AWXPlaceDetails? = nil, hidePaymentConsents: Bool = false, lang: String? = nil, paymentMethods: [String]? = nil, paymentConsentOptions: PaymentConsentOptions? = nil, requiredBillingContactFields: RequiredBillingContactFields = .name, returnURL: String? = nil)
```

## Parameters

`paymentIntentProvider`

An object conforming to `PaymentIntentProvider` protocol that will create
the payment intent when needed. The provider must supply currency,
and customerId properties immediately, and create the actual intent asynchronously.

`countryCode`

The ISO 3166-1 alpha-2 country code (e.g., “US”, “AU”, “GB”).

`applePayOptions`

Configuration for Apple Pay integration. Default: nil.

`autoCapture`

Whether to automatically capture the payment after successful authorization. Default: true.

`autoSaveCardForFuturePayments`

Whether to automatically save card details for future payments. Default: true.

`billing`

Pre-filled billing address information. Default: nil.

`hidePaymentConsents`

Whether to hide previously saved payment methods. Default: false.

`lang`

Preferred BCP-47 language identifier for SDK UI.

`paymentMethods`

Array of payment method identifiers to limit display. Default: nil.

`paymentConsentOptions`

Configuration for recurring payments. Default: nil.

`requiredBillingContactFields`

Which billing contact fields are mandatory. Default: .name.

`returnURL`

The URL to redirect users after payment completion for redirect payments.

## Discussion

This initializer allows you to defer the creation of the payment intent until just before
payment confirmation or when it is required.
