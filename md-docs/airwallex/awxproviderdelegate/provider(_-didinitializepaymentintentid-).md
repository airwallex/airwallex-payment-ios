<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXProviderDelegate/provider(_:didInitializePaymentIntentId:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(pl)AWXProviderDelegate(im)provider:didInitializePaymentIntentId:"
  },
  "title" : "provider(_:didInitializePaymentIntentId:)"
}
-->

# provider(_:didInitializePaymentIntentId:)

**Instance Method**

This method is called when it is generated new payment intent.

```
@MainActor func provider(_ provider: AWXDefaultProvider, didInitializePaymentIntentId paymentIntentId: String)
```

## Parameters

`provider`

The provider handling payment.

`paymentIntentId`

The new payment intent id.
