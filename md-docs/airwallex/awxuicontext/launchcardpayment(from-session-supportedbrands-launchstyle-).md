<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXUIContext/launchCardPayment(from:session:supportedBrands:launchStyle:)",
  "metadataVersion" : "0.1.0",
  "role" : "Type Method",
  "symbol" : {
    "kind" : "Type Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@CM@Airwallex@objc(cs)AWXUIContext(cm)launchCardPaymentFrom:session:supportedBrands:launchStyle:"
  },
  "title" : "launchCardPayment(from:session:supportedBrands:launchStyle:)"
}
-->

# launchCardPayment(from:session:supportedBrands:launchStyle:)

**Type Method**

Launches the Airwallex card payment flow.

```
@MainActor static func launchCardPayment(from hostingVC: UIViewController & AWXPaymentResultDelegate, session: AWXSession, supportedBrands: [AWXCardBrand] = AWXCardBrand.allAvailable, launchStyle: LaunchStyle = .push)
```

## Parameters

`hostingVC`

The view controller that presents the payment sheet and acts as the `AWXPaymentResultDelegate`.

`session`

The active payment session.

`supportedBrands`

A list of supported card brands for the payment session.

`launchStyle`

The presentation style of the payment sheet, which defaults to `.push`.
