<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXProviderDelegate/provider(_:shouldHandle:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(pl)AWXProviderDelegate(im)provider:shouldHandleNextAction:"
  },
  "title" : "provider(_:shouldHandle:)"
}
-->

# provider(_:shouldHandle:)

**Instance Method**

This method is called when the next action is required.

```
@MainActor optional func provider(_ provider: AWXDefaultProvider, shouldHandle nextAction: AWXConfirmPaymentNextAction)
```

## Parameters

`provider`

The provider handling payment.

`nextAction`

The next action.
