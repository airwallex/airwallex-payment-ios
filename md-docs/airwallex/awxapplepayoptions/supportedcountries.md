<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXApplePayOptions/supportedCountries",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(cs)AWXApplePayOptions(py)supportedCountries"
  },
  "title" : "supportedCountries"
}
-->

# supportedCountries

**Instance Property**

A list of ISO 3166 country codes for limiting payments to cards from specific countries. Default value is null, meaning all countries are allowed.

```
var supportedCountries: Set<String>? { get set }
```
