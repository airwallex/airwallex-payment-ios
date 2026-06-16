<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentElementDelegate/paymentElement(_:didCompleteFor:with:error:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(pl)AWXPaymentElementDelegate(im)paymentElement:didCompleteFor:with:error:"
  },
  "title" : "paymentElement(_:didCompleteFor:with:error:)"
}
-->

# paymentElement(_:didCompleteFor:with:error:)

**Instance Method**

Called when payment processing completes.

```
@MainActor func paymentElement(_ element: AWXPaymentElement, didCompleteFor paymentMethod: String, with status: AirwallexPaymentStatus, error: Error?)
```

## Parameters

`element`

The payment element that completed payment.

`paymentMethod`

The name of the payment method used.

`status`

The result status of the payment.

`error`

The error if payment failed, nil otherwise.
