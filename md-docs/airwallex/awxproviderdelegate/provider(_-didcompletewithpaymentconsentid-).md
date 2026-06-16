<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXProviderDelegate/provider(_:didCompleteWithPaymentConsentId:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(pl)AWXProviderDelegate(im)provider:didCompleteWithPaymentConsentId:"
  },
  "title" : "provider(_:didCompleteWithPaymentConsentId:)"
}
-->

# provider(_:didCompleteWithPaymentConsentId:)

**Instance Method**

This method is called when payment is completed and payment consent id is produced.

```
@MainActor optional func provider(_ provider: AWXDefaultProvider, didCompleteWithPaymentConsentId paymentConsentId: String)
```

## Parameters

`provider`

The provider handling payment.

`paymentConsentId`

The id of payment consent.
