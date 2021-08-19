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

NSString * FormatNextTriggerByType(AirwallexNextTriggerByType type)
{
    switch (type) {
        case AirwallexNextTriggerByCustomerType:
            return @"customer";
        case AirwallexNextTriggerByMerchantType:
            return @"merchant";
    }
}
