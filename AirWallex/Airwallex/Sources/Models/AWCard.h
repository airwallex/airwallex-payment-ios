//
//  AWCard.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWCodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWCard` includes the information of a card.
 */
@interface AWCard : NSObject <AWJSONEncodable, AWJSONDecodable>

/**
 Card number.
 */
@property (nonatomic, copy) NSString *number;

/**
 Two digit number representing the card’s expiration month. Example: 12.
 */
@property (nonatomic, copy) NSString *expiryMonth;

/**
 Four digit number representing the card’s expiration year. Example: 2030.
 */
@property (nonatomic, copy) NSString *expiryYear;

/**
 Card holder name.
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 Card cvc.
 */
@property (nonatomic, copy, nullable) NSString *cvc;

/**
 Bank identify number of this card.
 */
@property (nonatomic, copy, nullable) NSString *bin;

/**
 Last four digits of the card number.
 */
@property (nonatomic, copy, nullable) NSString *last4;

/**
 Brand of the card.
 */
@property (nonatomic, copy, nullable) NSString *brand;

/**
 Country code of the card.
 */
@property (nonatomic, copy, nullable) NSString *country;

/**
 Funding type of the card.
 */
@property (nonatomic, copy, nullable) NSString *funding;

/**
 Fingerprint of the card.
 */
@property (nonatomic, copy, nullable) NSString *fingerprint;

/**
 Whether CVC pass the check.
 */
@property (nonatomic, copy, nullable) NSString *cvcCheck;

/**
 Whether address pass the check.
 */
@property (nonatomic, copy, nullable) NSString *avsCheck;

@end

NS_ASSUME_NONNULL_END
