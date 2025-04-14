//
//  AWXTheme.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/26.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXTheme.h"
#import "AWXUtils.h"
#import "UIColor+AWXTheme.h"
#import "UIColor+ViewCompat.h"

@implementation AWXTheme

+ (instancetype)sharedTheme {
    static AWXTheme *sharedTheme;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTheme = [self new];
    });
    return sharedTheme;
}

- (UIColor *)toolbarColor {
    return self.primaryBackgroundColor;
}

- (UIColor *)primaryBackgroundColor {
    return [UIColor colorWithDynamicLightColor:UIColor.whiteColor
                                     darkColor:UIColor.airwallexGray100Color];
}

- (UIColor *)surfaceBackgroundColor {
    return [UIColor colorWithDynamicLightColor:UIColor.whiteColor
                                     darkColor:UIColor.airwallexGray90Color];
}

- (UIColor *)primaryTextColor {
    return [UIColor colorWithDynamicLightColor:UIColor.airwallexGray100Color
                                     darkColor:UIColor.whiteColor];
}

- (UIColor *)secondaryTextColor {
    return UIColor.airwallexGray50Color;
}

- (UIColor *)disabledButtonColor {
    return self.lineColor;
}

- (UIColor *)primaryButtonTextColor {
    return [UIColor colorWithDynamicLightColor:UIColor.whiteColor
                                     darkColor:UIColor.airwallexGray100Color];
}

- (UIColor *)lineColor {
    return [UIColor colorWithDynamicLightColor:UIColor.airwallexGray30Color
                                     darkColor:UIColor.airwallexGray80Color];
}

- (UIColor *)glyphColor {
    return UIColor.airwallexGray70Color;
}

- (UIColor *)tintColor {
    if (_tintColor != nil) {
        return _tintColor;
    } else {
        return [UIColor colorWithDynamicLightColor:UIColor.airwallexUltraviolet70Color
                                         darkColor:UIColor.airwallexUltraviolet40Color];
    }
}

- (UIColor *)errorColor {
    return UIColor.airwallexRed50Color;
}

- (UIColor *)shadowColor {
    return [UIColor.blackColor colorWithAlphaComponent:0.08];
}

@end
