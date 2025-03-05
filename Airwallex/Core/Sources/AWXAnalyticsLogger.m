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
#import "AWXUIContext.h"
#import "NSData+Base64.h"
#import "NSObject+Logging.h"
#import <AirTracker/AirTracker-Swift.h>

@interface AWXAnalyticsLogger ()

@property (nonatomic, strong, readonly) Tracker *tracker;

@end

@interface NSMutableDictionary (extension)

- (void)addInfoFromPaymentSession;

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
    [self logPageViewWithName:pageName additionalInfo:@{}];
}

- (void)logPageViewWithName:(NSString *)pageName additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *extraInfo = additionalInfo.mutableCopy;
    extraInfo[@"eventType"] = @"page_view";
    [extraInfo addInfoFromPaymentSession];
    [_tracker infoWithEventName:pageName extraInfo:extraInfo];
    [self log:@"page_view: %@, extraInfo: %@", pageName, extraInfo];
}

- (void)logPaymentViewWithName:(NSString *)name {
    [self logPaymentViewWithName:name additionalInfo:@{}];
}

- (void)logPaymentViewWithName:(NSString *)name additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *extraInfo = additionalInfo.mutableCopy;
    extraInfo[@"eventType"] = @"payment_view";
    [extraInfo addInfoFromPaymentSession];
    [_tracker infoWithEventName:name extraInfo:extraInfo];
    [self log:@"payment_view: %@, extraInfo: %@", name, extraInfo];
}

- (void)logErrorWithName:(NSString *)eventName additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *extraInfo = additionalInfo.mutableCopy;
    [extraInfo addInfoFromPaymentSession];
    [_tracker errorWithEventName:eventName extraInfo:extraInfo];
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
    [extraInfo addInfoFromPaymentSession];
    [_tracker errorWithEventName:eventName extraInfo:extraInfo];
}

- (void)logError:(NSError *)error withEventName:(NSString *)eventName {
    NSMutableDictionary *extraInfo = @{@"code": [@(error.code) stringValue]}.mutableCopy;
    if (error.localizedDescription.length > 0) {
        extraInfo[@"message"] = error.localizedDescription;
    }
    [extraInfo addInfoFromPaymentSession];
    [_tracker errorWithEventName:eventName extraInfo:extraInfo];
}

- (void)logActionWithName:(NSString *)actionName {
    NSMutableDictionary *extraInfo = @{@"eventType": @"action"}.mutableCopy;
    [extraInfo addInfoFromPaymentSession];
    [_tracker infoWithEventName:actionName extraInfo:extraInfo];
    [NSObject log:@"action_name: %@, extraInfo: %@", actionName, extraInfo];
}

- (void)logActionWithName:(NSString *)actionName additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *extraInfo = additionalInfo.mutableCopy;
    extraInfo[@"eventType"] = @"action";
    [extraInfo addInfoFromPaymentSession];
    [_tracker infoWithEventName:actionName extraInfo:extraInfo];
    [NSObject log:@"action_name: %@, extraInfo: %@", actionName, extraInfo];
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

@implementation NSMutableDictionary (extension)

- (void)addInfoFromPaymentSession {
    if (AWXUIContext.sharedContext.session.paymentIntentId) {
        self[@"payment_intent_id"] = AWXUIContext.sharedContext.session.paymentIntentId;
    }
    if (AWXUIContext.sharedContext.session.transactionMode) {
        self[@"transaction_mode"] = AWXUIContext.sharedContext.session.transactionMode;
    }
}

@end
