//
//  AWXAddress.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXCodable.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXAddress` includes the information of an address.
 */
@interface AWXAddress : NSObject<AWXJSONEncodable, AWXJSONDecodable, NSCopying>

/**
 Country code of the address. Use the two-character ISO Standard Country Codes.
 */
@property (nonatomic, copy) NSString *countryCode;

/**
 City of the address.
 */
@property (nonatomic, copy) NSString *city;

/**
 Street of the address.
 */
@property (nonatomic, copy) NSString *street;

/**
 State or province of the address, optional.
 */
@property (nonatomic, copy, nullable) NSString *state;

/**
 Postcode of the address, optional.
 */
@property (nonatomic, copy, nullable) NSString *postcode;

@end

NS_ASSUME_NONNULL_END
