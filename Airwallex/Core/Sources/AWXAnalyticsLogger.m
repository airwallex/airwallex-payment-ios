//
//  AWXAnalyticsLogger.m
//  Core
//
//  Created by Hector.Huang on 2023/3/14.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXAnalyticsLogger.h"
#import "AWXAPIClient.h"
#import "NSData+Base64.h"
#import <AirTracker/AirTracker-Swift.h>

@interface AWXAnalyticsLogger ()

@property (nonatomic, strong, readonly) Tracker *tracker;

@end

@implementation AWXAnalyticsLogger

+ (instancetype)shared {
    static AWXAnalyticsLogger *sharedLogger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogger = [self new];
    });
    return sharedLogger;
}

- (instancetype)init {
    self = [super init];
    if (self && Airwallex.analyticsEnabled) {
        Config *config = [[Config alloc] initWithAppName:@"pa_mobile_sdk" appVersion:AIRWALLEX_VERSION environment:[self trackerEnvironment]];
        _tracker = [[Tracker alloc] initWithConfig:config];
        _tracker.extraCommonData = [self extraCommonData];
    }
    return self;
}

- (void)logWithEventName:(NSString *)eventName extraInfo:(NSDictionary<NSString *, id> *)extraInfo {
    [_tracker infoWithEventName:eventName extraInfo:extraInfo];
}

#pragma mark - Private methods

- (NSDictionary *)extraCommonData {
    NSMutableDictionary *data = [NSMutableDictionary new];
    NSString *merchantAppName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (merchantAppName.length > 0) {
        [data setObject:merchantAppName forKey:@"merchantAppName"];
    }

    NSString *merchantAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (merchantAppVersion.length > 0) {
        [data setObject:merchantAppVersion forKey:@"merchantAppVersion"];
    }

    NSString *accountId = [self accountIdFromClientSecret:nil];
    if (accountId != nil) {
        [data setObject:accountId forKey:@"accountId"];
    }

    return data;
}

- (NSString *)accountIdFromClientSecret:(NSString *)clientSecret {
    NSArray<NSString *> *splitedClientSecret = [clientSecret componentsSeparatedByString:@"."];
    NSString *encodedSecret;
    if (splitedClientSecret.count > 1) {
        encodedSecret = splitedClientSecret[1];
    }
    NSData *decodedData = [NSData initWithBase64NoPaddingString:encodedSecret];
    NSString *accountId;
    if (decodedData != nil) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:decodedData options:0 error:nil];
        accountId = [dict objectForKey:@"account_id"];
    }
    return accountId;
}

- (Environment)trackerEnvironment {
    switch (Airwallex.mode) {
    case AirwallexSDKDemoMode:
        return EnvironmentDemo;
    case AirwallexSDKStagingMode:
        return EnvironmentStaging;
    case AirwallexSDKProductionMode:
        return EnvironmentProd;
    }
}

@end
