<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXProviderDelegate/provider(_:didCompleteWith:error:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(pl)AWXProviderDelegate(im)provider:didCompleteWithStatus:error:"
  },
  "title" : "provider(_:didCompleteWith:error:)"
}
-->

# provider(_:didCompleteWith:error:)

**Instance Method**

This method is called when payment is completed.

```
@MainActor func provider(_ provider: AWXDefaultProvider, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?)
```

## Parameters

`provider`

The provider handling payment.

`status`

The status of payment.

`error`

The error of payment.
