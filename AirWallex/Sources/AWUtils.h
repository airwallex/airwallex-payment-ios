//
//  AWUtils.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Utils)

- (NSString *)queryURLEncoding;
- (NSError *)convertToNSErrorWithCode:(NSNumber *)code;
- (NSError *)convertToNSError;

@end

@interface NSBundle (Utils)

+ (NSBundle *)sdkBundle;
+ (NSBundle *)resourceBundle;

@end

@interface NSString (Utils)

- (NSDictionary *)convertToDictionary;

@end

@interface NSDecimalNumber (Utils)

- (NSDecimalNumber *)toIntegerCents;

@end

@interface AWValidationUtils : NSObject

+ (void)checkNotNil:(id)value
               name:(NSString *)name;

+ (void)checkNotNegative:(NSDecimalNumber *)value
                    name:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
