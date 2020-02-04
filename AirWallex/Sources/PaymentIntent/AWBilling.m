//
//  AWBilling.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWBilling.h"

@implementation AWBilling

- (NSDictionary *)toJSONDictionary
{
    return @{
        @"address": self.address.toJSONDictionary,
        @"date_of_birth": self.dateOfBirth ?: @"",
        @"email": self.email,
        @"first_name": self.firstName,
        @"last_name": self.lastName,
        @"phone_number": self.phoneNumber ?: @""
    };
}

+ (id)parseFromJsonDictionary:(NSDictionary *)json
{
    AWBilling *billing = [AWBilling new];
    billing.address = [AWAddress parseFromJsonDictionary:json[@"address"]];
    billing.firstName = json[@"first_name"];
    billing.lastName = json[@"last_name"];
    billing.email = json[@"email"];
    billing.phoneNumber = json[@"phone_number"];
    billing.dateOfBirth = json[@"date_of_birth"];
    return billing;
}

@end
