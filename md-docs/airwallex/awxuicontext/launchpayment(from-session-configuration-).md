<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXUIContext/launchPayment(from:session:configuration:)",
  "metadataVersion" : "0.1.0",
  "role" : "Type Method",
  "symbol" : {
    "kind" : "Type Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@CM@Airwallex@objc(cs)AWXUIContext(cm)launchPaymentFrom:session:configuration:"
  },
  "title" : "launchPayment(from:session:configuration:)"
}
-->

# launchPayment(from:session:configuration:)

**Type Method**

Launches the Airwallex payment UI using a configuration object.

```
@MainActor static func launchPayment(from hostingVC: UIViewController & AWXPaymentResultDelegate, session: AWXSession, configuration: Configuration)
```

## Parameters

`hostingVC`

The view controller that launches the payment UI and also acts as the `AWXPaymentResultDelegate`.

`session`

The current payment session.

`configuration`

Configuration for the payment flow.
