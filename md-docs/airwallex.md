<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex",
  "metadataVersion" : "0.1.0",
  "role" : "Framework",
  "symbol" : {
    "kind" : "Framework",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "Airwallex"
  },
  "title" : "Airwallex"
}
-->

# Airwallex

**Framework**

## Overview

The Airwallex iOS SDK is a flexible tool that enables you to integrate payment methods into your iOS app. It provides native UI screens to facilitate payment functions on top of your existing purchase flow. You can also choose to build your own custom UI using API integration.

- [Installation](https://github.com/airwallex/airwallex-payment-ios?tab=readme-ov-file#installation)
- [Required Setup](https://github.com/airwallex/airwallex-payment-ios?tab=readme-ov-file#required-setup)
- [UI Integration - Hosted Payment Page](https://github.com/airwallex/airwallex-payment-ios?tab=readme-ov-file#ui-integration---hosted-payment-page-hpp)
- [UI Integration - Embedded Element](https://github.com/airwallex/airwallex-payment-ios?tab=readme-ov-file#ui-integration---embedded)
- [API Integration](https://github.com/airwallex/airwallex-payment-ios?tab=readme-ov-file#low-level-api-integration)

## Topics

### Preparation

[`AWXPaymentIntent`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentintent.md)

`AWXPaymentIntent` includes the information of payment intent.

[`Session`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/session.md)

`Session` is a specialized subclass of `AWXSession`

[`PaymentConsentOptions`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentconsentoptions.md)

Options for payment consents

[`AWXApplePayOptions`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxapplepayoptions.md)

Object used to construct PKPaymentRequest for Apple Pay.

[`AWXAPIClientConfiguration`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxapiclientconfiguration.md)

`AWXAPIClientConfiguration` contains the base configuration the API client needs.

### UI Integration - Hosted Payment Page

[`AWXUIContext`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext.md)

The main UI context for Airwallex payment flows.

### UI Integration - Embedded Element

[`AWXPaymentElement`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentelement.md)

An embeddable payment element that can be added to any view hierarchy.

### API Integration

[`PaymentSessionHandler`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentsessionhandler.md)

A low-level API handler for managing Airwallex payment sessions.

[`AWXPaymentConsent`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentconsent.md)

`AWXPaymentConsent` includes the info of payment consent.

### Customization

[`AWXTheme`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxtheme.md)

`AWXTheme` manages text styles.

### Payment Result

[`AWXPaymentResultDelegate`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentresultdelegate.md)

## Preparation

[`AWXPaymentIntent`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentintent.md)

[`Session`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/session.md)

[`PaymentConsentOptions`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentconsentoptions.md)

[`AWXApplePayOptions`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxapplepayoptions.md)

[`AWXAPIClientConfiguration`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxapiclientconfiguration.md)

## UI Integration - Hosted Payment Page

[`AWXUIContext`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxuicontext.md)

## UI Integration - Embedded Element

[`AWXPaymentElement`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentelement.md)

## API Integration

[`PaymentSessionHandler`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentsessionhandler.md)

[`AWXPaymentConsent`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentconsent.md)

## Customization

[`AWXTheme`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxtheme.md)

## Payment Result

[`AWXPaymentResultDelegate`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentresultdelegate.md)

## Classes

[`AWXAPIClient`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxapiclient.md)

[`AWXAPIErrorResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxapierrorresponse.md)

[`AWXAddress`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxaddress.md)

[`AWXApplePayProvider`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxapplepayprovider.md)

[`AWXAuthenticationData`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxauthenticationdata.md)

[`AWXBank`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxbank.md)

[`AWXBrand`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxbrand.md)

[`AWXCandidate`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcandidate.md)

[`AWXCard`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcard.md)

[`AWXCardCVCViewController`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcardcvcviewcontroller.md)

[`AWXCardOptions`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcardoptions.md)

[`AWXCardProvider`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcardprovider.md)

[`AWXCardScheme`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcardscheme.md)

[`AWXCardValidator`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcardvalidator.md)

[`AWXConfirmPaymentIntentRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxconfirmpaymentintentrequest.md)

[`AWXConfirmPaymentIntentResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxconfirmpaymentintentresponse.md)

[`AWXConfirmPaymentNextAction`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxconfirmpaymentnextaction.md)

[`AWXConfirmThreeDSRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxconfirmthreedsrequest.md)

[`AWXCountry`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcountry.md)

[`AWXCreatePaymentConsentRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcreatepaymentconsentrequest.md)

[`AWXCreatePaymentConsentResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcreatepaymentconsentresponse.md)

[`AWXCreatePaymentMethodRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcreatepaymentmethodrequest.md)

[`AWXCreatePaymentMethodResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcreatepaymentmethodresponse.md)

[`AWXDefaultActionProvider`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxdefaultactionprovider.md)

[`AWXDefaultProvider`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxdefaultprovider.md)

[`AWXDevice`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxdevice.md)

[`AWXDisablePaymentConsentRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxdisablepaymentconsentrequest.md)

[`AWXDisablePaymentConsentResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxdisablepaymentconsentresponse.md)

[`AWXField`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxfield.md)

[`AWXFieldValidation`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxfieldvalidation.md)

[`AWXForm`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxform.md)

[`AWXFormMapping`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxformmapping.md)

[`AWXGetAvailableBanksRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxgetavailablebanksrequest.md)

[`AWXGetAvailableBanksResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxgetavailablebanksresponse.md)

[`AWXGetPaResRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxgetparesrequest.md)

[`AWXGetPaResResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxgetparesresponse.md)

[`AWXGetPaymentConsentsRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxgetpaymentconsentsrequest.md)

[`AWXGetPaymentConsentsResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxgetpaymentconsentsresponse.md)

[`AWXGetPaymentIntentResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxgetpaymentintentresponse.md)

[`AWXGetPaymentMethodTypeRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxgetpaymentmethodtyperequest.md)

[`AWXGetPaymentMethodTypeResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxgetpaymentmethodtyperesponse.md)

[`AWXGetPaymentMethodTypesRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxgetpaymentmethodtypesrequest.md)

[`AWXGetPaymentMethodTypesResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxgetpaymentmethodtypesresponse.md)

[`AWXGetPaymentMethodsRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxgetpaymentmethodsrequest.md)

[`AWXGetPaymentMethodsResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxgetpaymentmethodsresponse.md)

[`AWXNextActionHandler`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxnextactionhandler.md)

[`AWXOneOffSession`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxoneoffsession.md)

[`AWXPaymentAttempt`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentattempt.md)

[`AWXPaymentMethod`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentmethod.md)

[`AWXPaymentMethodOptions`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentmethodoptions.md)

[`AWXPaymentMethodType`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentmethodtype.md)

[`AWXPlaceDetails`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxplacedetails.md)

[`AWXRecurringSession`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxrecurringsession.md)

[`AWXRecurringWithIntentSession`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxrecurringwithintentsession.md)

[`AWXRedirectActionProvider`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxredirectactionprovider.md)

[`AWXRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxrequest.md)

[`AWXResources`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxresources.md)

[`AWXResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxresponse.md)

[`AWXRetrievePaymentConsentRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxretrievepaymentconsentrequest.md)

[`AWXRetrievePaymentIntentRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxretrievepaymentintentrequest.md)

[`AWXSchema`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxschema.md)

[`AWXSession`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxsession.md)

[`AWXShippingViewController`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxshippingviewcontroller.md)

[`AWXThreeDs`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxthreeds.md)

[`AWXVerifyPaymentConsentRequest`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxverifypaymentconsentrequest.md)

[`AWXVerifyPaymentConsentResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxverifypaymentconsentresponse.md)

[`AWXViewController`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxviewcontroller.md)

[`AWXWeChatPayActionProvider`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxwechatpayactionprovider.md)

[`AWXWeChatPaySDKResponse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxwechatpaysdkresponse.md)

[`Airwallex`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/airwallex.md)

[`AnalyticsLogger`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/analyticslogger.md)

[`ImageLoader`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/imageloader.md)

[`PaymentSchedule`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentschedule.md)

[`TermsOfUse`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/termsofuse.md)

## Protocols

[`AWXJSONDecodable`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxjsondecodable.md)

[`AWXJSONEncodable`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxjsonencodable.md)

[`AWXPage`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpage.md)

[`AWXPageViewTrackable`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpageviewtrackable.md)

[`AWXPaymentElementDelegate`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentelementdelegate.md)

[`AWXProviderDelegate`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxproviderdelegate.md)

[`AWXShippingViewControllerDelegate`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxshippingviewcontrollerdelegate.md)

[`ErrorLoggable`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/errorloggable.md)

[`PaymentIntentProvider`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentintentprovider.md)

## Structures

[`AWXCardBrand`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcardbrand.md)

[`AWXHTTPMethod`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxhttpmethod.md)

[`AWXPaymentMethodFlow`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymentmethodflow.md)

[`Palette`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/palette.md)

[`RequiredBillingContactFields`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/requiredbillingcontactfields.md)

## Variables

[`AIRWALLEX_API_VERSION`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/airwallex_api_version.md)

[`AIRWALLEX_VERSION`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/airwallex_version.md)

[`AWXApplePayKey`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxapplepaykey.md)

[`AWXCardKey`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcardkey.md)

[`AWXCybsURL`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxcybsurl.md)

[`AWXHTTPMethodGET`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxhttpmethodget.md)

[`AWXHTTPMethodPOST`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxhttpmethodpost.md)

[`AWXPaymentTransactionModeOneOff`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymenttransactionmodeoneoff.md)

[`AWXPaymentTransactionModeRecurring`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxpaymenttransactionmoderecurring.md)

[`AWXSDKErrorDomain`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxsdkerrordomain.md)

[`AWXThreatMatrixFingerprintServer`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxthreatmatrixfingerprintserver.md)

[`AWXThreatMatrixOrganizationID`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxthreatmatrixorganizationid.md)

[`AWXThreeDSCheckEnrollment`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxthreedscheckenrollment.md)

[`AWXThreeDSContinue`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxthreedscontinue.md)

[`AWXThreeDSReturnURL`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxthreedsreturnurl.md)

[`AWXThreeDSValidate`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxthreedsvalidate.md)

[`AWXThreeDSWaitingUserInfoInput`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxthreedswaitinguserinfoinput.md)

[`AWXThreeDSWatingDeviceDataCollection`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxthreedswatingdevicedatacollection.md)

[`AWXWeChatPayKey`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxwechatpaykey.md)

[`AirwallexCoreVersionNumber`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/airwallexcoreversionnumber.md)

[`AirwallexCoreVersionString`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/airwallexcoreversionstring.md)

[`AirwallexWeChatPayVersionNumber`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/airwallexwechatpayversionnumber.md)

[`AirwallexWeChatPayVersionString`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/airwallexwechatpayversionstring.md)

[`PaymentVersionNumber`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentversionnumber.md)

[`PaymentVersionString`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentversionstring.md)

## Functions

[`AWXApplePaySupportedNetworks()`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxapplepaysupportednetworks().md)

[`ClassToHandleFlowForPaymentMethodType(_:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/classtohandleflowforpaymentmethodtype(_-).md)

[`ClassToHandleNextActionForType(_:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/classtohandlenextactionfortype(_-).md)

[`FormatAirwallexSDKMode(_:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/formatairwallexsdkmode(_-).md)

[`FormatMerchantTriggerReason(_:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/formatmerchanttriggerreason(_-).md)

[`FormatNextTriggerByType(_:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/formatnexttriggerbytype(_-).md)

[`GetTextFieldTypeByUIType(_:)`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/gettextfieldtypebyuitype(_-).md)

## Type Aliases

[`AWXRequestHandler`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxrequesthandler.md)

## Enumerations

[`AWXBrandType`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxbrandtype.md)

[`AWXFormType`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxformtype.md)

[`AWXSDKErrorCode`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxsdkerrorcode.md)

[`AWXTextFieldType`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/awxtextfieldtype.md)

[`AirwallexMerchantTriggerReason`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/airwallexmerchanttriggerreason.md)

[`AirwallexNextTriggerByType`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/airwallexnexttriggerbytype.md)

[`AirwallexPaymentStatus`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/airwallexpaymentstatus.md)

[`AirwallexSDKMode`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/airwallexsdkmode.md)

[`PaymentAmountType`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/paymentamounttype.md)

[`PeriodUnit`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/periodunit.md)

## Extended Modules

[`CoreGraphics`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/coregraphics.md)

[`Foundation`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/foundation.md)

[`ObjectiveC`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/objectivec.md)

[`PassKit`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/passkit.md)

[`UIKit`](https://github.com/airwallex/airwallex-payment-ios/blob/md-doc/md-docs/airwallex/uikit.md)
