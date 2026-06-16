<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentElement/Configuration/CheckoutButton-swift.class/title",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "s:9Airwallex17AWXPaymentElementC13ConfigurationC14CheckoutButtonC5titleSSSgvp"
  },
  "title" : "title"
}
-->

# title

**Instance Property**

Custom title for the checkout button.
When `nil` (default), the SDK automatically selects based on session type:
“Pay” for one-off payments, “Confirm” for recurring.

```
var title: String?
```
