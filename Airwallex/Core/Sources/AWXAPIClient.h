//
//  AWXAPIClient.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXConstants.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `Airwallex` contains the base configuration the SDK needs.
 */
@interface Airwallex : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

/**
 Set base URL.

 @param baseURL A baseURL required.
 */
+ (void)setDefaultBaseURL:(NSURL *)baseURL;

/**
 Get base URL.
 */
+ (NSURL *)defaultBaseURL;

/**
 Set sdk mode.

 @param mode A mode required.
 */
+ (void)setMode:(AirwallexSDKMode)mode;

/**
 Get sdk mode. Test mode as default.
 */
+ (AirwallexSDKMode)mode;

/**
 Disable analytics.
 */
+ (void)disableAnalytics;

/**
 enable analytics.
 */
+ (void)enableAnalytics;

/**
 Get whether analytics is enabled, by default it's turned on.
 */
+ (BOOL)analyticsEnabled;

/**
 Enable local log file.
 */
+ (void)enableLocalLogFile;

/**
 Disable local log file.
 */
+ (void)disableLocalLogFile;

/**
 Get whether local Log file is enabled, by default it's turned off.
 */
+ (BOOL)isLocalLogFileEnabled;

@end

/**
 Http request
 */
typedef enum : NSUInteger {
    AWXHTTPMethodGET,
    AWXHTTPMethodPOST,
} AWXHTTPMethod;

@interface AWXRequest : NSObject

- (NSString *)path;
- (AWXHTTPMethod)method;
- (nullable NSDictionary *)parameters;
- (nullable NSData *)postData;
- (Class)responseClass;
- (NSDictionary *)headers;

@end

@interface AWXResponse : NSObject

+ (AWXResponse *)parse:(NSData *)data;
+ (nullable AWXResponse *)parseError:(NSData *)data;

@end

/**
 `AWXAPIClientConfiguration` contains the base configuration the API client needs.
 */
@interface AWXAPIClientConfiguration : NSObject<NSCopying>

/**
 The base URL.
 */
@property (nonatomic, copy) NSURL *baseURL;

/**
 The client secret for payment.
 */
@property (nonatomic, copy, nullable) NSString *clientSecret;

/**
 The account ID from client secret.
 */
@property (nonatomic, strong, nullable, readonly) NSString *accountID;

/**
 Convenience constructor for a configuration.

 @return The shared configuration.
 */
+ (instancetype)sharedConfiguration;

@end

typedef void (^AWXRequestHandler)(AWXResponse *_Nullable response, NSError *_Nullable error);

/**
 `AWXAPIClient` is a http request client.
 */
NS_SWIFT_NAME(AWXAPIClientOC)
@interface AWXAPIClient : NSObject

/**
 The configuration required.
 */
@property (nonatomic, copy, readonly) AWXAPIClientConfiguration *configuration;

/**
 Initializer.

 @param configuration A configuration required.
 @return The initialized http request client.
 */
- (instancetype)initWithConfiguration:(AWXAPIClientConfiguration *)configuration;

/**
 Send request.

 @param request A request object.
 @param handler A handler which includes response.
 */
- (void)send:(AWXRequest *)request handler:(AWXRequestHandler)handler;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
