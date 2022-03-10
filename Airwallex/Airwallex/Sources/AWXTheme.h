//
//  AWXTheme.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/26.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXTheme` manages text styles.
 */
@interface AWXTheme : NSObject

/**
 Line Color.
 */
@property (nonatomic, copy, null_resettable) UIColor *lineColor;

/**
 Tint Color.
 */
@property (nonatomic, copy, null_resettable) UIColor *tintColor;

/**
 Text Color.
 */
@property (nonatomic, copy, null_resettable) UIColor *textColor;

/**
 Convenience constructor for a theme.
 
 @return The shared theme.
 */
+ (instancetype)sharedTheme;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
