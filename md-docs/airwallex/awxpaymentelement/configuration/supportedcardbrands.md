<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentElement/Configuration/supportedCardBrands",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "s:9Airwallex17AWXPaymentElementC13ConfigurationC19supportedCardBrandsSaySo12AWXCardBrandaGvp"
  },
  "title" : "supportedCardBrands"
}
-->

# supportedCardBrands

**Instance Property**

Supported card brands for card payment.

```
var supportedCardBrands: [AWXCardBrand]
```

## Discussion

Only applies when `elementType` is `.addCard`.
Defaults to all available card brands.
