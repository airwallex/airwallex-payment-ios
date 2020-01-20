//
//  AWPaymentConfiguration.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentConfiguration.h"

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

- (id)copyWithZone:(__unused NSZone *)zone
{
    AWPaymentConfiguration *copy = [self.class new];
    copy.baseURL = self.baseURL;
    copy.intentId = self.intentId;
    copy.requestId = self.requestId;
    copy.token = self.token;
    return copy;
}

@end
