<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/Session/init(paymentIntent:countryCode:applePayOptions:autoCapture:autoSaveCardForFuturePayments:billing:hidePaymentConsents:lang:paymentMethods:paymentConsentOptions:requiredBillingContactFields:returnURL:)",
  "metadataVersion" : "0.1.0",
  "role" : "Initializer",
  "symbol" : {
    "kind" : "Initializer",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)Session(im)initWithPaymentIntent:countryCode:applePayOptions:autoCapture:autoSaveCardForFuturePayments:billing:hidePaymentConsents:lang:paymentMethods:paymentConsentOptions:requiredBillingContactFields:returnURL:"
  },
  "title" : "init(paymentIntent:countryCode:applePayOptions:autoCapture:autoSaveCardForFuturePayments:billing:hidePaymentConsents:lang:paymentMethods:paymentConsentOptions:requiredBillingContactFields:returnURL:)"
}
-->

# init(paymentIntent:countryCode:applePayOptions:autoCapture:autoSaveCardForFuturePayments:billing:hidePaymentConsents:lang:paymentMethods:paymentConsentOptions:requiredBillingContactFields:returnURL:)

**Initializer**

Creates a new unified Session for payment processing.

```
@objc init(paymentIntent: AWXPaymentIntent, countryCode: String, applePayOptions: AWXApplePayOptions? = nil, autoCapture: Bool = true, autoSaveCardForFuturePayments: Bool = true, billing: AWXPlaceDetails? = nil, hidePaymentConsents: Bool = false, lang: String? = nil, paymentMethods: [String]? = nil, paymentConsentOptions: PaymentConsentOptions? = nil, requiredBillingContactFields: RequiredBillingContactFields = .name, returnURL: String? = nil)
```

## Parameters

`paymentIntent`

The payment intent containing transaction details (amount, currency, customer).
Must have a valid amount and currency.

`countryCode`

The ISO 3166-1 alpha-2 country code (e.g., “US”, “AU”, “GB”).
Used for localization and payment method availability.

`applePayOptions`

Configuration for Apple Pay integration. Specify to enable Apple Pay as a payment option.
Default: nil (Apple Pay disabled).

`autoCapture`

Whether to automatically capture the payment after successful authorization.
- true: Payment is captured immediately (funds are transferred)
- false: Payment is only authorized (requires manual capture later)
Default: true.

`autoSaveCardForFuturePayments`

Whether to automatically save card details for future payments.
Only applies when customer is logged in. Default: true.

`billing`

Pre-filled billing address information. If provided, billing form fields will be pre-populated.
Default: nil (user must enter billing information).

`hidePaymentConsents`

Whether to hide previously saved payment methods in the payment sheet.
For now, we only display payment consent for cards.
- true: Only show new payment method entry
- false: Show saved payment methods (if available)
Default: false.

`lang`

Language code for UI localization (e.g., “en”, “zh-Hans”, “ja”).
If nil, uses the system’s current language. Default: system language.

`paymentMethods`

Array of payment method identifiers to limit which methods are displayed.
Useful for restricting to specific payment types (e.g., [“card”, “wechatpay”]).
If nil, all available methods for the region are shown. Default: nil.

`paymentConsentOptions`

Configuration for recurring payments including terms of use, billing schedules, and consent parameters.
- When provided: Creates a recurring payment session
- When nil: Creates a one-off payment session
Default: nil.

`requiredBillingContactFields`

Specifies which billing contact fields are mandatory.
Can be combined using OptionSet syntax (e.g., [.name, .address]).
Default: .name.

`returnURL`

The URL to redirect users after payment completion or cancellation when user
choose a redirect payment, for example: wechatpay.
Should be a valid URL that your app can handle (e.g., “yourapp://payment/return”).

## Discussion

This initializer supports both one-off and recurring payment scenarios through a single API.
The session type is automatically determined by the presence of `paymentConsentOptions`:

- **One-off payments**: When `paymentConsentOptions` is nil
- **Recurring payments**: When `paymentConsentOptions` is provided
