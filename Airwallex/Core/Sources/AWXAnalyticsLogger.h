//
//  AWXAnalyticsLogger.h
//  Core
//
//  Created by Hector.Huang on 2023/3/14.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWXAPIErrorResponse;

NS_ASSUME_NONNULL_BEGIN

@interface AWXAnalyticsLogger : NSObject

/// Defaults to `false`, will print all events to console if set to true
@property (nonatomic, assign) BOOL verbose;

+ (instancetype)shared;

- (void)logPageViewWithName:(NSString *)pageName;

- (void)logPageViewWithName:(NSString *)pageName additionalInfo:(NSDictionary<NSString *, id> *_Nullable)additionalInfo;

- (void)logPaymentViewWithName:(NSString *)name;

- (void)logPaymentViewWithName:(NSString *)name additionalInfo:(NSDictionary<NSString *, id> *_Nullable)additionalInfo;

- (void)logErrorWithName:(NSString *)eventName additionalInfo:(NSDictionary<NSString *, id> *_Nullable)additionalInfo;

- (void)logErrorWithName:(NSString *)eventName url:(NSURL *)url response:(AWXAPIErrorResponse *)errorResponse;

- (void)logError:(NSError *)error withEventName:(NSString *)eventName;

- (void)logActionWithName:(NSString *)actionName;

- (void)logActionWithName:(NSString *)actionName additionalInfo:(NSDictionary<NSString *, id> *_Nullable)additionalInfo;

@end

NS_ASSUME_NONNULL_END
