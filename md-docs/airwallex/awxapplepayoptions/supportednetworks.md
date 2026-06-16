<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXApplePayOptions/supportedNetworks",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(cs)AWXApplePayOptions(py)supportedNetworks"
  },
  "title" : "supportedNetworks"
}
-->

# supportedNetworks

**Instance Property**

The payment networks supported by the merchant, for example @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard].
This property constrains payment cards that may fund the payment. Default value includes Visa, Mastercard, UnionPay, Amex, Discover and JCB.

```
var supportedNetworks: [PKPaymentNetwork] { get set }
```
