//
//  AWXUtils.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXUtils.h"
#import "AWXConstants.h"
#import "AWXLogger.h"
#import "AWXAPIClient.h"

static NSString * const kSDKSuiteName = @"com.airwallex.sdk";

@implementation NSDictionary (Utils)

- (NSString *)queryURLEncoding
{
    NSMutableArray<NSString *> *parametersArray = [NSMutableArray array];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *queryString = [[NSString stringWithFormat:@"%@", obj] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [parametersArray addObject:[NSString stringWithFormat:@"%@=%@", key, queryString]];
    }];
    return [parametersArray componentsJoinedByString:@"&"];
}

@end

@implementation NSBundle (Utils)

+ (NSBundle *)sdkBundle
{
    return [NSBundle bundleForClass:[Airwallex class]];
}

+ (NSBundle *)resourceBundle
{
    return [NSBundle bundleWithPath:[self.sdkBundle pathForResource:@"AirwallexSDK" ofType:@"bundle"]];
}

@end

@implementation NSUserDefaults (Utils)

+ (NSUserDefaults *)awxUserDefaults
{
    return [[NSUserDefaults alloc] initWithSuiteName:kSDKSuiteName];
}

- (void)reset
{
    NSDictionary *keys = self.dictionaryRepresentation;
    for (id key in keys) {
        [self removeObjectForKey:key];
    }
    [self synchronize];
}

@end

@implementation NSString (Utils)

- (NSDictionary *)convertToDictionary
{
    if (self == nil) {
        return nil;
    }
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:0
                                                           error:&error];
    if (error) {
        return nil;
    }
    return dict;
}

- (NSString *)stringByRemovingIllegalCharacters
{
    NSCharacterSet *set = [NSCharacterSet decimalDigitCharacterSet].invertedSet;
    NSArray *components = [self componentsSeparatedByCharactersInSet:set];
    return [components componentsJoinedByString:@""];
}

@end

@implementation NSLocale (Utils)

+ (NSLocale *)localeWithCurrency:(NSString *)currency
{
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

- (NSDecimalNumber *)toIntegerCents
{
    if (self == [NSDecimalNumber notANumber]) {
        [[AWXLogger sharedLogger] logException:@"NaN can't be convert to cents"];
    }

    NSDecimalNumberHandler *round = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                           scale:0
                                                                                raiseOnExactness:YES
                                                                                 raiseOnOverflow:YES
                                                                                raiseOnUnderflow:YES
                                                                             raiseOnDivideByZero:YES];
    return [self decimalNumberByMultiplyingByPowerOf10:2 withBehavior:round];
}

- (NSString *)string
{
    if (self == [NSDecimalNumber zero]) {
        return @"Free";
    }

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.usesGroupingSeparator = YES;
    return [formatter stringFromNumber:self];
}

- (NSString *)stringWithCurrencyCode:(NSString *)currencyCode
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = [NSLocale localeWithCurrency:currencyCode];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.usesGroupingSeparator = YES;
    return [formatter stringFromNumber:self];
}

- (NSString *)currencySymbol:(NSString *)currencyCode
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = [NSLocale localeWithCurrency:currencyCode];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    if ([formatter.currencySymbol isEqualToString:@"HK$"]) {
        return @"$";
    }
    return formatter.currencySymbol;
}

@end

@implementation AWXValidationUtils

+ (void)checkNotNil:(id)value
               name:(NSString *)name
{
    if (value == nil) {
        [[AWXLogger sharedLogger] logException:[NSString stringWithFormat:@"%@ must not be nil", name]];
    }
}

+ (void)checkNotNegative:(NSDecimalNumber *)value
                    name:(NSString *)name
{
    if ([value compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        [[AWXLogger sharedLogger] logException:[NSString stringWithFormat:@"%@ must not be negative", name]];
    }
}

@end

@implementation UIImage (Utils)

+ (nullable UIImage *)imageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle
{
    return [UIImage imageNamed:name ofType:@"png" inBundle:bundle];
}

+ (nullable UIImage *)imageNamed:(NSString *)name ofType:(NSString *)type inBundle:(nullable NSBundle *)bundle
{
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:type]];
}

@end

@implementation UIButton (Utils)

- (void)setImageAndTitleVerticalAlignmentCenter:(float)spacing imageSize:(CGSize)imageSize
{
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    self.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0f, 0.0f, - titleSize.width);
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0f, - imageSize.width, - (imageSize.height + spacing), 0.0f);
}

- (void)setImageAndTitleHorizontalAlignmentCenter:(float)spacing
{
    self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
}

@end

@implementation NSCharacterSet (Utils)

+ (NSCharacterSet *)invertedAsciiDigitCharacterSet
{
    return [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789- "] invertedSet];
}

+ (NSCharacterSet *)allURLQueryAllowedCharacterSet
{
    NSMutableCharacterSet *set = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [set removeCharactersInString:@"&+=?"];
    return set;
}

@end

@implementation NSURL (Utils)

- (nullable NSArray *)queryItems
{
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:YES];
    return urlComponents.queryItems;
}

- (nullable NSString *)queryValueForName:(NSString *)name
{
    NSArray *queryItems = self.queryItems;
    if (!queryItems) {
        return nil;
    }
    
    for (NSURLQueryItem *item in queryItems) {
        if ([item.name isEqualToString:name]) {
            return item.value;
        }
    }
    return nil;
}

@end

@implementation UIView (Utils)

- (void)roundCorners:(UIRectCorner)corners radius:(CGFloat)radius
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    maskLayer.path = path.CGPath;
    self.layer.mask = maskLayer;
}

@end
