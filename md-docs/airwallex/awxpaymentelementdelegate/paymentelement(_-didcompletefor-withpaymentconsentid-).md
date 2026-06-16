<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentElementDelegate/paymentElement(_:didCompleteFor:withPaymentConsentId:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(pl)AWXPaymentElementDelegate(im)paymentElement:didCompleteFor:withPaymentConsentId:"
  },
  "title" : "paymentElement(_:didCompleteFor:withPaymentConsentId:)"
}
-->

# paymentElement(_:didCompleteFor:withPaymentConsentId:)

**Instance Method**

Called when a payment consent is created.

```
@objc @MainActor optional func paymentElement(_ element: AWXPaymentElement, didCompleteFor paymentMethod: String, withPaymentConsentId paymentConsentId: String)
```

## Parameters

`element`

The payment element.

`paymentMethod`

The name of the payment method used.

`paymentConsentId`

The ID of the created payment consent.
