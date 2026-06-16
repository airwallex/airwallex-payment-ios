<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXDefaultProvider/createPaymentConsentAndConfirmIntent(with:completion:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(cs)AWXDefaultProvider(im)createPaymentConsentAndConfirmIntentWithPaymentMethod:completion:"
  },
  "title" : "createPaymentConsentAndConfirmIntent(with:completion:)"
}
-->

# createPaymentConsentAndConfirmIntent(with:completion:)

**Instance Method**

Create a new payment consent and confirm the payment intent with payment method as well as a custom completion block.

```
func createPaymentConsentAndConfirmIntent(with paymentMethod: AWXPaymentMethod, completion: @escaping @Sendable (AWXResponse?, (any Error)?) -> Void)
```

## Parameters

`paymentMethod`

The payment method info.

`completion`

The completion block to be called with the response and error.
