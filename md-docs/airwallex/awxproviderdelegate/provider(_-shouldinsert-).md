<!--
{
  "availability" : [
    "iOS: 2.0.0 -",
    "iPadOS: 2.0.0 -",
    "macCatalyst: 2.0.0 -"
  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXProviderDelegate/provider(_:shouldInsert:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(pl)AWXProviderDelegate(im)provider:shouldInsertViewController:"
  },
  "title" : "provider(_:shouldInsert:)"
}
-->

# provider(_:shouldInsert:)

**Instance Method** · iOS 2.0.0+, iPadOS 2.0.0+, macCatalyst 2.0.0+

This method is called when new controller is required. (as child view controller)

```
@MainActor optional func provider(_ provider: AWXDefaultProvider, shouldInsert controller: UIViewController)
```

## Parameters

`provider`

The provider handling payment.

`controller`

The view controller will be presented.
