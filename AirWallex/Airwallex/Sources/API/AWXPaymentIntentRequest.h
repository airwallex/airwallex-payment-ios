//
//  AWXPaymentIntentRequest.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXRequestProtocol.h"

@class AWXPaymentMethod;
@class AWXPaymentMethodOptions;
@class AWXDevice;

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXConfirmPaymentIntentRequest` includes all of the parameters needed to confirm payment intent.
 */
@interface AWXConfirmPaymentIntentRequest : NSObject <AWXRequestProtocol>

/**
 Intent ID.
 */
@property (nonatomic, copy) NSString *intentId;

/**
 Request ID.
 */
@property (nonatomic, copy) NSString *requestId;

/**
 Customer ID.
 */
@property (nonatomic, copy, nullable) NSString *customerId;

/**
 Save payment method.
 */
@property (nonatomic) BOOL savePaymentMethod;

/**
 Payment method object.
 */
@property (nonatomic, strong) AWXPaymentMethod *paymentMethod;

/**
 Options object.
 */
@property (nonatomic, strong, nullable) AWXPaymentMethodOptions *options;

/**
 Device object.
 */
@property (nonatomic, strong, nullable) AWXDevice *device;

@end

/**
 `AWXRetrievePaymentIntentRequest` includes all of the parameters needed to get payment intent.
 */
@interface AWXRetrievePaymentIntentRequest : NSObject <AWXRequestProtocol>

/**
 Intent ID.
 */
@property (nonatomic, copy) NSString *intentId;

@end

NS_ASSUME_NONNULL_END