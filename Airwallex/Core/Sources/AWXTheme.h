//
//  AWXTheme.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/26.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 `AWXTheme` manages text styles.
 */
@interface AWXTheme : NSObject

- (UIColor *_Nonnull)toolbarColor;
- (UIColor *_Nonnull)primaryBackgroundColor;
- (UIColor *_Nonnull)surfaceBackgroundColor;
- (UIColor *_Nonnull)primaryTextColor;
- (UIColor *_Nonnull)secondaryTextColor;
- (UIColor *_Nonnull)disabledButtonColor;
- (UIColor *_Nonnull)lineColor;
- (UIColor *_Nonnull)glyphColor;
- (UIColor *_Nonnull)errorColor;
- (UIColor *_Nonnull)primaryButtonTextColor;
- (UIColor *_Nonnull)shadowColor;

/**
 Tint Color.
 */
@property (nonatomic, copy, null_resettable) UIColor *tintColor;

/**
 Convenience constructor for a theme.

 @return The shared theme.
 */
+ (instancetype _Nonnull)sharedTheme;

+ (instancetype _Nonnull)new NS_UNAVAILABLE;
- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)allocWithZone:(struct _NSZone *_Nonnull)zone NS_UNAVAILABLE;

@end
