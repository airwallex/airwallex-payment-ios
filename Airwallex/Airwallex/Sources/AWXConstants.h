//
//  AWXConstants.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/25.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define AIRWALLEX_VERSION (@"1.0.0")
#define AIRWALLEX_API_VERSION (@"2020-04-30")

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

FOUNDATION_EXPORT NSErrorDomain const AWXSDKErrorDomain;

#else

FOUNDATION_EXPORT NSString *const AWXSDKErrorDomain;

#endif

FOUNDATION_EXPORT NSString *const AWXCyberSourceOrganizationID;
FOUNDATION_EXPORT NSString *const AWXCyberSourceMerchantID;

FOUNDATION_EXPORT NSString *const AWXWeChatPayKey;
FOUNDATION_EXPORT NSString *const AWXCardKey;
FOUNDATION_EXPORT NSString *const AWXThreeDSReturnURL;
FOUNDATION_EXPORT NSString *const AWXRedirectPaResURL;

FOUNDATION_EXPORT NSString *const AWXFontFamilyNameCircularStd;
FOUNDATION_EXPORT NSString *const AWXFontNameCircularStdMedium;
FOUNDATION_EXPORT NSString *const AWXFontNameCircularStdBold;

NS_ASSUME_NONNULL_END
