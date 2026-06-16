<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentElementDelegate/paymentElement(_:onProcessingStateChangedFor:isProcessing:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(pl)AWXPaymentElementDelegate(im)paymentElement:onProcessingStateChangedFor:isProcessing:"
  },
  "title" : "paymentElement(_:onProcessingStateChangedFor:isProcessing:)"
}
-->

# paymentElement(_:onProcessingStateChangedFor:isProcessing:)

**Instance Method**

Called when payment processing state changes.

```
@objc @MainActor optional func paymentElement(_ element: AWXPaymentElement, onProcessingStateChangedFor paymentMethod: String, isProcessing: Bool)
```

## Parameters

`element`

The payment element.

`paymentMethod`

The name of the payment method being used (e.g., “card”, “applepay”).

`isProcessing`

`true` when payment starts, `false` when payment ends.

## Discussion

Implement this method to display a custom loading indicator during payment processing.
This method is called with `isProcessing: true` when payment starts, and
`isProcessing: false` when payment completes (before `didCompleteFor` is called).
If this method is not implemented, a default loading indicator will be shown.
