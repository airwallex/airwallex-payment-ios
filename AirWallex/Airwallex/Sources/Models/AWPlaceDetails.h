//
//  AWPlaceDetails.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWCodable.h"
#import "AWAddress.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWPlaceDetails` includes the information of a billing address.
 */
@interface AWPlaceDetails : NSObject <AWJSONEncodable, AWJSONDecodable, NSCopying>

/**
 First name of the customer.
 */
@property (nonatomic, copy) NSString *firstName;

/**
 Last name of the customer.
 */
@property (nonatomic, copy) NSString *lastName;

/**
 Email address of the customer, optional.
 */
@property (nonatomic, copy, nullable) NSString *email;

/**
 Date of birth of the customer in the format: YYYY-MM-DD, optional.
 */
@property (nonatomic, copy, nullable) NSString *dateOfBirth;

/**
 Phone number of the customer, optional.
 */
@property (nonatomic, copy, nullable) NSString *phoneNumber;

/**
 Address object.
 */
@property (nonatomic, copy) AWAddress *address;

@end

@interface AWPlaceDetails (Utils)

- (nullable NSString *)validate;

@end

NS_ASSUME_NONNULL_END
