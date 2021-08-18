//
//  AWXCountry.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXCountry` includes the information of a country.
 */
@interface AWXCountry : NSObject

/**
 Country code.
 */
@property (nonatomic, strong) NSString *countryCode;

/**
 Country name.
 */
@property (nonatomic, strong) NSString *countryName;

@end

@interface AWXCountry (Utils)

/**
 Return all of the supported countries.
 */
+ (NSArray <AWXCountry *> *)allCountries;

/**
 Get a matched country object.

 @param code Country code.
 @return A country object.
 */
+ (nullable AWXCountry *)countryWithCode:(NSString *)code;

@end

NS_ASSUME_NONNULL_END
