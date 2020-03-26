//
//  AWCard.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWJSONifiable.h"
#import "AWParseable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWCard` includes the information of a card.
 */
@interface AWCard : NSObject <AWJSONifiable, AWParseable>

/**
 Card number.
 */
@property (nonatomic, copy) NSString *number;

/**
 Card expiry month.
 */
@property (nonatomic, copy) NSString *expiryMonth;

/**
 Card expiry year.
 */
@property (nonatomic, copy) NSString *expiryYear;

/**
 The name on card.
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 Card cvc.
 */
@property (nonatomic, copy, nullable) NSString *cvc;

/**
 Bin.
 */
@property (nonatomic, copy, nullable) NSString *bin;

/**
 Last 4 card numbers.
 */
@property (nonatomic, copy, nullable) NSString *last4;

/**
 Card brand.
 */
@property (nonatomic, copy, nullable) NSString *brand;

/**
 Country code.
 */
@property (nonatomic, copy, nullable) NSString *country;

/**
 Funding.
 */
@property (nonatomic, copy, nullable) NSString *funding;

/**
 Fingerprint
 */
@property (nonatomic, copy, nullable) NSString *fingerprint;

@end

NS_ASSUME_NONNULL_END
