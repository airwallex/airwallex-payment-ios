<!--
{
  "availability" : [
    "iOS: 2.0.0 -",
    "iPadOS: 2.0.0 -",
    "macCatalyst: 2.0.0 -"
  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentResultDelegate/paymentViewController(_:didCompleteWith:error:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(pl)AWXPaymentResultDelegate(im)paymentViewController:didCompleteWithStatus:error:"
  },
  "title" : "paymentViewController(_:didCompleteWith:error:)"
}
-->

# paymentViewController(_:didCompleteWith:error:)

**Instance Method** · iOS 2.0.0+, iPadOS 2.0.0+, macCatalyst 2.0.0+

This method is called when the user has completed the checkout.

```
func paymentViewController(_ controller: UIViewController?, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?)
```

## Parameters

`controller`

The controller handling payment result. Could be nil for low level API integration or when user dismiss the payment view controller.

`status`

The status of checkout result.

`error`

The error if checkout failed.
