//
//  AWAPIClient.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWBlocks.h"

@class AWPaymentConfiguration;
@protocol AWRequestProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface AWAPIClient : NSObject

@property (nonatomic, copy) AWPaymentConfiguration *configuration;

- (void)send:(id <AWRequestProtocol>)request handler:(AWRequestHandler)handler;

@end

NS_ASSUME_NONNULL_END
