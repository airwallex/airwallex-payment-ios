<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentConsentOptions/init(nextTriggeredBy:merchantTriggerReason:termsOfUse:)",
  "metadataVersion" : "0.1.0",
  "role" : "Initializer",
  "symbol" : {
    "kind" : "Initializer",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)PaymentConsentOptions(im)initWithNextTriggeredBy:merchantTriggerReason:termsOfUse:"
  },
  "title" : "init(nextTriggeredBy:merchantTriggerReason:termsOfUse:)"
}
-->

# init(nextTriggeredBy:merchantTriggerReason:termsOfUse:)

**Initializer**

Creates a new payment consent options instance for recurring payments.

```
@objc init(nextTriggeredBy: AirwallexNextTriggerByType, merchantTriggerReason: AirwallexMerchantTriggerReason = .undefined, termsOfUse: TermsOfUse? = nil)
```

## Parameters

`nextTriggeredBy`

Specifies which party will trigger subsequent payments.
Use `.merchantType` when merchant initiates future payments,
or `.customerType` when customer initiates future payments.

`merchantTriggerReason`

Indicates whether subsequent payments are scheduled.
Only applicable when nextTriggeredBy is `.merchantType`.
Default value is `.undefined`.

`termsOfUse`

Terms to specify how this Payment Consent will be used.
