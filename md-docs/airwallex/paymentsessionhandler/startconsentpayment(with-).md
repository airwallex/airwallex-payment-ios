<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentSessionHandler/startConsentPayment(with:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@CM@Airwallex@objc(cs)PaymentSessionHandler(im)startConsentPaymentWith:"
  },
  "title" : "startConsentPayment(with:)"
}
-->

# startConsentPayment(with:)

**Instance Method**

Initiates a consent-based payment using a previously obtained payment consent object.

```
@MainActor func startConsentPayment(with consent: AWXPaymentConsent)
```

## Parameters

`consent`

The payment consent object retrieved from the server that authorizes this transaction.
This consent must be valid and not expired.

## Discussion

This method processes payments with different behaviors based on the session type and consent configuration:

- **Recurring sessions**: Creates a new consent and confirms payment using the existing payment method
- **One-off sessions with MIT consent**: Creates a new CIT consent and confirms the payment intent
- **One-off sessions with CIT consent**: Processes as a standard subsequent one-off transaction

**Important**: Consents with `numberType` “PAN” may require additional user input (such as CVC) for security validation.
The SDK will automatically prompt for required information when necessary.
