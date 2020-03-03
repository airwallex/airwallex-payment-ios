//
//  AWPaymentConfiguration.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWBilling;

NS_ASSUME_NONNULL_BEGIN

@interface AWPaymentConfiguration : NSObject

@property (nonatomic, copy, readwrite) NSString *baseURL;
@property (nonatomic, copy, readwrite) NSString *intentId;
@property (nonatomic, copy, readwrite) NSDecimalNumber *totalNumber;
@property (nonatomic, copy, readwrite) NSString *token;
@property (nonatomic, copy, readwrite) NSString *clientSecret;
@property (nonatomic, copy, readwrite, nullable) NSString *customerId;
@property (nonatomic, copy, readwrite) NSString *currency;
@property (nonatomic, strong) AWBilling *shipping;

+ (instancetype)sharedConfiguration;
- (void)cache:(NSString *)key value:(NSString *)value;
- (NSString *)cacheWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
