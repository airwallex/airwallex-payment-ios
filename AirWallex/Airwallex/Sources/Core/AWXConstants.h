//
//  AWXConstants.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/25.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AWXConfirmPaymentNextAction;

NS_ASSUME_NONNULL_BEGIN

#define AIRWALLEX_VERSION (@"2.0.0")
#define AIRWALLEX_API_VERSION (@"2020-04-30")

typedef NS_ENUM(NSInteger, AirwallexSDKMode) {
    AirwallexSDKTestMode,
    AirwallexSDKLiveMode
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
    AWXFormTypeOption,
    AWXFormTypeField,
    AWXFormTypeButton
};

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

FOUNDATION_EXPORT NSErrorDomain const AWXSDKErrorDomain;

#else

FOUNDATION_EXPORT NSString *const AWXSDKErrorDomain;

#endif

FOUNDATION_EXPORT NSString *const AWXCyberSourceOrganizationID;
FOUNDATION_EXPORT NSString *const AWXCyberSourceMerchantID;

FOUNDATION_EXPORT NSString *const AWXWeChatPayKey;
FOUNDATION_EXPORT NSString *const AWXAlipayCNKey;
FOUNDATION_EXPORT NSString *const AWXAlipayHKKey;
FOUNDATION_EXPORT NSString *const AWXKakaoPayKey;
FOUNDATION_EXPORT NSString *const AWXTNGPayKey;
FOUNDATION_EXPORT NSString *const AWXDANAPayKey;
FOUNDATION_EXPORT NSString *const AWXGCashPayKey;
FOUNDATION_EXPORT NSString *const AWXTrueMoneyPayKey;
FOUNDATION_EXPORT NSString *const AWXBKashPayKey;
FOUNDATION_EXPORT NSString *const AWXPoli;
FOUNDATION_EXPORT NSString *const AWXFpx;
FOUNDATION_EXPORT NSString *const AWXBankTransfer;
FOUNDATION_EXPORT NSString *const AWXOnlineBanking;

FOUNDATION_EXPORT NSString *const AWXCardKey;
FOUNDATION_EXPORT NSString *const AWXThreeDSReturnURL;
FOUNDATION_EXPORT NSString *const AWXCybsURL;
FOUNDATION_EXPORT NSString *const AWXThreeDSCheckEnrollment;
FOUNDATION_EXPORT NSString *const AWXThreeDSValidate;
FOUNDATION_EXPORT NSString *const AWXDCC;

FOUNDATION_EXPORT NSString *const AWXFontFamilyNameCircularStd;
FOUNDATION_EXPORT NSString *const AWXFontNameCircularStdMedium;
FOUNDATION_EXPORT NSString *const AWXFontNameCircularStdBold;

FOUNDATION_EXPORT NSString *const AWXFontFamilyNameCircularXX;
FOUNDATION_EXPORT NSString *const AWXFontNameCircularXXRegular;

FOUNDATION_EXPORT NSString * FormatNextTriggerByType(AirwallexNextTriggerByType type);
FOUNDATION_EXPORT NSString * FormatMerchantTriggerReason(AirwallexMerchantTriggerReason reason);
FOUNDATION_EXPORT Class ClassToHandleFlowForPaymentMethodType(NSString *type);
FOUNDATION_EXPORT Class ClassToHandleNextActionForType(AWXConfirmPaymentNextAction *nextAction);

NS_ASSUME_NONNULL_END
