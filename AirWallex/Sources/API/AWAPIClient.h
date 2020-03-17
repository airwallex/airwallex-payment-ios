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

@interface AWAPIClient : NSObject

@property (nonatomic, copy, readonly) AWPaymentConfiguration *configuration;

- (instancetype)initWithConfiguration:(AWPaymentConfiguration *)configuration;

- (void)send:(id <AWRequestProtocol>)request handler:(AWRequestHandler)handler;

@end

NS_ASSUME_NONNULL_END
