<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXApplePayOptions/additionalPaymentSummaryItems",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(cs)AWXApplePayOptions(py)additionalPaymentSummaryItems"
  },
  "title" : "additionalPaymentSummaryItems"
}
-->

# additionalPaymentSummaryItems

**Instance Property**

An additional array of payment summary item objects that summarize the amount of the payment. Default value is nil.

```
var additionalPaymentSummaryItems: [PKPaymentSummaryItem]? { get set }
```

## Discussion

The SDK will automatically construct a PKPaymentSummaryItem with the total amount from the session object and
the label defined with the totalPriceLabel property. Please make sure the sum of all the items in the array equals the total amount
you set on the session object.
