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
NSString *const AWXCardKey = @"card";
NSString *const AWXThreeDSReturnURL = @"";
NSString *const AWXTermURL = @"https://demo-pacybsmock.airwallex.com/";
NSString *const AWXThreeDSCheckEnrollment = @"3dsCheckEnrollment";
NSString *const AWXThreeDSValidate = @"3dsValidate";
NSString *const AWXDCC = @"dcc";

NSString *const AWXFontFamilyNameCircularStd = @"Circular Std";
NSString *const AWXFontNameCircularStdMedium = @"CircularStd-Medium";
NSString *const AWXFontNameCircularStdBold = @"CircularStd-Bold";

NSString *const AWXFontFamilyNameCircularXX = @"CircularXX";
NSString *const AWXFontNameCircularXXRegular = @"CircularXX-Regular";
