<!--
{
  "availability" : [
    "iOS: 2.0.0 -",
    "iPadOS: 2.0.0 -",
    "macCatalyst: 2.0.0 -"
  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXProviderDelegate/provider(_:shouldPresent:forceToDismiss:withAnimation:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(pl)AWXProviderDelegate(im)provider:shouldPresentViewController:forceToDismiss:withAnimation:"
  },
  "title" : "provider(_:shouldPresent:forceToDismiss:withAnimation:)"
}
-->

# provider(_:shouldPresent:forceToDismiss:withAnimation:)

**Instance Method** · iOS 2.0.0+, iPadOS 2.0.0+, macCatalyst 2.0.0+

This method is called when new controller is required.

```
@MainActor optional func provider(_ provider: AWXDefaultProvider, shouldPresent controller: UIViewController?, forceToDismiss: Bool, withAnimation: Bool)
```

## Parameters

`provider`

The provider handling payment.

`controller`

The view controller will be presented.

`forceToDismiss`

Whether the presenting view controller needs be dismissed forcibly.
