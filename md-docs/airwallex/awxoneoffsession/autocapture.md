<!--
{
  "availability" : [
    "*: -"
  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXOneOffSession/autoCapture",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(cs)AWXOneOffSession(py)autoCapture"
  },
  "title" : "autoCapture"
}
-->

# autoCapture

**Instance Property** · *

Only applicable when payment_method.type is card. If true the payment will be captured immediately after authorization succeeds.
Default: YES

## Deprecated

Will be removed in next major version release, use AirwallexPayment.Session instead

```
var autoCapture: Bool { get set }
```
