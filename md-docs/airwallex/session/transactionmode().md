<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/Session/transactionMode()",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)Session(im)transactionMode"
  },
  "title" : "transactionMode()"
}
-->

# transactionMode()

**Instance Method**

Determines the transaction mode based on the presence of recurring options.

```
override func transactionMode() -> String
```

## Return Value

“recurring” for recurring payments, “oneoff” for one-time payments.
