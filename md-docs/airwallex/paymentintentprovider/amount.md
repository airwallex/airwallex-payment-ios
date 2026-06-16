<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentIntentProvider/amount",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(pl)PaymentIntentProvider(py)amount"
  },
  "title" : "amount"
}
-->

# amount

**Instance Property**

The payment amount as an NSDecimalNumber value.

```
var amount: NSDecimalNumber { get }
```

## Discussion

This value must be available immediately and should match the amount
of the payment intent that will be created by `createPaymentIntent()`.

> Important: Should be zero for recurring-only payments (no immediate charge).
> Must match the amount in the created payment intent.
