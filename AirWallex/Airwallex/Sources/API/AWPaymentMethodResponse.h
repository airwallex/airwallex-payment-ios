//
//  AWPaymentMethodResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/4.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWResponseProtocol.h"

@class AWPaymentMethod;

NS_ASSUME_NONNULL_BEGIN

/**
 `AWGetPaymentMethodsResponse` includes the list of payment methods.
 */
@interface AWGetPaymentMethodsResponse : NSObject <AWResponseProtocol>

/**
 Check whether there are more payment methods not loaded.
 */
@property (nonatomic, readonly) BOOL hasMore;

/**
 Payment methods.
 */
@property (nonatomic, readonly) NSArray <AWPaymentMethod *> *items;

@end

/**
 `AWCreatePaymentMethodResponse` includes the payment method created.
 */
@interface AWCreatePaymentMethodResponse : NSObject <AWResponseProtocol>

/**
 Payment method object.
 */
@property (nonatomic, readonly) AWPaymentMethod *paymentMethod;

@end

NS_ASSUME_NONNULL_END
