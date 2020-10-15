//
//  AWXPaymentIntent.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/31.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXPaymentIntent` includes the information of payment intent.
 */
@interface AWXPaymentIntent : NSObject <AWXJSONDecodable>

/**
 Unique identifier for the payment intent.
 */
@property (nonatomic, copy) NSString *Id;

/**
 Payment amount. This is the order amount you would like to charge your customer.
 */
@property (nonatomic, copy) NSDecimalNumber *amount;

/**
 Amount currency.
 */
@property (nonatomic, copy) NSString *currency;

/**
 Payment intent status. REQUIRES_PAYMENT_METHOD, REQUIRES_CUSTOMER_ACTION, REQUIRES_MERCHANT_ACTION, SUCCEEDED, CANCELLED
 */
@property (nonatomic, copy) NSString *status;

/**
 Available payment method types.
 */
@property (nonatomic, copy) NSArray <NSString *> *availablePaymentMethodTypes;

/**
 Client secret for browser or app.
 */
@property (nonatomic, copy) NSString *clientSecret;

/**
 The customer who is paying for this payment intent.
 */
@property (nonatomic, copy, nullable) NSString *customerId;

@end

NS_ASSUME_NONNULL_END
