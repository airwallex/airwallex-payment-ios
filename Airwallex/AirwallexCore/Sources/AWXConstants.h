//
//  AWXConstants.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/25.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>
#import <UIKit/UIKit.h>

@class AWXPaymentMethodType, AWXConfirmPaymentNextAction;

NS_ASSUME_NONNULL_BEGIN

#define AIRWALLEX_VERSION (@"5.7.0")
#define AIRWALLEX_API_VERSION (@"2021-11-25")

typedef NSString *AWXCardBrand NS_TYPED_ENUM;
extern AWXCardBrand const AWXCardBrandVisa;
extern AWXCardBrand const AWXCardBrandAmex;
extern AWXCardBrand const AWXCardBrandMastercard;
extern AWXCardBrand const AWXCardBrandDiscover;
extern AWXCardBrand const AWXCardBrandJCB;
extern AWXCardBrand const AWXCardBrandDinersClub;
extern AWXCardBrand const AWXCardBrandUnionPay;

typedef NSString *AWXPaymentMethodFlow NS_TYPED_EXTENSIBLE_ENUM;
extern AWXPaymentMethodFlow const AWXPaymentMethodFlowApp;
extern AWXPaymentMethodFlow const AWXPaymentMethodFlowWeb;
extern AWXPaymentMethodFlow const AWXPaymentMethodFlowQrcode;

typedef NS_OPTIONS(NSUInteger, AWXRequiredBillingContactFields) {
    AWXRequiredBillingContactFieldNone = 0,
    AWXRequiredBillingContactFieldName = 1 << 0,
    AWXRequiredBillingContactFieldEmail = 1 << 1,
    AWXRequiredBillingContactFieldPhone = 1 << 2,
    AWXRequiredBillingContactFieldAddress = 1 << 3,
    AWXRequiredBillingContactFieldCountryCode = 1 << 4,
} NS_SWIFT_NAME(RequiredBillingContactFields);

typedef NS_CLOSED_ENUM(NSInteger, AirwallexSDKMode) {
    AirwallexSDKDemoMode,
    AirwallexSDKStagingMode,
    AirwallexSDKProductionMode
};

typedef NS_CLOSED_ENUM(NSUInteger, AirwallexPaymentStatus) {
    AirwallexPaymentStatusSuccess,
    AirwallexPaymentStatusInProgress,
    AirwallexPaymentStatusFailure,
    AirwallexPaymentStatusCancel
};

typedef NS_CLOSED_ENUM(NSUInteger, AirwallexNextTriggerByType) {
    AirwallexNextTriggerByCustomerType,
    AirwallexNextTriggerByMerchantType
};

typedef NS_CLOSED_ENUM(NSUInteger, AirwallexMerchantTriggerReason) {
    AirwallexMerchantTriggerReasonUndefined,
    AirwallexMerchantTriggerReasonUnscheduled,
    AirwallexMerchantTriggerReasonScheduled
};

typedef NS_CLOSED_ENUM(NSUInteger, AWXFormType) {
    AWXFormTypeText,
    AWXFormTypeListCell,
    AWXFormTypeButton
};

typedef NS_ENUM(NSUInteger, AWXTextFieldType) {
    AWXTextFieldTypeDefault,
    AWXTextFieldTypeFirstName,
    AWXTextFieldTypeLastName,
    AWXTextFieldTypeEmail,
    AWXTextFieldTypePhoneNumber,
    AWXTextFieldTypeCountry,
    AWXTextFieldTypeState,
    AWXTextFieldTypeCity,
    AWXTextFieldTypeStreet,
    AWXTextFieldTypeZipcode,
    AWXTextFieldTypeCardNumber,
    AWXTextFieldTypeNameOnCard,
    AWXTextFieldTypeExpires,
    AWXTextFieldTypeCVC
};

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

FOUNDATION_EXPORT NSErrorDomain const AWXSDKErrorDomain;

#else

FOUNDATION_EXPORT NSString *const AWXSDKErrorDomain;

#endif

FOUNDATION_EXPORT NSString *const AWXThreatMatrixOrganizationID;
FOUNDATION_EXPORT NSString *const AWXThreatMatrixFingerprintServer;

FOUNDATION_EXPORT NSString *const AWXCardKey;
FOUNDATION_EXPORT NSString *const AWXThreeDSReturnURL;
FOUNDATION_EXPORT NSString *const AWXCybsURL;
FOUNDATION_EXPORT NSString *const AWXThreeDSCheckEnrollment;
FOUNDATION_EXPORT NSString *const AWXThreeDSWatingDeviceDataCollection;
FOUNDATION_EXPORT NSString *const AWXThreeDSWaitingUserInfoInput;
FOUNDATION_EXPORT NSString *const AWXThreeDSValidate;
FOUNDATION_EXPORT NSString *const AWXThreeDSContinue;
FOUNDATION_EXPORT NSString *const AWXDCC;

FOUNDATION_EXPORT NSString *const AWXWeChatPayKey;
FOUNDATION_EXPORT NSString *const AWXApplePayKey;

FOUNDATION_EXPORT NSArray<PKPaymentNetwork> *AWXApplePaySupportedNetworks(void);

FOUNDATION_EXPORT NSArray *AWXCardSupportedBrands(void);

FOUNDATION_EXPORT NSString *FormatAirwallexSDKMode(AirwallexSDKMode mode);
FOUNDATION_EXPORT NSString *FormatNextTriggerByType(AirwallexNextTriggerByType type);
FOUNDATION_EXPORT AWXTextFieldType GetTextFieldTypeByUIType(NSString *uiType);
FOUNDATION_EXPORT NSString *_Nullable FormatMerchantTriggerReason(AirwallexMerchantTriggerReason reason);
FOUNDATION_EXPORT _Nullable Class ClassToHandleFlowForPaymentMethodType(AWXPaymentMethodType *type);
FOUNDATION_EXPORT Class ClassToHandleNextActionForType(AWXConfirmPaymentNextAction *nextAction);

NS_ASSUME_NONNULL_END
