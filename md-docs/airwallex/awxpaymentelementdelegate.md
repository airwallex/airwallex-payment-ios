<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXPaymentElementDelegate",
  "metadataVersion" : "0.1.0",
  "role" : "Protocol",
  "symbol" : {
    "kind" : "Protocol",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(pl)AWXPaymentElementDelegate"
  },
  "title" : "AWXPaymentElementDelegate"
}
-->

# AWXPaymentElementDelegate

**Protocol**

Delegate protocol for receiving payment events from AWXPaymentElement.

```
@MainActor @objc protocol AWXPaymentElementDelegate
```

## Overview

This delegate replaces `AWXPaymentResultDelegate` for AWXPaymentElement,
providing payment lifecycle notifications with method information.

## Instance Methods

[`paymentElement(_:didCompleteFor:with:error:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentelementdelegate/paymentelement(_-didcompletefor-with-error-).md)

[`paymentElement(_:didCompleteFor:withPaymentConsentId:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentelementdelegate/paymentelement(_-didcompletefor-withpaymentconsentid-).md)

[`paymentElement(_:onProcessingStateChangedFor:isProcessing:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentelementdelegate/paymentelement(_-onprocessingstatechangedfor-isprocessing-).md)

[`paymentElement(_:validationFailedFor:invalidInputView:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentelementdelegate/paymentelement(_-validationfailedfor-invalidinputview-).md)
