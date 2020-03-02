//
//  AWTheme.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/26.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWTheme.h"

static UIColor *AWThemeDefaultLineColor = nil;
static UIColor *AWThemeDefaultPurpleColor = nil;

@implementation AWTheme

+ (instancetype)defaultTheme
{
    static AWTheme *theme;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        theme = [self new];
    });
    return theme;
}

+ (void)initialize
{
    AWThemeDefaultLineColor = [UIColor colorWithRed:235.0f/255.0f green:236.0f/255.0f blue:240.0f/255.0f alpha:1];
    AWThemeDefaultPurpleColor = [UIColor colorWithRed:97.0f/255.0f green:47.0f/255.0f blue:255.0f/255.0f alpha:1];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lineColor = AWThemeDefaultLineColor;
        self.purpleColor = AWThemeDefaultPurpleColor;
    }
    return self;
}

- (UIColor *)lineColor
{
    return _lineColor ?: AWThemeDefaultLineColor;
}

- (UIColor *)purpleColor
{
    return _purpleColor ?: AWThemeDefaultPurpleColor;
}

@end
