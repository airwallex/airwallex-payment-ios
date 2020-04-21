//
//  AWPaymentIntentRequest.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWRequestProtocol.h"

@class AWPaymentMethod;
@class AWPaymentMethodOptions;
@class AWDevice;

NS_ASSUME_NONNULL_BEGIN

/**
 `AWConfirmPaymentIntentRequest` includes all of the parameters needed to confirm payment intent.
 */
@interface AWConfirmPaymentIntentRequest : NSObject <AWRequestProtocol>

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
@property (nonatomic, strong) AWPaymentMethod *paymentMethod;

/**
 Options object.
 */
@property (nonatomic, strong, nullable) AWPaymentMethodOptions *options;

/**
 Device object.
 */
@property (nonatomic, strong, nullable) AWDevice *device;

@end

/**
 `AWRetrievePaymentIntentRequest` includes all of the parameters needed to get payment intent.
 */
@interface AWRetrievePaymentIntentRequest : NSObject <AWRequestProtocol>

/**
 Intent ID.
 */
@property (nonatomic, copy) NSString *intentId;

@end

NS_ASSUME_NONNULL_END
