//
//  UIColor+AWXTheme.h
//  Core
//
//  Created by Jarrod Robins on 20/6/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (AWXTheme)

+ (UIColor *)colorWithHex:(NSUInteger)hex;
+ (UIColor *)airwallexGray10Color;
+ (UIColor *)airwallexGray30Color;
+ (UIColor *)airwallexGray50Color;
+ (UIColor *)airwallexGray70Color;
+ (UIColor *)airwallexGray80Color;
+ (UIColor *)airwallexGray90Color;
+ (UIColor *)airwallexGray100Color;

+ (UIColor *)airwallexUltraviolet40Color;
+ (UIColor *)airwallexUltraviolet70Color;
+ (UIColor *)airwallexRed50Color;

@end
