<!--
{
  "availability" : [
    "iOS: 2.0.0 -",
    "iPadOS: 2.0.0 -",
    "macCatalyst: 2.0.0 -"
  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentResultDelegate/paymentViewController(_:didCompleteWithPaymentConsentId:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(pl)AWXPaymentResultDelegate(im)paymentViewController:didCompleteWithPaymentConsentId:"
  },
  "title" : "paymentViewController(_:didCompleteWithPaymentConsentId:)"
}
-->

# paymentViewController(_:didCompleteWithPaymentConsentId:)

**Instance Method** · iOS 2.0.0+, iPadOS 2.0.0+, macCatalyst 2.0.0+

This method is called when the user has completed the checkout and payment consent id is produced.

```
optional func paymentViewController(_ controller: UIViewController?, didCompleteWithPaymentConsentId paymentConsentId: String)
```

## Parameters

`controller`

The controller handling payment result. Could be nil for low level API integration.

`paymentConsentId`

The id of payment consent.
