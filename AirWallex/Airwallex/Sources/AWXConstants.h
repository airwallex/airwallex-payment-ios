//
//  AWXConstants.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/25.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AWXPaymentMethodType, AWXConfirmPaymentNextAction;

NS_ASSUME_NONNULL_BEGIN

#define AIRWALLEX_VERSION (@"3.0.2")
#define AIRWALLEX_API_VERSION (@"2020-04-30")

typedef NS_ENUM(NSInteger, AirwallexSDKMode) {
    AirwallexSDKDemoMode,
    AirwallexSDKStagingMode,
    AirwallexSDKProductionMode
};

typedef NS_ENUM(NSUInteger, AirwallexPaymentStatus) {
    AirwallexPaymentStatusSuccess,
    AirwallexPaymentStatusInProgress,
    AirwallexPaymentStatusFailure,
    AirwallexPaymentStatusCancel
};

typedef NS_ENUM(NSUInteger, AirwallexNextTriggerByType) {
    AirwallexNextTriggerByCustomerType,
    AirwallexNextTriggerByMerchantType
};

typedef NS_ENUM(NSUInteger, AirwallexMerchantTriggerReason) {
    AirwallexMerchantTriggerReasonUnscheduled,
    AirwallexMerchantTriggerReasonScheduled
};

typedef NS_ENUM(NSUInteger, AWXFormType) {
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

FOUNDATION_EXPORT NSString *const AWXCyberSourceOrganizationID;
FOUNDATION_EXPORT NSString *const AWXCyberSourceMerchantID;

FOUNDATION_EXPORT NSString *const AWXCardKey;
FOUNDATION_EXPORT NSString *const AWXThreeDSReturnURL;
FOUNDATION_EXPORT NSString *const AWXCybsURL;
FOUNDATION_EXPORT NSString *const AWXThreeDSCheckEnrollment;
FOUNDATION_EXPORT NSString *const AWXThreeDSValidate;
FOUNDATION_EXPORT NSString *const AWXThreeDSContinue;
FOUNDATION_EXPORT NSString *const AWXDCC;

FOUNDATION_EXPORT NSString * FormatAirwallexSDKMode(AirwallexSDKMode mode);
FOUNDATION_EXPORT NSString * FormatNextTriggerByType(AirwallexNextTriggerByType type);
FOUNDATION_EXPORT AWXTextFieldType GetTextFieldTypeByUIType(NSString *uiType);
FOUNDATION_EXPORT NSString * FormatMerchantTriggerReason(AirwallexMerchantTriggerReason reason);
FOUNDATION_EXPORT Class ClassToHandleFlowForPaymentMethodType(AWXPaymentMethodType *type);
FOUNDATION_EXPORT Class ClassToHandleNextActionForType(AWXConfirmPaymentNextAction *nextAction);

NS_ASSUME_NONNULL_END
