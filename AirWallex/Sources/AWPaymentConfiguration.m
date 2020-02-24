//
//  AWPaymentConfiguration.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentConfiguration.h"

@interface AWPaymentConfiguration ()

@property (nonatomic, strong) NSMutableDictionary *cacheInfo;

@end

@implementation AWPaymentConfiguration

+ (instancetype)sharedConfiguration
{
    static AWPaymentConfiguration *sharedConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfiguration = [self new];
    });
    return sharedConfiguration;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cacheInfo = [@{} mutableCopy];
    }
    return self;
}

- (void)cache:(NSString *)key value:(NSString *)value
{
    self.cacheInfo[key] = value;
}

- (NSString *)cacheWithKey:(NSString *)key
{
    return self.cacheInfo[key];
}

- (id)copyWithZone:(__unused NSZone *)zone
{
    AWPaymentConfiguration *copy = [self.class new];
    copy.baseURL = self.baseURL;
    copy.intentId = self.intentId;
    copy.token = self.token;
    copy.clientSecret = self.clientSecret;
    copy.currency = self.currency;
    copy.customerId = self.customerId;
    return copy;
}

@end
