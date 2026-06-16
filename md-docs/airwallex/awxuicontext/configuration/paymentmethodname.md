<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXUIContext/Configuration/paymentMethodName",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "s:9Airwallex12AWXUIContextC13ConfigurationC17paymentMethodNameSSSgvp"
  },
  "title" : "paymentMethodName"
}
-->

# paymentMethodName

**Instance Property**

The payment method name to display when elementType is .component.
Required for .component; ignored for .paymentSheet.
If elementType is .component and this is nil, falls back to .paymentSheet.

```
var paymentMethodName: String?
```
