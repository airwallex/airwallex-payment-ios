<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentSessionHandler/init(session:viewController:methodType:)",
  "metadataVersion" : "0.1.0",
  "role" : "Initializer",
  "symbol" : {
    "kind" : "Initializer",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)PaymentSessionHandler(im)initWithSession:viewController:methodType:"
  },
  "title" : "init(session:viewController:methodType:)"
}
-->

# init(session:viewController:methodType:)

**Initializer**

Initializes a `PaymentSessionHandler` with a payment session and a view controller that also acts as a payment result delegate.

```
@objc @MainActor convenience init(session: AWXSession, viewController: UIViewController & AWXPaymentResultDelegate, methodType: AWXPaymentMethodType? = nil)
```

## Parameters

`session`

The payment session containing relevant transaction details.

`viewController`

The view controller initiating the payment, which conforms to `AWXPaymentResultDelegate` for handling payment results.

`methodType`

The payment method type returned from the server (optional).
