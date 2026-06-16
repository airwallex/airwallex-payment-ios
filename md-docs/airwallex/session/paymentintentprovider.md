<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/Session/paymentIntentProvider",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)Session(py)paymentIntentProvider"
  },
  "title" : "paymentIntentProvider"
}
-->

# paymentIntentProvider

**Instance Property**

Provider for delayed payment intent creation.
When set, the payment intent will be created just before confirmation.

```
@objc weak var paymentIntentProvider: PaymentIntentProvider? { get }
```
