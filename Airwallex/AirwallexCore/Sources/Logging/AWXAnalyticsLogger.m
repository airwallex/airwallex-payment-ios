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
@property (nonatomic, strong, null_resettable) NSDictionary *sessionInfo;

@end

@interface NSMutableDictionary (extension)

+ (instancetype)dictionaryWithSession:(AWXSession *)session extraInfo:(NSDictionary *)info;

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

- (NSDictionary *)sessionInfo {
    if (!_sessionInfo) {
        return @{};
    } else {
        return _sessionInfo;
    }
}

- (void)logPageViewWithName:(NSString *)pageName {
    [self logPageViewWithName:pageName additionalInfo:@{}];
}

- (void)logPageViewWithName:(NSString *)pageName additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithSession:self.session extraInfo:self.sessionInfo];
    if ([additionalInfo isKindOfClass:[NSDictionary class]]) {
        [extraInfo setValuesForKeysWithDictionary:additionalInfo];
    }
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
    NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithSession:self.session extraInfo:self.sessionInfo];
    if ([additionalInfo isKindOfClass:[NSDictionary class]]) {
        [extraInfo setValuesForKeysWithDictionary:additionalInfo];
    }
    extraInfo[@"eventType"] = @"payment_method_view";
    [_tracker infoWithEventName:name extraInfo:extraInfo];
    if (self.verbose) {
        [self log:@"payment_view: %@, extraInfo: %@", name, extraInfo];
    }
}

- (void)logErrorWithName:(NSString *)eventName additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithSession:self.session extraInfo:self.sessionInfo];
    if ([additionalInfo isKindOfClass:[NSDictionary class]]) {
        [extraInfo setValuesForKeysWithDictionary:additionalInfo];
    }
    [_tracker errorWithEventName:eventName extraInfo:extraInfo];
}

- (void)logErrorWithName:(NSString *)eventName
                     url:(NSURL *)url
                response:(AWXAPIErrorResponse *)errorResponse
          additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithSession:self.session extraInfo:self.sessionInfo];
    if ([additionalInfo isKindOfClass:[NSDictionary class]]) {
        [extraInfo setValuesForKeysWithDictionary:additionalInfo];
    }
    extraInfo[@"eventType"] = @"pa_api_request";
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
    NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithSession:self.session extraInfo:self.sessionInfo];
    extraInfo[@"code"] = [@(error.code) stringValue];
    if (error.localizedDescription.length > 0) {
        extraInfo[@"message"] = error.localizedDescription;
    }
    [_tracker errorWithEventName:eventName extraInfo:extraInfo];
}

- (void)logActionWithName:(NSString *)actionName {
    [self logActionWithName:actionName additionalInfo:@{}];
}

- (void)logActionWithName:(NSString *)actionName additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithSession:self.session extraInfo:self.sessionInfo];
    if ([additionalInfo isKindOfClass:[NSDictionary class]]) {
        [extraInfo setValuesForKeysWithDictionary:additionalInfo];
    }
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
    data[@"framework"] = @"native";

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

+ (instancetype)dictionaryWithSession:(AWXSession *)session extraInfo:(NSDictionary *)info {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:info];
    if (session.paymentIntentId) {
        dictionary[@"paymentIntentId"] = session.paymentIntentId;
    }
    return dictionary;
}

@end
