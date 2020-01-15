//
//  NSNumber+Utils.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "NSNumber+Utils.h"

@implementation NSNumber (Utils)

- (NSString *)string
{
    if (self == [NSDecimalNumber zero]) {
        return @"Free";
    }

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.usesGroupingSeparator = YES;
    return [formatter stringFromNumber:self];
}

@end
