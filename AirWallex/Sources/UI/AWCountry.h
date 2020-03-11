//
//  AWCountry.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWCountry : NSObject

@property (nonatomic, strong) NSString *countryCode, *countryName;

@end

@interface AWCountry (Utils)

+ (NSArray *)allCountries;
+ (nullable AWCountry *)countryWithCode:(NSString *)code;

@end

NS_ASSUME_NONNULL_END
