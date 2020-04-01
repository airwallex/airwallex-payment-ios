//
//  AWCountry.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWCountry.h"

@implementation AWCountry

@end

@implementation AWCountry (Utils)

+ (NSArray <AWCountry *> *)allCountries
{
    NSLocale *locale = [NSLocale currentLocale];
    NSArray *isoCountryCodes = [NSLocale ISOCountryCodes];
    NSMutableArray *countries = [[NSMutableArray alloc] init];
    for (NSString *countryCode in isoCountryCodes) {
        NSString *countryName = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
        AWCountry *country = [AWCountry new];
        country.countryCode = countryCode;
        country.countryName = countryName;
        [countries addObject:country];
    }
    [countries sortUsingComparator:^NSComparisonResult(AWCountry * _Nonnull obj1, AWCountry * _Nonnull obj2) {
        return [obj1.countryName localizedCompare:obj2.countryName];
    }];
    return countries;
}

+ (nullable AWCountry *)countryWithCode:(NSString *)code
{
    NSArray *filtered = [[self allCountries] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"countryCode == %@", code]];
    return filtered.firstObject;
}

@end
