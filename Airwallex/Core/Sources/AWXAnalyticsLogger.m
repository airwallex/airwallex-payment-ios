//
//  AWXAnalyticsLogger.m
//  Core
//
//  Created by Hector.Huang on 2023/3/14.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXAnalyticsLogger.h"
#import "AWXAPIClient.h"
#import "AWXAPIResponse.h"
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

- (void)logPageViewWithName:(NSString *)pageName {
    [_tracker infoWithEventName:pageName extraInfo:@{@"eventType": @"page_view"}];
}

- (void)logPageViewWithName:(NSString *)pageName additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *extraInfo = additionalInfo.mutableCopy;
    extraInfo[@"eventType"] = @"page_view";
    [_tracker infoWithEventName:pageName extraInfo:extraInfo];
}

- (void)logErrorWithName:(NSString *)eventName additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    [_tracker errorWithEventName:eventName extraInfo:additionalInfo];
}

- (void)logErrorWithName:(NSString *)eventName url:(NSURL *)url response:(AWXAPIErrorResponse *)errorResponse {
    NSMutableDictionary *extraInfo = @{@"eventType": @"pa_api_request"}.mutableCopy;
    if (url.absoluteString.length > 0) {
        extraInfo[@"url"] = url.absoluteString;
    }
    if (errorResponse.code.length > 0) {
        extraInfo[@"code"] = errorResponse.code;
    }
    if (errorResponse.message.length > 0) {
        extraInfo[@"message"] = errorResponse.message;
    }
    [_tracker errorWithEventName:eventName extraInfo:extraInfo];
}

- (void)logError:(NSError *)error withEventName:(NSString *)eventName {
    NSMutableDictionary *extraInfo = @{@"code": [@(error.code) stringValue]}.mutableCopy;
    if (error.localizedDescription.length > 0) {
        extraInfo[@"message"] = error.localizedDescription;
    }
    [_tracker errorWithEventName:eventName extraInfo:extraInfo];
}

- (void)logActionWithName:(NSString *)actionName {
    [_tracker infoWithEventName:actionName extraInfo:@{@"eventType": @"action"}];
}

- (void)logActionWithName:(NSString *)actionName additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *extraInfo = additionalInfo.mutableCopy;
    extraInfo[@"eventType"] = @"action";
    [_tracker infoWithEventName:actionName extraInfo:extraInfo];
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

    NSString *accountId = [AWXAPIClientConfiguration sharedConfiguration].accountID;
    if (accountId != nil) {
        [data setObject:accountId forKey:@"accountId"];
    }

    return data;
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
