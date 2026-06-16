<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXUIContext/launchPayment(from:session:paymentResultDelegate:configuration:)",
  "metadataVersion" : "0.1.0",
  "role" : "Type Method",
  "symbol" : {
    "kind" : "Type Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@CM@Airwallex@objc(cs)AWXUIContext(cm)launchPaymentFrom:session:paymentResultDelegate:configuration:"
  },
  "title" : "launchPayment(from:session:paymentResultDelegate:configuration:)"
}
-->

# launchPayment(from:session:paymentResultDelegate:configuration:)

**Type Method**

Launches the Airwallex payment UI using a configuration object.

```
@MainActor static func launchPayment(from hostingVC: UIViewController, session: AWXSession, paymentResultDelegate: AWXPaymentResultDelegate, configuration: Configuration)
```

## Parameters

`hostingVC`

The view controller that launches the payment UI.

`session`

The current payment session.

`paymentResultDelegate`

The delegate responsible for handling the payment result.

`configuration`

Configuration for the payment flow.
