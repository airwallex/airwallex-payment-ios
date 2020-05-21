//
//  AWAPIClient.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AWRequestProtocol, AWResponseProtocol;

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

@end

@interface AWAPIClientConfiguration : NSObject <NSCopying>

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

typedef void (^AWRequestHandler)(id <AWResponseProtocol> _Nullable response, NSError * _Nullable error);

/**
 `AWAPIClient` is a http request client.
 */
@interface AWAPIClient : NSObject

/**
 Convenience constructor for an api client.
 
 @return The shared api client.
 */
+ (instancetype)sharedClient;

/**
 The configuration required.
 */
@property (nonatomic, copy, readonly) AWAPIClientConfiguration *configuration;

/**
 Initializer.
 
 @param configuration A configuration required.
 @return The initialized http request client.
 */
- (instancetype)initWithConfiguration:(AWAPIClientConfiguration *)configuration;

/**
 Send request.
 
 @param request A request object.
 @param handler A handler which includes response.
 */
- (void)send:(id <AWRequestProtocol>)request handler:(AWRequestHandler)handler;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
