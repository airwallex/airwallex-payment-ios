<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXTheme/tintColor",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(cs)AWXTheme(py)tintColor"
  },
  "title" : "tintColor"
}
-->

# tintColor

**Instance Property**

The primary tint color used for theming.

```
@NSCopying var tintColor: UIColor! { get set }
```

## Discussion

Internally, airwallex sdk resolves the color for the light interface style and uses it as the base tint color.
A corresponding set of colors is automatically generated to support both light and dark interface styles,
ensuring visual consistency across different appearances.
