//
//  AWAPIClient.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWAPIClient.h"
#import "AWAPIClient+Private.h"
#import "AWPaymentConfiguration.h"

static NSString * const APIBaseURL = @"https://api-demo.airwallex.com/api/v1";

@interface AWAPIClient ()

@property (nonatomic, strong, readwrite) NSString *apiKey;

@end

@implementation AWAPIClient

+ (instancetype)sharedClient
{
    static AWAPIClient *sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [self new];
    });
    return sharedClient;
}

- (instancetype)init
{
    return [self initWithConfiguration:[AWPaymentConfiguration sharedConfiguration]];
}

- (instancetype)initWithPublishableKey:(NSString *)publishableKey
{
    AWPaymentConfiguration *config = [[AWPaymentConfiguration alloc] init];
    config.publishableKey = [publishableKey copy];
    return [self initWithConfiguration:config];
}

- (instancetype)initWithConfiguration:(AWPaymentConfiguration *)configuration
{
    NSString *publishableKey = [configuration.publishableKey copy];
    self = [super init];
    if (self) {
        _apiKey = publishableKey;
        _apiURL = [NSURL URLWithString:APIBaseURL];
        _configuration = configuration;
    }
    return self;
}

@end
