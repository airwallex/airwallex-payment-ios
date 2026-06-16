<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentIntentProvider/customerId",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(pl)PaymentIntentProvider(py)customerId"
  },
  "title" : "customerId"
}
-->

# customerId

**Instance Property**

The customer ID associated with this payment, if available.

```
var customerId: String? { get }
```

## Discussion

This value must be available immediately. If not nil, it should match the
customer ID of the payment intent that will be created by `createPaymentIntent()`.

> Important: Required for recurring payments and saved payment methods.
