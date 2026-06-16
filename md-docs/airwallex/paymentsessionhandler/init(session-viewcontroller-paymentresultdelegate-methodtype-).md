<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentSessionHandler/init(session:viewController:paymentResultDelegate:methodType:)",
  "metadataVersion" : "0.1.0",
  "role" : "Initializer",
  "symbol" : {
    "kind" : "Initializer",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)PaymentSessionHandler(im)initWithSession:viewController:paymentResultDelegate:methodType:"
  },
  "title" : "init(session:viewController:paymentResultDelegate:methodType:)"
}
-->

# init(session:viewController:paymentResultDelegate:methodType:)

**Initializer**

Initializes a `PaymentSessionHandler` with a payment session and an optional view controller from which the payment is initiated.

```
@objc @MainActor convenience init(session: AWXSession, viewController: UIViewController? = nil, paymentResultDelegate: AWXPaymentResultDelegate?, methodType: AWXPaymentMethodType? = nil)
```

## Parameters

`session`

The payment session containing relevant transaction details.

`viewController`

The view controller that initiates the payment process. If `nil`, the topmost visible view controller will be used automatically.

`paymentResultDelegate`

delegate which conforms to `AWXPaymentResultDelegate` for handling payment results

`methodType`

The payment method type returned from the server (optional).
