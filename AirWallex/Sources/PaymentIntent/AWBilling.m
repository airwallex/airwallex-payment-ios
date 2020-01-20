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
        @"email": self.email ?: @"",
        @"first_name": self.firstName,
        @"last_name": self.lastName,
        @"phone_number": self.phoneNumber ?: @""
    };
}

@end
