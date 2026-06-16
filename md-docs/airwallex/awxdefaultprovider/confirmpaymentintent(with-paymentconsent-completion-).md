<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXDefaultProvider/confirmPaymentIntent(with:paymentConsent:completion:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(cs)AWXDefaultProvider(im)confirmPaymentIntentWithPaymentMethod:paymentConsent:completion:"
  },
  "title" : "confirmPaymentIntent(with:paymentConsent:completion:)"
}
-->

# confirmPaymentIntent(with:paymentConsent:completion:)

**Instance Method**

Confirm the payment intent with payment method and consent as well as a custom completion block.

```
func confirmPaymentIntent(with paymentMethod: AWXPaymentMethod, paymentConsent: AWXPaymentConsent?, completion: @escaping @Sendable (AWXResponse?, (any Error)?) -> Void)
```

## Parameters

`paymentMethod`

The payment method info.

`paymentConsent`

The payment consent info.

`completion`

The completion block to be called with the response and error.
