//
//  AWAddress.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWAddress.h"

@implementation AWAddress

- (NSDictionary *)toJSONDictionary
{
    return @{
        @"country_code": self.countryCode,
        @"state": self.state ?: @"",
        @"city": self.city,
        @"street": self.street,
        @"postcode": self.postcode ?: @""
    };
}

+ (id)parseFromJsonDictionary:(NSDictionary *)json
{
    AWAddress *address = [AWAddress new];
    address.countryCode = json[@"country_code"];
    address.state = json[@"state"];
    address.city = json[@"city"];
    address.street = json[@"street"];
    address.postcode = json[@"postcode"];
    return address;
}

@end
