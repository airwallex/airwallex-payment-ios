//
//  AWPaymentIntent.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/31.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWParseable.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWPaymentIntent : NSObject <AWParseable>

/**
 Payment intent ID.
 */
@property (nonatomic, copy) NSString *Id;

/**
 Amount.
 */
@property (nonatomic, copy) NSDecimalNumber *amount;

/**
 Currency.
 */
@property (nonatomic, copy) NSString *currency;

/**
 Payment intent status.
 */
@property (nonatomic, copy) NSString *status;

/**
 Available payment method types
 */
@property (nonatomic, copy) NSArray <NSString *> *availablePaymentMethodTypes;

/**
 Client secret.
 */
@property (nonatomic, copy) NSString *clientSecret;

/**
 Customer ID.
 */
@property (nonatomic, copy) NSString *customerId;

@end

NS_ASSUME_NONNULL_END
