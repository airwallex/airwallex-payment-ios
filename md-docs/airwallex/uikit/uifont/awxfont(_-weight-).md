<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/UIKit/UIFont/awxFont(_:weight:)",
  "metadataVersion" : "0.1.0",
  "role" : "Type Method",
  "symbol" : {
    "kind" : "Type Method",
    "modules" : [
      "Airwallex",
      "UIKit"
    ],
    "preciseIdentifier" : "s:So6UIFontC9AirwallexE7awxFont_6weightA2bCE7AWXFontO_So0A6WeightatFZ"
  },
  "title" : "awxFont(_:weight:)"
}
-->

# awxFont(_:weight:)

**Type Method**

return UIFont by semantic and weight

```
static func awxFont(_ font: AWXFont, weight: UIFont.Weight = .regular) -> UIFont
```

## Parameters

`font`

Defined by UI

`weight`

weight of font
UltraLight: [100] (approximation)
Thin: [200] (approximation)
Light: [300]
Regular: [400]
Medium: [500]
Semibold: [600]
Bold: [700]
Heavy/Black: [800] (both can map to higher numeric values)

## Return Value

UIFont
