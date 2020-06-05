//
//  AWXTheme.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/26.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXTheme.h"

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
    AWXThemeDefaultLineColor = [UIColor colorWithRed:235.0f/255.0f green:236.0f/255.0f blue:240.0f/255.0f alpha:1];
    AWXThemeDefaultPurpleColor = [UIColor colorWithRed:97.0f/255.0f green:47.0f/255.0f blue:255.0f/255.0f alpha:1];
    AWXThemeDefaultTextColor = [UIColor colorWithRed:42.0f/255.0f green:42.0f/255.0f blue:42.0f/255.0f alpha:1];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lineColor = AWXThemeDefaultLineColor;
        self.purpleColor = AWXThemeDefaultPurpleColor;
        self.textColor = AWXThemeDefaultTextColor;
    }
    return self;
}

- (UIColor *)lineColor
{
    return _lineColor ?: AWXThemeDefaultLineColor;
}

- (UIColor *)purpleColor
{
    return _purpleColor ?: AWXThemeDefaultPurpleColor;
}

- (UIColor *)textColor
{
    return _textColor ?: AWXThemeDefaultTextColor;
}

@end
