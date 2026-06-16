<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentElement/Configuration/ApplePayButton-swift.class/buttonType",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "s:9Airwallex17AWXPaymentElementC13ConfigurationC14ApplePayButtonC10buttonTypeSo09PKPaymentgI0VSgvp"
  },
  "title" : "buttonType"
}
-->

# buttonType

**Instance Property**

Custom button type for the Apple Pay button.
When `nil` (default), the SDK automatically selects based on session type:
`.plain` for one-off payments, `.subscribe` for recurring.

```
@nonobjc var buttonType: PKPaymentButtonType?
```
