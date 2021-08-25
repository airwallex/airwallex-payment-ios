//
//  AWXConstants.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/25.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXConstants.h"
#import "AWXAPIClient.h"
#import "AWXPaymentIntentResponse.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

NSErrorDomain const AWXSDKErrorDomain = @"com.airwallex.error";

#else

NSString *const AWXSDKErrorDomain = @"com.airwallex.error";

#endif

NSString *const AWXCyberSourceOrganizationID = @"1snn5n9w";
NSString *const AWXCyberSourceMerchantID = @"airwallex_cybs";

NSString *const AWXWeChatPayKey = @"wechatpay";
NSString *const AWXAlipayCNKey = @"alipaycn";
NSString *const AWXAlipayHKKey = @"alipayhk";
NSString *const AWXKakaoPayKey = @"kakaopay";
NSString *const AWXTNGPayKey = @"tng";
NSString *const AWXDANAPayKey = @"dana";
NSString *const AWXGCashPayKey = @"gcash";
NSString *const AWXTrueMoneyPayKey = @"truemoney";
NSString *const AWXBKashPayKey = @"bkash";
NSString *const AWXPoli = @"poli";
NSString *const AWXFpx = @"fpx";
NSString *const AWXBankTransfer = @"bank_transfer";
NSString *const AWXOnlineBanking = @"online_banking";

NSString *const AWXCardKey = @"card";
NSString *const AWXThreeDSReturnURL = @"https://www.airwallex.com";
NSString *const AWXThreeDSCheckEnrollment = @"3dsCheckEnrollment";
NSString *const AWXThreeDSValidate = @"3dsValidate";
NSString *const AWXDCC = @"dcc";

NSString *const AWXFontFamilyNameCircularStd = @"Circular Std";
NSString *const AWXFontNameCircularStdMedium = @"CircularStd-Medium";
NSString *const AWXFontNameCircularStdBold = @"CircularStd-Bold";

NSString *const AWXFontFamilyNameCircularXX = @"CircularXX";
NSString *const AWXFontNameCircularXXRegular = @"CircularXX-Regular";

NSString * FormatNextTriggerByType(AirwallexNextTriggerByType type)
{
    switch (type) {
        case AirwallexNextTriggerByCustomerType:
            return @"customer";
        case AirwallexNextTriggerByMerchantType:
            return @"merchant";
    }
}

NSString * FormatMerchantTriggerReason(AirwallexMerchantTriggerReason reason)
{
    switch (reason) {
        case AirwallexMerchantTriggerReasonUnscheduled:
            return @"unscheduled";
        case AirwallexMerchantTriggerReasonScheduled:
            return @"scheduled";
    }
}

Class ClassToHandleFlowForPaymentMethodType(NSString *type)
{
    if ([type isEqualToString:AWXCardKey]) {
        return NSClassFromString(@"AWXCardProvider");
    } else if ([Airwallex.paymentFormRequiredTypes containsObject:type]) {
        return NSClassFromString(@"AWXPPROProvider");
    } else {
        return NSClassFromString(@"AWXDefaultProvider");
    }
}

Class ClassToHandleNextActionForType(AWXConfirmPaymentNextAction *nextAction)
{
    if ([nextAction.type isEqualToString:@"call_sdk"]) {
        return NSClassFromString(@"AWXWeChatPayActionProvider");
    } else if ([nextAction.type isEqualToString:@"redirect"]) {
        if (nextAction.payload[@"data"]) {
            return NSClassFromString(@"AWXThreeDSActionProvider");
        } else {
            return NSClassFromString(@"AWXRedirectActionProvider");
        }
    } else if ([nextAction.type isEqualToString:@"dcc"]) {
        return NSClassFromString(@"AWXDccActionProvider");
    } else {
        return NSClassFromString(@"AWXDefaultActionProvider");
    }
}
