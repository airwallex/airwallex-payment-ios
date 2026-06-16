<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentSessionHandler/startConsentPayment(withId:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@CM@Airwallex@objc(cs)PaymentSessionHandler(im)startConsentPaymentWithId:"
  },
  "title" : "startConsentPayment(withId:)"
}
-->

# startConsentPayment(withId:)

**Instance Method**

Initiates a consent-based  subsequent one-off payment using a consent identifier without CVC requirement.

```
@MainActor func startConsentPayment(withId consentId: String)
```

## Parameters

`consentId`

The unique identifier of the previously created payment consent.

## Discussion

This is a convenience method that calls `startConsentPayment(withId:requiresCVC:)` with `requiresCVC` set to `false`.
Use this method when you’re confident that the consent doesn’t require CVC input, typically for tokenized payment methods.

**Note**: If the consent actually requires CVC (e.g., PAN-type consents), the payment may fail.
Consider using `startConsentPayment(withId:requiresCVC:)` with `requiresCVC: true` for such cases.
