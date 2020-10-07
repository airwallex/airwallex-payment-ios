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

#define AIRWALLEX_VERSION (@"2.0.0")
#define AIRWALLEX_API_VERSION (@"2020-04-30")

typedef NS_ENUM(NSInteger, AirwallexSDKMode) {
    AirwallexSDKTestMode,
    AirwallexSDKLiveMode
};

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
FOUNDATION_EXPORT NSString *const AWXThreeDSCheckEnrollment;
FOUNDATION_EXPORT NSString *const AWXThreeDSValidate;
FOUNDATION_EXPORT NSString *const AWXDCC;

FOUNDATION_EXPORT NSString *const AWXFontFamilyNameCircularStd;
FOUNDATION_EXPORT NSString *const AWXFontNameCircularStdMedium;
FOUNDATION_EXPORT NSString *const AWXFontNameCircularStdBold;

FOUNDATION_EXPORT NSString *const AWXFontFamilyNameCircularXX;
FOUNDATION_EXPORT NSString *const AWXFontNameCircularXXRegular;

NS_ASSUME_NONNULL_END
