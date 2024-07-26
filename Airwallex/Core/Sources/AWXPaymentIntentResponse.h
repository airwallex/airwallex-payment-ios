//
//  AWXPaymentintentResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "AWXCodable.h"

NS_ASSUME_NONNULL_BEGIN

@class AWXConfirmPaymentNextAction, AWXPaymentAttempt, AWXPaymentMethod;

/**
 `AWXGetPaymentIntentResponse` includes the information of payment intent.
 */
@interface AWXGetPaymentIntentResponse : AWXResponse

/**
 Intent id.
 */
@property (nonatomic, readonly) NSString *Id;

/**
 Request id.
 */
@property (nonatomic, readonly) NSString *requestId;

/**
 Payment amount.
 */
@property (nonatomic, readonly) NSDecimalNumber *amount;

/**
 Currency.
 */
@property (nonatomic, readonly) NSString *currency;

/**
 Merchant order id.
 */
@property (nonatomic, readonly) NSString *merchantOrderId;

/**
 Order data.
 */
@property (nonatomic, readonly) NSDictionary *order;

/**
 Customer id.
 */
@property (nonatomic, readonly) NSString *customerId;

/**
 Payment status.
 */
@property (nonatomic, readonly) NSString *status;

/**
 Captured amount.
 */
@property (nonatomic, readonly) NSDecimalNumber *capturedAmount;

/**
 Created date.
 */
@property (nonatomic, readonly) NSString *createdAt;

/**
 Updated date.
 */
@property (nonatomic, readonly) NSString *updatedAt;

/**
 Available payment method types.
 */
@property (nonatomic, readonly) NSArray<NSString *> *availablePaymentMethodTypes;

/**
 Client secret.
 */
@property (nonatomic, readonly) NSString *clientSecret;

@end

/**
 `AWXGetPaResResponse` includes the 3ds information of payment.
 */
@interface AWXGetPaResResponse : AWXResponse

/**
 PaRes
 */
@property (nonatomic, readonly) NSString *paRes;

@end

NS_ASSUME_NONNULL_END
