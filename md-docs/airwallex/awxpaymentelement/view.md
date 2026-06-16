<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentElement/view",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)AWXPaymentElement(py)view"
  },
  "title" : "view"
}
-->

# view

**Instance Property**

The embeddable view containing the payment UI.

```
@objc @MainActor var view: UIView { get }
```

## Discussion

Add this view to your view hierarchy using Auto Layout constraints.
The view’s height will update automatically based on its content.
