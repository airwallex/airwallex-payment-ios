<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentIntentProvider/createPaymentIntent()",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(pl)PaymentIntentProvider(im)createPaymentIntentWithCompletionHandler:"
  },
  "title" : "createPaymentIntent()"
}
-->

# createPaymentIntent()

**Instance Method**

Creates a payment intent asynchronously.

```
func createPaymentIntent() async throws -> AWXPaymentIntent
```

## Return Value

A fully initialized `AWXPaymentIntent` object

## Discussion

This method is called by the SDK when the payment intent is needed, typically just
before payment confirmation. Implement this method to call your backend API and
create a payment intent with the Airwallex API.

## Important

The returned payment intent must have:

- `amount` matching the `amount` property
- `currency` matching the `currency` property
- `customerId` matching the `customerId` property (if not nil)

If these values don’t match, the SDK will throw a validation error.

> Throws: Any error that occurs during payment intent creation (e.g., network errors,
> API errors). The error will be propagated to the payment flow.
