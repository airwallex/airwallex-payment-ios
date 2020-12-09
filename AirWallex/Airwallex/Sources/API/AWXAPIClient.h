//
//  AWXAPIClient.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXConstants.h"

@protocol AWXRequestProtocol, AWXResponseProtocol;

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
 Set term URL.
 
 @param cybsURL A cybs URL.
 */
+ (void)setCybsURL:(NSString *)cybsURL;

/**
 Get term URL.
 */
+ (NSString *)cybsURL;

/**
 Set sdk mode.

 @param mode A mode required.
 */
+ (void)setMode:(AirwallexSDKMode)mode;

/**
 Get sdk mode. Test mode as default.
 */
+ (AirwallexSDKMode)mode;

@end

@interface AWXAPIClientConfiguration : NSObject <NSCopying>

/**
 The base URL.
 */
@property (nonatomic, copy) NSURL *baseURL;

/**
 The client secret for payment.
 */
@property (nonatomic, copy) NSString *clientSecret;

/**
 Convenience constructor for a configuration.
 
 @return The shared configuration.
 */
+ (instancetype)sharedConfiguration;

@end

@interface AWXCustomerAPIClientConfiguration : AWXAPIClientConfiguration

@end

typedef void (^AWXRequestHandler)(id <AWXResponseProtocol> _Nullable response, NSError * _Nullable error);

/**
 `AWXAPIClient` is a http request client.
 */
@interface AWXAPIClient : NSObject

/**
 Convenience constructor for an api client.
 
 @return The shared api client.
 */
+ (instancetype)sharedClient;

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
- (void)send:(id <AWXRequestProtocol>)request handler:(AWXRequestHandler)handler;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
