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
#import "AWXSession.h"
#import "NSData+Base64.h"
#import "NSObject+Logging.h"
#import <AirTracker/AirTracker-Swift.h>

@interface AWXAnalyticsLogger ()

@property (nonatomic, strong, readonly) Tracker *tracker;

@property (nonatomic, strong, nullable) AWXSession *session;
@property (nonatomic, strong, nullable) NSDictionary *sessionInfo;

@end

@interface NSMutableDictionary (extension)

- (void)addInfoFromPaymentSession:(AWXSession *)session additionalInfo:(NSDictionary *)info;

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
    [extraInfo addInfoFromPaymentSession:self.session additionalInfo:self.sessionInfo];
    extraInfo[@"eventType"] = @"page_view";
    [_tracker infoWithEventName:pageName extraInfo:extraInfo];
    if (self.verbose) {
        [self log:@"page_view: %@, extraInfo: %@", pageName, extraInfo];
    }
}

- (void)logPaymentMethodViewWithName:(NSString *)name {
    [self logPaymentMethodViewWithName:name additionalInfo:@{}];
}

- (void)logPaymentMethodViewWithName:(NSString *)name additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *extraInfo = additionalInfo.mutableCopy;
    [extraInfo addInfoFromPaymentSession:self.session additionalInfo:self.sessionInfo];
    extraInfo[@"eventType"] = @"payment_method_view";
    [_tracker infoWithEventName:name extraInfo:extraInfo];
    if (self.verbose) {
        [self log:@"payment_view: %@, extraInfo: %@", name, extraInfo];
    }
}

- (void)logErrorWithName:(NSString *)eventName additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *extraInfo = additionalInfo.mutableCopy;
    [extraInfo addInfoFromPaymentSession:self.session additionalInfo:self.sessionInfo];
    [_tracker errorWithEventName:eventName extraInfo:extraInfo];
}

- (void)logErrorWithName:(NSString *)eventName
                     url:(NSURL *)url
                response:(AWXAPIErrorResponse *)errorResponse
          additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *extraInfo = @{@"eventType": @"pa_api_request"}.mutableCopy;
    [extraInfo addInfoFromPaymentSession:self.session additionalInfo:self.sessionInfo];
    if (url.absoluteString.length > 0) {
        extraInfo[@"url"] = url.absoluteString;
    }
    if (errorResponse.code.length > 0) {
        extraInfo[@"code"] = errorResponse.code;
    }
    if (errorResponse.message.length > 0) {
        extraInfo[@"message"] = errorResponse.message;
    }
    if (additionalInfo) {
        for (NSString *key in additionalInfo) {
            extraInfo[key] = additionalInfo[key];
        }
    }
    [_tracker errorWithEventName:eventName extraInfo:extraInfo];
}

- (void)logError:(NSError *)error withEventName:(NSString *)eventName {
    NSMutableDictionary *extraInfo = @{@"code": [@(error.code) stringValue]}.mutableCopy;
    [extraInfo addInfoFromPaymentSession:self.session additionalInfo:self.sessionInfo];
    if (error.localizedDescription.length > 0) {
        extraInfo[@"message"] = error.localizedDescription;
    }
    [_tracker errorWithEventName:eventName extraInfo:extraInfo];
}

- (void)logActionWithName:(NSString *)actionName {
    NSMutableDictionary *extraInfo = @{@"eventType": @"action"}.mutableCopy;
    [extraInfo addInfoFromPaymentSession:self.session additionalInfo:self.sessionInfo];
    [_tracker infoWithEventName:actionName extraInfo:extraInfo];
    if (self.verbose) {
        [self log:@"action_name: %@, extraInfo: %@", actionName, extraInfo];
    }
}

- (void)logActionWithName:(NSString *)actionName additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *extraInfo = additionalInfo.mutableCopy;
    [extraInfo addInfoFromPaymentSession:self.session additionalInfo:self.sessionInfo];
    extraInfo[@"eventType"] = @"action";
    [_tracker infoWithEventName:actionName extraInfo:extraInfo];
    if (self.verbose) {
        [self log:@"action_name: %@, extraInfo: %@", actionName, extraInfo];
    }
}

- (void)bindSession:(AWXSession *)session additionalInfo:(NSDictionary<NSString *, id> *)info {
    self.session = session;
    self.sessionInfo = info;
}

- (void)bindExtraCommonData:(NSDictionary<NSString *, id> *)extraCommonData {
    NSMutableDictionary *info = [self.tracker.extraCommonData mutableCopy];
    for (NSString *key in extraCommonData) {
        info[key] = extraCommonData[key];
    }
    self.tracker.extraCommonData = info;
}

#pragma mark - Private methods

- (NSDictionary *)extraCommonData {
    NSMutableDictionary *data = [NSMutableDictionary new];
    NSString *merchantAppName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
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
    data[@"integrationType"] = @"ios";

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

- (void)addInfoFromPaymentSession:(AWXSession *)session additionalInfo:(NSDictionary *)info {
    if (session.paymentIntentId) {
        // payment intent id needs to be dynamically retrieved because of express checkout
        self[@"paymentIntentId"] = session.paymentIntentId;
    }
    for (NSString *key in info) {
        self[key] = info[key];
    }
}

@end
