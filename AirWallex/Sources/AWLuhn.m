//
//  AWLuhn.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/12.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWLuhn.h"
#import "AWUtils.h"

@implementation AWLuhn

+ (AWCardType)typeFromString:(NSString *)string
{
    BOOL isValid = [self validateString:string];
    if (!isValid) {
        return AWCardTypeUnknown;
    }

    NSString *formattedString = [string stringByRemovingIllegalCharacters];
    if (formattedString == nil || formattedString.length < 9) {
        return AWCardTypeUnknown;
    }

    NSArray *enums = @[@(AWCardTypeAmex), @(AWCardTypeVisa), @(AWCardTypeMastercard), @(AWCardTypeDiscover), @(AWCardTypeDinersClub), @(AWCardTypeJCB)];
    __block AWCardType type = AWCardTypeUnknown;
    [enums enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AWCardType _type = [obj integerValue];
        NSPredicate *predicate = [self predicateForType:_type];
        BOOL isCurrentType = [predicate evaluateWithObject:formattedString];
        if (isCurrentType) {
            type = _type;
            *stop = YES;
        }
    }];
    return type;
}

+ (NSPredicate *)predicateForType:(AWCardType)type
{
    if (type == AWCardTypeUnknown) {
        return nil;
    }

    NSString *regex = nil;
    switch (type) {
        case AWCardTypeAmex:
            regex = @"^3[47][0-9]{5,}$";
            break;
        case AWCardTypeDinersClub:
            regex = @"^3(?:0[0-5]|[68][0-9])[0-9]{4,}$";
            break;
        case AWCardTypeDiscover:
            regex = @"^6(?:011|5[0-9]{2})[0-9]{3,}$";
            break;
        case AWCardTypeJCB:
            regex = @"^(?:2131|1800|35[0-9]{3})[0-9]{3,}$";
            break;
        case AWCardTypeMastercard:
            regex = @"^(5018|5020|5038|6304|6759|6761|6763)[0-9]{8,15}$";
            break;
        case AWCardTypeVisa:
            regex = @"^4[0-9]{6,}$";
            break;
        default:
            break;
    }
    return [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
}

+ (BOOL)validateString:(NSString *)string
{
    NSString *formattedString = [string stringByRemovingIllegalCharacters];
    if (formattedString == nil || formattedString.length < 9) {
        return NO;
    }

    NSMutableString *reversedString = [NSMutableString stringWithCapacity:[formattedString length]];
    [formattedString enumerateSubstringsInRange:NSMakeRange(0, [formattedString length]) options:(NSStringEnumerationReverse |NSStringEnumerationByComposedCharacterSequences) usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [reversedString appendString:substring];
    }];

    NSUInteger oddSum = 0, evenSum = 0;
    for (NSUInteger i = 0; i < [reversedString length]; i++) {
        NSInteger digit = [[NSString stringWithFormat:@"%C", [reversedString characterAtIndex:i]] integerValue];
        if (i % 2 == 0) {
            evenSum += digit;
        } else {
            oddSum += digit / 5 + (2 * digit) % 10;
        }
    }
    return (oddSum + evenSum) % 10 == 0;
}

@end
