//
//  UIColor+ViewCompat.m
//  Core
//
//  Created by Jarrod Robins on 20/6/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "UIColor+ViewCompat.h"

@implementation UIColor (ViewCompat)

+ (UIColor *)colorWithDynamicLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
            switch (traitCollection.userInterfaceStyle) {
            case UIUserInterfaceStyleDark:
                return darkColor;
            default:
                return lightColor;
            }
        }];

    } else {
        return lightColor;
    }
}

@end
