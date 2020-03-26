//
//  AWAPIClient.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWPaymentConfiguration;
@protocol AWRequestProtocol, AWResponseProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef void (^AWRequestHandler)(id <AWResponseProtocol> _Nullable response, NSError * _Nullable error);

/**
 `AWAPIClient` is a http request client.
 */
@interface AWAPIClient : NSObject

/**
 The configuration required.
 */
@property (nonatomic, copy, readonly) AWPaymentConfiguration *configuration;

/**
 Initializer.
 
 @param configuration A configuration required.
 @return The initialized http request client.
 */
- (instancetype)initWithConfiguration:(AWPaymentConfiguration *)configuration;

/**
 Send request.
 
 @param request A request object.
 @param handler A handler which includes response.
 */
- (void)send:(id <AWRequestProtocol>)request handler:(AWRequestHandler)handler;

@end

NS_ASSUME_NONNULL_END
