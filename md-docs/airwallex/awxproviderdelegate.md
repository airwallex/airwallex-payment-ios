<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXProviderDelegate",
  "metadataVersion" : "0.1.0",
  "role" : "Protocol",
  "symbol" : {
    "kind" : "Protocol",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(pl)AWXProviderDelegate"
  },
  "title" : "AWXProviderDelegate"
}
-->

# AWXProviderDelegate

**Protocol**

A delegate which handles checkout results.

```
@MainActor protocol AWXProviderDelegate : NSObjectProtocol
```

## Instance Methods

[`hostViewController()`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxproviderdelegate/hostviewcontroller().md)

[`provider(_:didCompleteWith:error:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxproviderdelegate/provider(_-didcompletewith-error-).md)

[`provider(_:didCompleteWithPaymentConsentId:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxproviderdelegate/provider(_-didcompletewithpaymentconsentid-).md)

[`provider(_:didInitializePaymentIntentId:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxproviderdelegate/provider(_-didinitializepaymentintentid-).md)

[`provider(_:shouldHandle:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxproviderdelegate/provider(_-shouldhandle-).md)

[`provider(_:shouldInsert:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxproviderdelegate/provider(_-shouldinsert-).md)

[`provider(_:shouldPresent:forceToDismiss:withAnimation:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxproviderdelegate/provider(_-shouldpresent-forcetodismiss-withanimation-).md)

[`providerDidEndRequest(_:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxproviderdelegate/providerdidendrequest(_-).md)

[`providerDidStartRequest(_:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxproviderdelegate/providerdidstartrequest(_-).md)
