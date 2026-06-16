<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentSessionHandler/startConsentPayment(withId:requiresCVC:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@CM@Airwallex@objc(cs)PaymentSessionHandler(im)startConsentPaymentWithId:requiresCVC:"
  },
  "title" : "startConsentPayment(withId:requiresCVC:)"
}
-->

# startConsentPayment(withId:requiresCVC:)

**Instance Method**

Initiates a consent-based subsequent one-off payment using a consent identifier with optional CVC requirement.

```
@MainActor func startConsentPayment(withId consentId: String, requiresCVC: Bool = false)
```

## Parameters

`consentId`

The unique identifier of the previously created payment consent.

`requiresCVC`

Whether to prompt the user for CVC input. Defaults to `false`.
Set to `true` for PAN-type consents that require CVC validation.

## Discussion

Use this method when you have stored the consent ID and want to control whether CVC input is required.

**CVC Requirement Guidelines:**

- Set `requiresCVC` to `true` when the consent’s `numberType` is “PAN” for enhanced security
- Set `requiresCVC` to `false` for tokenized payment methods that don’t require CVC re-entry
