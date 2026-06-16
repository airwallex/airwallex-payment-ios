<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentElement/Configuration/layout",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "s:9Airwallex17AWXPaymentElementC13ConfigurationC6layoutAA12AWXUIContextC13PaymentLayoutOvp"
  },
  "title" : "layout"
}
-->

# layout

**Instance Property**

The layout style for payment sections.

```
var layout: AWXUIContext.PaymentLayout { get set }
```

## Discussion

Only applies when `elementType` is `.paymentSheet`.

- `.tab`: Displays payment methods in a horizontal tab bar (default)
- `.accordion`: Displays payment methods in an expandable accordion layout
