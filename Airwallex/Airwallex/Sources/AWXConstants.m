//
//  AWXConstants.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/25.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXConstants.h"

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

NSString *const AWXCardKey = @"card";
NSString *const AWXThreeDSReturnURL = @"";
NSString *const AWXThreeDSCheckEnrollment = @"3dsCheckEnrollment";
NSString *const AWXThreeDSValidate = @"3dsValidate";
NSString *const AWXDCC = @"dcc";

NSString *const AWXFontFamilyNameCircularStd = @"Circular Std";
NSString *const AWXFontNameCircularStdMedium = @"CircularStd-Medium";
NSString *const AWXFontNameCircularStdBold = @"CircularStd-Bold";

NSString *const AWXFontFamilyNameCircularXX = @"CircularXX";
NSString *const AWXFontNameCircularXXRegular = @"CircularXX-Regular";

NSString * FormatPaymentMethodTypeString(NSString *type)
{
    if ([type isEqualToString:AWXWeChatPayKey]) {
        return @"WeChat Pay";
    } else if ([type isEqualToString:AWXAlipayCNKey]) {
        return @"Alipay";
    } else if ([type isEqualToString:AWXAlipayHKKey]) {
        return @"Alipay";
    } else if ([type isEqualToString:AWXKakaoPayKey]) {
        return @"Alipay";
    } else if ([type isEqualToString:AWXTNGPayKey]) {
        return @"Alipay";
    } else if ([type isEqualToString:AWXDANAPayKey]) {
        return @"Alipay";
    } else if ([type isEqualToString:AWXGCashPayKey]) {
        return @"Alipay";
    }
    return nil;
}

NSString * PaymentMethodTypeLogo(NSString *type)
{
    if ([type isEqualToString:AWXWeChatPayKey]) {
        return @"wechat";
    } else if ([type isEqualToString:AWXAlipayCNKey]) {
        return @"alipay";
    } else if ([type isEqualToString:AWXAlipayHKKey]) {
        return @"alipay";
    } else if ([type isEqualToString:AWXKakaoPayKey]) {
        return @"alipay";
    } else if ([type isEqualToString:AWXTNGPayKey]) {
        return @"alipay";
    } else if ([type isEqualToString:AWXDANAPayKey]) {
        return @"alipay";
    } else if ([type isEqualToString:AWXGCashPayKey]) {
        return @"alipay";
    }
    return nil;
}
