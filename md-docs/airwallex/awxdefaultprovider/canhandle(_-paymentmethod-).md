<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXDefaultProvider/canHandle(_:paymentMethod:)",
  "metadataVersion" : "0.1.0",
  "role" : "Type Method",
  "symbol" : {
    "kind" : "Type Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(cs)AWXDefaultProvider(cm)canHandleSession:paymentMethod:"
  },
  "title" : "canHandle(_:paymentMethod:)"
}
-->

# canHandle(_:paymentMethod:)

**Type Method**

Indicating whether the provider can handle a particular session. Default implementation returns YES. Subclasses can override to
do additional checks.

```
class func canHandle(_ session: AWXSession, paymentMethod: AWXPaymentMethodType) -> Bool
```
