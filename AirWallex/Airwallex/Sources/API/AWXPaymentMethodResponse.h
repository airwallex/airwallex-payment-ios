//
//  AWXPaymentMethodResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/4.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXResponseProtocol.h"

@class AWXPaymentMethod,AWXPaymentMethodType;

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXGetPaymentMethodsResponse` includes the list of payment methods.
 */
@interface AWXGetPaymentMethodsResponse : NSObject <AWXResponseProtocol>

/**
 Check whether there are more payment methods not loaded.
 */
@property (nonatomic, readonly) BOOL hasMore;

/**
 Payment methods.
 */
@property (nonatomic, readonly) NSArray <AWXPaymentMethod *> *items;

@end

/**
 `AWXGetPaymentMethodTypesResponse` includes the list of payment methods.
 */
@interface AWXGetPaymentMethodTypeResponse : NSObject <AWXResponseProtocol>

/**
 Check whether there are more payment methods not loaded.
 */
@property (nonatomic, readonly) BOOL hasMore;

/**
 Payment methods.
 */
@property (nonatomic, readonly) NSArray <AWXPaymentMethodType *> *items;

@end

/**
 `AWXCreatePaymentMethodResponse` includes the payment method created.
 */
@interface AWXCreatePaymentMethodResponse : NSObject <AWXResponseProtocol>

/**
 Payment method object.
 */
@property (nonatomic, readonly) AWXPaymentMethod *paymentMethod;

@end

/**
 `AWXDisablePaymentMethodResponse` includes the payment method disabled.
 */
@interface AWXDisablePaymentMethodResponse : NSObject <AWXResponseProtocol>

/**
 Payment method object.
 */
@property (nonatomic, readonly) AWXPaymentMethod *paymentMethod;

@end

NS_ASSUME_NONNULL_END
