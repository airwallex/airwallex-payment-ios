//
//  AWXUtils.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Utils)

- (NSString *)queryURLEncoding;

@end

@interface NSBundle (Utils)

+ (NSBundle *)sdkBundle;
+ (NSBundle *)resourceBundle;

@end

@interface NSUserDefaults (Utils)

+ (NSUserDefaults *)awxUserDefaults;
- (void)reset;

@end

@interface NSString (Utils)

- (NSDictionary *)convertToDictionary;
- (NSString *)stringByRemovingIllegalCharacters;

@end

@interface NSLocale (Utils)

+ (NSLocale *)localeWithCurrency:(NSString *)currency;

@end

@interface NSDecimalNumber (Utils)

- (NSDecimalNumber *)toIntegerCents;
- (NSString *)string;
- (NSString *)stringWithCurrencyCode:(NSString *)currencyCode;
- (NSString *)currencySymbol:(NSString *)currencyCode;

@end

@interface AWXValidationUtils : NSObject

+ (void)checkNotNil:(id)value
               name:(NSString *)name;

+ (void)checkNotNegative:(NSDecimalNumber *)value
                    name:(NSString *)name;

@end

@interface UIImage (Utils)

+ (nullable UIImage *)imageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle;
+ (nullable UIImage *)imageNamed:(NSString *)name ofType:(NSString *)type inBundle:(nullable NSBundle *)bundle;
+ (UIImage *)imageFromColor:(UIColor *)color;

@end

@interface UIButton (Utils)

- (void)setImageAndTitleVerticalAlignmentCenter:(float)spacing imageSize:(CGSize)imageSize;
- (void)setImageAndTitleHorizontalAlignmentCenter:(float)spacing;

@end

@interface NSCharacterSet (Utils)

+ (NSCharacterSet *)invertedAsciiDigitCharacterSet;
+ (NSCharacterSet *)allURLQueryAllowedCharacterSet;

@end

@interface NSURL (Utils)

- (nullable NSArray *)queryItems;
- (nullable NSString *)queryValueForName:(NSString *)name;

@end

@interface UIView (Utils)

+ (instancetype)autoLayoutView;
- (void)roundCorners:(UIRectCorner)corners radius:(CGFloat)radius;

@end

@interface UIImageView (Utils)

- (void)setImageURL:(NSURL *)imageURL placeholder:(nullable UIImage *)placeholder;

@end

@interface UIColor (Utils)

+ (UIColor *)colorWithHex:(NSUInteger)hex;
+ (UIColor *)gray10Color;
+ (UIColor *)gray30Color;
+ (UIColor *)gray50Color;
+ (UIColor *)gray70Color;
+ (UIColor *)gray100Color;
+ (UIColor *)ultravioletColor;
+ (UIColor *)infraredColor;

@end

@interface UIFont (Utils)

+ (UIFont *)titleFont;
+ (UIFont *)headlineFont;
+ (UIFont *)bodyFont;
+ (UIFont *)subhead1Font;
+ (UIFont *)subhead2Font;
+ (UIFont *)caption1Font;
+ (UIFont *)caption2Font;

@end

@interface NSArray (Utils)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;

@end

NS_ASSUME_NONNULL_END
