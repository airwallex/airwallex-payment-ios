<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXUIContext/launchCardPayment(from:session:paymentResultDelegate:supportedBrands:launchStyle:)",
  "metadataVersion" : "0.1.0",
  "role" : "Type Method",
  "symbol" : {
    "kind" : "Type Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@CM@Airwallex@objc(cs)AWXUIContext(cm)launchCardPaymentFrom:session:paymentResultDelegate:supportedBrands:launchStyle:"
  },
  "title" : "launchCardPayment(from:session:paymentResultDelegate:supportedBrands:launchStyle:)"
}
-->

# launchCardPayment(from:session:paymentResultDelegate:supportedBrands:launchStyle:)

**Type Method**

Launches the Airwallex card payment flow.

```
@MainActor static func launchCardPayment(from hostingVC: UIViewController, session: AWXSession, paymentResultDelegate: AWXPaymentResultDelegate, supportedBrands: [AWXCardBrand] = AWXCardBrand.allAvailable, launchStyle: LaunchStyle = .push)
```

## Parameters

`hostingVC`

The view controller that presents the payment sheet

`session`

The active payment session.

`paymentResultDelegate`

The delegate responsible for handling the payment result.

`supportedBrands`

A list of supported card brands for the payment session.

`launchStyle`

The presentation style of the payment sheet, which defaults to `.push`.
