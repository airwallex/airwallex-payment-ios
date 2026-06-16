<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXUIContext/launchPayment(name:from:session:paymentResultDelegate:supportedBrands:launchStyle:)",
  "metadataVersion" : "0.1.0",
  "role" : "Type Method",
  "symbol" : {
    "kind" : "Type Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@CM@Airwallex@objc(cs)AWXUIContext(cm)launchPaymentWithName:from:session:paymentResultDelegate:supportedBrands:launchStyle:"
  },
  "title" : "launchPayment(name:from:session:paymentResultDelegate:supportedBrands:launchStyle:)"
}
-->

# launchPayment(name:from:session:paymentResultDelegate:supportedBrands:launchStyle:)

**Type Method**

Launches the Airwallex payment sheet for a specified payment method.

```
@MainActor static func launchPayment(name: String, from hostingVC: UIViewController, session: AWXSession, paymentResultDelegate: AWXPaymentResultDelegate, supportedBrands: [AWXCardBrand]? = AWXCardBrand.allAvailable, launchStyle: LaunchStyle = .push)
```

## Parameters

`name`

The name of the payment method.
API reference: https://www.airwallex.com/docs/api#/Payment_Acceptance/Config/_api_v1_pa_config_payment_method_types/get JSON Object field: items.name

`hostingVC`

The view controller that presents the payment sheet.

`session`

The current payment session containing transaction details.

`paymentResultDelegate`

The delegate that handles payment result callbacks.

`supportedBrands`

A list of supported card brands for the payment method. Required for Card Payment

`launchStyle`

The presentation style of the payment sheet. Defaults to `.push`.
