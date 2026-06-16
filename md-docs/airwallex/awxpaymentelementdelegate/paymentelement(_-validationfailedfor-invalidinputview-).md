<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentElementDelegate/paymentElement(_:validationFailedFor:invalidInputView:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(pl)AWXPaymentElementDelegate(im)paymentElement:validationFailedFor:invalidInputView:"
  },
  "title" : "paymentElement(_:validationFailedFor:invalidInputView:)"
}
-->

# paymentElement(_:validationFailedFor:invalidInputView:)

**Instance Method**

Called when input validation fails, allowing the host app to scroll the first
invalid field into the visible area.

```
@objc @MainActor optional func paymentElement(_ element: AWXPaymentElement, validationFailedFor paymentMethod: String, invalidInputView: UIView)
```

## Parameters

`element`

The payment element.

`paymentMethod`

The name of the payment method being validated (e.g., “card”).

`invalidInputView`

The view containing the first invalid input field that should be scrolled into view.

## Discussion

Since the payment element is embedded inside the host app’s view hierarchy,
the SDK cannot determine how to scroll content into view. Implement this method
to ensure the provided view is visible to the user (e.g., by calling
`scrollRectToVisible(_:animated:)` on the enclosing scroll view, converting
the view’s frame with `convert(_:from:)` as needed).
