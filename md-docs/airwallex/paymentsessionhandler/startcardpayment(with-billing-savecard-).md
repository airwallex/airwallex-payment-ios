<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentSessionHandler/startCardPayment(with:billing:saveCard:)",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Method",
  "symbol" : {
    "kind" : "Instance Method",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@CM@Airwallex@objc(cs)PaymentSessionHandler(im)startCardPaymentWith:billing:saveCard:"
  },
  "title" : "startCardPayment(with:billing:saveCard:)"
}
-->

# startCardPayment(with:billing:saveCard:)

**Instance Method**

Initiates a card payment transaction.
This method sets up and confirms a card-based payment, including optional billing and card-saving preferences.

```
@MainActor func startCardPayment(with card: AWXCard, billing: AWXPlaceDetails?, saveCard: Bool = false)
```

## Parameters

`card`

The card details required for processing the payment.

`billing`

Billing information for the transaction (optional).

`saveCard`

A boolean indicating whether to save the card for future transactions (default is `false`).
