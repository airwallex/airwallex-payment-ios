<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXUIContext/launchPayment(from:session:filterBy:launchStyle:layout:)",
  "metadataVersion" : "0.1.0",
  "role" : "Type Method",
  "symbol" : {
    "kind" : "Type Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@CM@Airwallex@objc(cs)AWXUIContext(cm)launchPaymentFrom:session:filterBy:launchStyle:layout:"
  },
  "title" : "launchPayment(from:session:filterBy:launchStyle:layout:)"
}
-->

# launchPayment(from:session:filterBy:launchStyle:layout:)

**Type Method**

Launches the Airwallex payment sheet.

```
@MainActor static func launchPayment(from hostingVC: UIViewController & AWXPaymentResultDelegate, session: AWXSession, filterBy methodNames: [String]? = nil, launchStyle: LaunchStyle = .push, layout: PaymentLayout = .tab)
```

## Parameters

`hostingVC`

The view controller that launch the payment sheet and also acts as the `AWXPaymentResultDelegate`.

`session`

The current payment session.

`methodNames`

An optional array of payment method names used to filter the payment methods returned by the server.

`launchStyle`

The presentation style of the payment sheet. Defaults to `.push`.

`layout`

layout of payment sheet
