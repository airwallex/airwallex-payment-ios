//
//  AWTheme.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/26.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWTheme : NSObject

@property (nonatomic, copy, null_resettable) UIColor *lineColor;
@property (nonatomic, copy, null_resettable) UIColor *purpleColor;

+ (instancetype)defaultTheme;

@end

NS_ASSUME_NONNULL_END
