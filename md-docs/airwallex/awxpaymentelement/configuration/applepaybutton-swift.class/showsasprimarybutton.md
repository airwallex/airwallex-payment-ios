<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentElement/Configuration/ApplePayButton-swift.class/showsAsPrimaryButton",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "s:9Airwallex17AWXPaymentElementC13ConfigurationC14ApplePayButtonC014showsAsPrimaryG0Sbvp"
  },
  "title" : "showsAsPrimaryButton"
}
-->

# showsAsPrimaryButton

**Instance Property**

Whether to prioritize Apple Pay by showing it prominently at the top.

```
var showsAsPrimaryButton: Bool
```

## Discussion

When `true` (default), Apple Pay is displayed as a separate button at the top.
When `false`, Apple Pay is grouped with other payment methods:

- In tab layout: shown in the horizontal method tab
- In accordion layout: shown as an accordion key
