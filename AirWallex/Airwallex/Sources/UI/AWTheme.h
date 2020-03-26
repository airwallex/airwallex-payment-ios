//
//  AWTheme.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/26.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `AWTheme` manages text styles & colors.
 */
@interface AWTheme : NSObject

/**
 Line Color.
 */
@property (nonatomic, copy, null_resettable) UIColor *lineColor;

/**
 Purple Color.
 */
@property (nonatomic, copy, null_resettable) UIColor *purpleColor;

/**
 Text Color.
 */
@property (nonatomic, copy, null_resettable) UIColor *textColor;

/**
 Convenience constructor for a theme.
 
 @return The default theme.
 */
+ (instancetype)defaultTheme;

@end

NS_ASSUME_NONNULL_END
