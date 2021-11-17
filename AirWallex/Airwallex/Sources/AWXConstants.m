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

NSString *const AWXCardKey = @"card";
NSString *const AWXThreeDSReturnURL = @"https://www.airwallex.com";
NSString *const AWXThreeDSCheckEnrollment = @"3dsCheckEnrollment";
NSString *const AWXThreeDSValidate = @"3dsValidate";
NSString *const AWXDCC = @"dcc";

NSString * FormatAirwallexSDKMode(AirwallexSDKMode mode)
{
    switch (mode) {
        case AirwallexSDKDemoMode:
            return @"demo";
        case AirwallexSDKStagingMode:
            return @"staging";
        case AirwallexSDKProductionMode:
            return @"production";
    }
}

NSString * FormatNextTriggerByType(AirwallexNextTriggerByType type)
{
    switch (type) {
        case AirwallexNextTriggerByCustomerType:
            return @"customer";
        case AirwallexNextTriggerByMerchantType:
            return @"merchant";
    }
}

AWXTextFieldType GetTextFieldTypeByUIType(NSString *uiType)
{
    if ([uiType isEqualToString:@"email"]) {
        return AWXTextFieldTypeEmail;
    } else if ([uiType isEqualToString:@"phone"]) {
        return AWXTextFieldTypePhoneNumber;
    }
    return AWXTextFieldTypeDefault;
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

Class ClassToHandleFlowForPaymentMethodType(AWXPaymentMethodType *type)
{
    if ([type.name isEqualToString:AWXCardKey]) {
        return NSClassFromString(@"AWXCardProvider");
    } else if (type.hasSchema) {
        return NSClassFromString(@"AWXSchemaProvider");
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
