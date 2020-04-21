//
//  AWConstants.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/25.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWConstants.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

NSErrorDomain const AWSDKErrorDomain = @"com.airwallex.sdk";

#else

NSString *const AWSDKErrorDomain = @"com.airwallex.sdk";

#endif

NSString *const AWCyberSourceOrganizationID = @"1snn5n9w";
NSString *const AWCyberSourceMerchantID = @"airwallex_cybs";

NSString *const AWWeChatPayKey = @"wechatpay";
NSString *const AWCardKey = @"card";

NSString *const AWFontFamilyNameCircularStd = @"Circular Std";
NSString *const AWFontNameCircularStdMedium = @"CircularStd-Medium";
NSString *const AWFontNameCircularStdBold = @"CircularStd-Bold";
