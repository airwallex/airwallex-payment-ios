<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentIntentProvider/currency",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(pl)PaymentIntentProvider(py)currency"
  },
  "title" : "currency"
}
-->

# currency

**Instance Property**

The three-letter ISO currency code (e.g., “USD”, “AUD”, “GBP”).

```
var currency: String { get }
```

## Discussion

This value must be available immediately and should match the currency
of the payment intent that will be created by `createPaymentIntent()`.

> Important: Must be a valid ISO 4217 currency code.
