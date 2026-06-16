<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentSessionHandler/startRedirectPayment(with:additionalInfo:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@CM@Airwallex@objc(cs)PaymentSessionHandler(im)startRedirectPaymentWith:additionalInfo:"
  },
  "title" : "startRedirectPayment(with:additionalInfo:)"
}
-->

# startRedirectPayment(with:additionalInfo:)

**Instance Method**

Initiates a schema-based payment transaction.
This method processes a payment with schema-based payment methods such as digital wallets or bank transfers.
You should collect all information from your user before calling this api

```
@MainActor func startRedirectPayment(with name: String, additionalInfo: [String : String]?)
```

## Parameters

`name`

The name of the payment method, as defined by the payment platform.

`additionalInfo`

A dictionary containing any additional data required for processing the payment.
