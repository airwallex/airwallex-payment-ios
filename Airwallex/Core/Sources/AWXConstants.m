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
#import "AWXPaymentMethod.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

NSErrorDomain const AWXSDKErrorDomain = @"com.airwallex.error";

#else

NSString *const AWXSDKErrorDomain = @"com.airwallex.error";

#endif

NSString *const AWXThreatMatrixOrganizationID = @"w2txo5aa";
NSString *const AWXThreatMatrixFingerprintServer = @"imgs.signifyd.com";

NSString *const AWXCardKey = @"card";
NSString *const AWXThreeDSReturnURL = @"https://www.airwallex.com";
NSString *const AWXThreeDSCheckEnrollment = @"3dsCheckEnrollment";
NSString *const AWXThreeDSWatingDeviceDataCollection = @"WAITING_DEVICE_DATA_COLLECTION";
NSString *const AWXThreeDSWaitingUserInfoInput = @"WAITING_USER_INFO_INPUT";

NSString *const AWXThreeDSValidate = @"3dsValidate";
NSString *const AWXThreeDSContinue = @"3ds_continue";
NSString *const AWXDCC = @"dcc";

NSString *const AWXApplePayKey = @"applepay";

NSArray<PKPaymentNetwork> *AWXApplePaySupportedNetworks(void) {
    NSArray<PKPaymentNetwork> *shared = @[
        PKPaymentNetworkVisa,
        PKPaymentNetworkMasterCard,
        PKPaymentNetworkChinaUnionPay
    ];
    if (@available(iOS 12.0, *)) {
        return [shared arrayByAddingObject:PKPaymentNetworkMaestro];
    } else {
        return shared;
    }
}

NSString *FormatAirwallexSDKMode(AirwallexSDKMode mode) {
    switch (mode) {
    case AirwallexSDKDemoMode:
        return @"demo";
    case AirwallexSDKStagingMode:
        return @"staging";
    case AirwallexSDKProductionMode:
        return @"production";
    }
}

NSString *FormatNextTriggerByType(AirwallexNextTriggerByType type) {
    switch (type) {
    case AirwallexNextTriggerByCustomerType:
        return @"customer";
    case AirwallexNextTriggerByMerchantType:
        return @"merchant";
    }
}

AWXTextFieldType GetTextFieldTypeByUIType(NSString *uiType) {
    if ([uiType isEqualToString:@"email"]) {
        return AWXTextFieldTypeEmail;
    } else if ([uiType isEqualToString:@"phone"]) {
        return AWXTextFieldTypePhoneNumber;
    }
    return AWXTextFieldTypeDefault;
}

NSString *FormatMerchantTriggerReason(AirwallexMerchantTriggerReason reason) {
    switch (reason) {
    case AirwallexMerchantTriggerReasonUndefined:
        return NULL;
    case AirwallexMerchantTriggerReasonUnscheduled:
        return @"unscheduled";
    case AirwallexMerchantTriggerReasonScheduled:
        return @"scheduled";
    }
}

Class ClassToHandleFlowForPaymentMethodType(AWXPaymentMethodType *type) {
    if ([type.name isEqualToString:AWXCardKey]) {
        return NSClassFromString(@"AWXCardProvider");
    } else if ([type.name isEqualToString:AWXApplePayKey]) {
        return NSClassFromString(@"AWXApplePayProvider");
    } else if (type.hasSchema) {
        return NSClassFromString(@"AWXSchemaProvider");
    } else {
        return Nil;
    }
}

Class ClassToHandleNextActionForType(AWXConfirmPaymentNextAction *nextAction) {
    if ([nextAction.type isEqualToString:@"call_sdk"]) {
        return NSClassFromString(@"AWXWeChatPayActionProvider");
    } else if ([nextAction.type isEqualToString:@"redirect_form"]) {
        return NSClassFromString(@"AWX3DSActionProvider");
    } else if ([nextAction.type isEqualToString:@"redirect"]) {
        return NSClassFromString(@"AWXRedirectActionProvider");
    } else if ([nextAction.type isEqualToString:@"dcc"]) {
        return NSClassFromString(@"AWXDccActionProvider");
    } else {
        return NSClassFromString(@"AWXDefaultActionProvider");
    }
}
