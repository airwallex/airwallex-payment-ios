//
//  UIColor+ViewCompat.h
//  Core
//
//  Created by Jarrod Robins on 20/6/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ViewCompat)

+ (UIColor *)colorWithDynamicLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor;

@end
