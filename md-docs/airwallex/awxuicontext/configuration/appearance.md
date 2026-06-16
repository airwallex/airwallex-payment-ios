<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXUIContext/Configuration/appearance",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "s:9Airwallex12AWXUIContextC13ConfigurationC10appearanceAA17AWXPaymentElementCADC10AppearanceCvp"
  },
  "title" : "appearance"
}
-->

# appearance

**Instance Property**

Appearance configuration for customizing the visual style.

```
var appearance: AWXPaymentElement.Configuration.Appearance
```

## Discussion

Use this to customize the tint color used throughout the payment UI.
When launched with a configuration, `appearance.tintColor` overrides `AWXTheme.shared().tintColor`.
