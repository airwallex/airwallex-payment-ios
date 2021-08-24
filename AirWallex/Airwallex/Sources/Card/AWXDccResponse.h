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

@property (nonatomic, readonly) NSString *currency;
@property (nonatomic, readonly) NSString *currencyPair;
@property (nonatomic, readonly) NSDecimalNumber *amount;
@property (nonatomic, readonly) NSString *amountString;
@property (nonatomic, readonly) NSDecimalNumber *clientRate;
@property (nonatomic, readonly) NSString *clientRateString;
@property (nonatomic, readonly) NSString *rateTimestamp, *rateExpiry;

@end

NS_ASSUME_NONNULL_END
