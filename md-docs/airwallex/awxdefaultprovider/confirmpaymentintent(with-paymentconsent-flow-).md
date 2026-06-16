<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXDefaultProvider/confirmPaymentIntent(with:paymentConsent:flow:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(cs)AWXDefaultProvider(im)confirmPaymentIntentWithPaymentMethod:paymentConsent:flow:"
  },
  "title" : "confirmPaymentIntent(with:paymentConsent:flow:)"
}
-->

# confirmPaymentIntent(with:paymentConsent:flow:)

**Instance Method**

Confirm the payment intent with payment method and consent.

```
func confirmPaymentIntent(with paymentMethod: AWXPaymentMethod, paymentConsent: AWXPaymentConsent?, flow: AWXPaymentMethodFlow)
```

## Parameters

`paymentMethod`

The payment method info.

`paymentConsent`

The payment consent info.

`flow`

The payment method flow.
