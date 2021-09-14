//
//  AWXTheme.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/26.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXTheme.h"
#import "AWXUtils.h"

static UIColor *AWXThemeDefaultLineColor = nil;
static UIColor *AWXThemeDefaultPurpleColor = nil;
static UIColor *AWXThemeDefaultTextColor = nil;

@implementation AWXTheme

+ (instancetype)sharedTheme
{
    static AWXTheme *sharedTheme;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTheme = [self new];
    });
    return sharedTheme;
}

+ (void)initialize
{
    AWXThemeDefaultLineColor = [UIColor gray30Color];
    AWXThemeDefaultPurpleColor = [UIColor ultravioletColor];
    AWXThemeDefaultTextColor = [UIColor gray100Color];
}

- (UIColor *)lineColor
{
    return _lineColor ?: AWXThemeDefaultLineColor;
}

- (UIColor *)tintColor
{
    return _tintColor ?: AWXThemeDefaultPurpleColor;
}

- (UIColor *)textColor
{
    return _textColor ?: AWXThemeDefaultTextColor;
}

@end
