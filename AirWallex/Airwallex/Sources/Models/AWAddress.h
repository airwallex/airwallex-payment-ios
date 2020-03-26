//
//  AWAddress.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWJSONifiable.h"
#import "AWParseable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWAddress` includes the information of an address.
 */
@interface AWAddress : NSObject <AWJSONifiable, AWParseable, NSCopying>

/**
 Country code.
 */
@property (nonatomic, copy) NSString *countryCode;

/**
 City.
 */
@property (nonatomic, copy) NSString *city;

/**
 Street.
 */
@property (nonatomic, copy) NSString *street;

/**
 State, optional.
 */
@property (nonatomic, copy, nullable) NSString *state;

/**
 Post code, optional.
 */
@property (nonatomic, copy, nullable) NSString *postcode;

@end

NS_ASSUME_NONNULL_END
