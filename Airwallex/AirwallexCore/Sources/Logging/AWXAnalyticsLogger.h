//
//  AWXAnalyticsLogger.h
//  Core
//
//  Created by Hector.Huang on 2023/3/14.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWXAPIErrorResponse, AWXSession;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(AnalyticsLogger)
@interface AWXAnalyticsLogger : NSObject

/// Defaults to `false`, will print all events to console if set to true
@property (nonatomic, assign) BOOL verbose;
@property (nonatomic, strong) AWXSession *session;

+ (instancetype)shared;

- (void)logPageViewWithName:(NSString *)pageName;

- (void)logPageViewWithName:(NSString *)pageName additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo;

- (void)logPaymentMethodViewWithName:(NSString *)name;

- (void)logPaymentMethodViewWithName:(NSString *)name additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo;

- (void)logErrorWithName:(NSString *)eventName additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo;

- (void)logErrorWithName:(NSString *)eventName url:(NSURL *)url response:(AWXAPIErrorResponse *)errorResponse;

- (void)logError:(NSError *)error withEventName:(NSString *)eventName;

- (void)logActionWithName:(NSString *)actionName;

- (void)logActionWithName:(NSString *)actionName additionalInfo:(NSDictionary<NSString *, id> *)additionalInfo;

@end

NS_ASSUME_NONNULL_END
