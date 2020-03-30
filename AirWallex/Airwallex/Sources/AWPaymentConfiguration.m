//
//  AWPaymentConfiguration.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentConfiguration.h"
#import "AWFontLoader.h"
#import "AWBilling.h"

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
        [AWFontLoader loadFontIfNeeded];
        self.cacheInfo = [@{} mutableCopy];
    }
    return self;
}

- (void)setBaseURL:(NSURL *)baseURL
{
    _baseURL = [baseURL URLByAppendingPathComponent:@""];
}

- (void)cache:(NSString *)key value:(NSString *)value
{
    self.cacheInfo[key] = value;
}

- (NSString *)cacheWithKey:(NSString *)key
{
    return self.cacheInfo[key];
}

- (id)copyWithZone:(NSZone *)zone
{
    AWPaymentConfiguration *copy = [[AWPaymentConfiguration allocWithZone:zone] init];
    copy.baseURL = [self.baseURL copyWithZone:zone];
    copy.intentId = [self.intentId copyWithZone:zone];
    copy.amount = [self.amount copyWithZone:zone];
    copy.token = [self.token copyWithZone:zone];
    copy.clientSecret = [self.clientSecret copyWithZone:zone];
    copy.customerId = [self.customerId copyWithZone:zone];
    copy.currency = [self.currency copyWithZone:zone];
    copy.shipping = [self.shipping copyWithZone:zone];
    copy.delegate = self.delegate;
    return copy;
}

@end
