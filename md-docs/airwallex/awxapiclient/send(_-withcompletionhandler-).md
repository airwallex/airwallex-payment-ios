<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXAPIClient/send(_:withCompletionHandler:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(cs)AWXAPIClient(im)send:withCompletionHandler:"
  },
  "title" : "send(_:withCompletionHandler:)"
}
-->

# send(_:withCompletionHandler:)

**Instance Method**

Send request.

```
func send(_ request: AWXRequest, withCompletionHandler handler: @escaping @Sendable (AWXResponse?, (any Error)?) -> Void)
```

## Parameters

`request`

A request object.

`handler`

A handler which includes response.
