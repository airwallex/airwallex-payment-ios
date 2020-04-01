//
//  AWConstants.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/25.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

FOUNDATION_EXPORT NSErrorDomain const AWSDKErrorDomain;

#else

FOUNDATION_EXPORT NSString *const AWSDKErrorDomain;

#endif

FOUNDATION_EXPORT NSString *const AWWeChatPayKey;
FOUNDATION_EXPORT NSString *const AWCardKey;

FOUNDATION_EXPORT NSString *const AWFontFamilyNameCircularStd;
FOUNDATION_EXPORT NSString *const AWFontNameCircularStdMedium;
FOUNDATION_EXPORT NSString *const AWFontNameCircularStdBold;

NS_ASSUME_NONNULL_END
