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

@interface NSString (Utils)

- (NSString *)stringByInsertingBetweenWordsWithString:(NSString *)separator;

@end

@interface NSLocale (Utils)

+ (NSLocale *)localeWithCurrency:(NSString *)currency;

@end

@interface NSDecimalNumber (Utils)

- (NSString *)stringWithCurrencyCode:(NSString *)currencyCode;

@end

@interface UIImage (Utils)

+ (nullable UIImage *)imageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle;

@end

NS_ASSUME_NONNULL_END
