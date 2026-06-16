<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentElement/create(session:delegate:configuration:)",
  "metadataVersion" : "0.1.0",
  "role" : "Type Method",
  "symbol" : {
    "kind" : "Type Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)AWXPaymentElement(cm)createWithSession:delegate:configuration:completionHandler:"
  },
  "title" : "create(session:delegate:configuration:)"
}
-->

# create(session:delegate:configuration:)

**Type Method**

Creates an embedded payment element.

```
@objc @MainActor static func create(session: AWXSession, delegate: AWXPaymentElementDelegate, configuration: Configuration = Configuration()) async throws -> AWXPaymentElement
```

## Parameters

`session`

The payment session containing transaction details.

`delegate`

The delegate that receives payment lifecycle callbacks.

`configuration`

Configuration options for the payment element.

## Return Value

A configured `AWXPaymentElement` ready to be embedded.

## Discussion

This factory method validates the session, fetches available payment methods,
and creates a fully configured payment element.

> Throws: `AWXUIContext.LaunchError` if session validation fails or payment methods cannot be fetched.
