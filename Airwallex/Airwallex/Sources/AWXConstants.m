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

NSString * FormatPaymentMethodTypeString(NSString *type)
{
    if ([type isEqualToString:AWXWeChatPayKey]) {
        return @"WeChat Pay";
    } else if ([type isEqualToString:AWXAlipayCNKey]) {
        return @"Alipay";
    } else if ([type isEqualToString:AWXAlipayHKKey]) {
        return @"AlipayHK";
    } else if ([type isEqualToString:AWXKakaoPayKey]) {
        return @"Kakao Pay";
    } else if ([type isEqualToString:AWXTNGPayKey]) {
        return @"Touch 'n Go";
    } else if ([type isEqualToString:AWXDANAPayKey]) {
        return @"DANA";
    } else if ([type isEqualToString:AWXGCashPayKey]) {
        return @"GCash";
    } else if ([type isEqualToString:AWXTrueMoneyPayKey]) {
        return @"Truemoney";
    } else if ([type isEqualToString:AWXBKashPayKey]) {
        return @"BKash";
    } else if ([type isEqualToString:AWXPoli]) {
        return @"POLI";
    } else if ([type isEqualToString:AWXFpx]) {
        return @"FPX";
    } else if ([type isEqualToString:AWXBankTransfer]) {
        return @"Bank transfer";
    } else if ([type isEqualToString:AWXOnlineBanking]) {
        return @"Online Banking";
    }
    return nil;
}

NSString * PaymentMethodTypeLogo(NSString *type)
{
    if ([type isEqualToString:AWXWeChatPayKey]) {
        return @"wechat";
    } else if ([type isEqualToString:AWXAlipayCNKey]) {
        return @"alipaycn";
    } else if ([type isEqualToString:AWXAlipayHKKey]) {
        return @"alipayhk";
    } else if ([type isEqualToString:AWXKakaoPayKey]) {
        return @"kakaopay";
    } else if ([type isEqualToString:AWXTNGPayKey]) {
        return @"tng";
    } else if ([type isEqualToString:AWXDANAPayKey]) {
        return @"dana";
    } else if ([type isEqualToString:AWXGCashPayKey]) {
        return @"gcash";
    } else if ([type isEqualToString:AWXTrueMoneyPayKey]) {
        return @"truemoney";
    } else if ([type isEqualToString:AWXBKashPayKey]) {
        return @"bKash";
    } else if ([type isEqualToString:AWXPoli]) {
        return @"poli";
    } else if ([type isEqualToString:AWXFpx]) {
        return @"fpx";
    } else if ([type isEqualToString:AWXBankTransfer]) {
        return @"bank_transfer";
    } else if ([type isEqualToString:AWXOnlineBanking]) {
        return @"online_banking";
    }
    return nil;
}
