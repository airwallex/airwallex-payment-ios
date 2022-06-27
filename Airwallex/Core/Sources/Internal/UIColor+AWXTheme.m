//
//  UIColor+AWXTheme.m
//  Core
//
//  Created by Jarrod Robins on 20/6/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "UIColor+AWXTheme.h"

@implementation UIColor (AWXTheme)

+ (UIColor *)colorWithHex:(NSUInteger)hex {
    CGFloat red, green, blue, alpha;
    red = ((CGFloat)((hex >> 16) & 0xFF)) / ((CGFloat)0xFF);
    green = ((CGFloat)((hex >> 8) & 0xFF)) / ((CGFloat)0xFF);
    blue = ((CGFloat)((hex >> 0) & 0xFF)) / ((CGFloat)0xFF);
    alpha = hex > 0xFFFFFF ? ((CGFloat)((hex >> 24) & 0xFF)) / ((CGFloat)0xFF) : 1;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)airwallexGray10Color {
    return [UIColor colorWithHex:0xF6F7F8];
}

+ (UIColor *)airwallexGray30Color {
    return [UIColor colorWithHex:0xD7DBE0];
}

+ (UIColor *)airwallexGray50Color {
    return [UIColor colorWithHex:0x868E98];
}

+ (UIColor *)airwallexGray70Color {
    return [UIColor colorWithHex:0x545B63];
}

+ (UIColor *)airwallexGray80Color {
    return [UIColor colorWithHex:0x42474D];
}

+ (UIColor *)airwallexGray90Color {
    return [UIColor colorWithHex:0x2F3237];
}

+ (UIColor *)airwallexGray100Color {
    return [UIColor colorWithHex:0x1A1D21];
}

+ (UIColor *)airwallexUltraviolet40Color {
    return [UIColor colorWithHex:0xB3AEFF];
}

+ (UIColor *)airwallexUltraviolet70Color {
    return [UIColor colorWithHex:0x612FFF];
}

+ (UIColor *)airwallexRed50Color {
    return [UIColor colorWithHex:0xFF4F42];
}

@end
