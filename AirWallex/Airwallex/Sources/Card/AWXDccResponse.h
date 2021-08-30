//
//  AWXDccResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXDccResponse` includes the parameters for dcc.
 */
@interface AWXDccResponse : NSObject <AWXJSONDecodable>

/**
 Currency code.
 */
@property (nonatomic, readonly) NSString *currency;

/**
 Currency pair.
 */
@property (nonatomic, readonly) NSString *currencyPair;

/**
 The total amount.
 */
@property (nonatomic, readonly) NSDecimalNumber *amount;

/**
 The amount string.
 */
@property (nonatomic, readonly) NSString *amountString;

/**
 The rate.
 */
@property (nonatomic, readonly) NSDecimalNumber *clientRate;

/**
 The rate string.
 */
@property (nonatomic, readonly) NSString *clientRateString;

/**
 The currency rate expired date.
 */
@property (nonatomic, readonly) NSString *rateTimestamp, *rateExpiry;

@end

NS_ASSUME_NONNULL_END
