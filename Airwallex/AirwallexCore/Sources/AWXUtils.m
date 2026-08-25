//
//  AWXUtils.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXUtils.h"
#import "AWXAPIClient.h"

@implementation NSDictionary (Utils)

- (NSString *)queryURLEncoding {
    NSMutableArray<NSString *> *parametersArray = [NSMutableArray array];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        NSString *queryString = [[NSString stringWithFormat:@"%@", obj] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [parametersArray addObject:[NSString stringWithFormat:@"%@=%@", key, queryString]];
    }];
    return [parametersArray componentsJoinedByString:@"&"];
}

@end

@implementation NSBundle (Utils)

+ (NSBundle *)sdkBundle {
    return [NSBundle bundleForClass:[Airwallex class]];
}

+ (NSBundle *)resourceBundle {
    NSArray *resourceName = @[@"AirwallexCore", @"Airwallex_AirwallexCore"];
    NSBundle *resourceBundle = nil;
    for (NSString *name in resourceName) {
        NSString *path = [self.sdkBundle pathForResource:name ofType:@"bundle"];
        if (path == nil)
            continue;
        resourceBundle = [NSBundle bundleWithPath:path];
        if (resourceBundle != nil)
            break;
    }
    return resourceBundle ? resourceBundle : self.sdkBundle;
}

@end

@implementation NSString (Utils)

- (NSString *)stringByInsertingBetweenWordsWithString:(NSString *)separator {
    int index = 1;
    NSMutableString *mutableInputString = self.mutableCopy;

    while (index < mutableInputString.length) {
        if ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[mutableInputString characterAtIndex:index]]) {
            [mutableInputString insertString:separator atIndex:index];
            index++;
        }
        index++;
    }

    return mutableInputString;
}

@end

@implementation NSLocale (Utils)

+ (NSLocale *)localeWithCurrency:(NSString *)currency {
    NSArray *locales = [NSLocale availableLocaleIdentifiers];
    for (NSString *localeId in locales) {
        NSLocale *locale = [NSLocale localeWithLocaleIdentifier:localeId];
        if ([locale.currencyCode isEqualToString:currency]) {
            return locale;
        }
    }
    return [NSLocale localeWithLocaleIdentifier:@"en_US"];
}

@end

@implementation NSDecimalNumber (Utils)

- (NSString *)stringWithCurrencyCode:(NSString *)currencyCode {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = [NSLocale localeWithCurrency:currencyCode];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.usesGroupingSeparator = YES;
    return [formatter stringFromNumber:self];
}

@end

@implementation UIImage (Utils)

+ (nullable UIImage *)imageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle {
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

@end
