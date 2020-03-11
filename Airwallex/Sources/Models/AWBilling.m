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

@implementation AWBilling (Utils)

- (nullable NSString *)validate
{
    if (self.firstName.length == 0) {
        return @"Please enter your first name";
    }
    if (self.lastName.length == 0) {
        return @"Please enter your last name";
    }
    if (self.email.length > 0) {
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if (![emailTest evaluateWithObject:self.email]) {
            return @"Invalid email";
        }
    }
    if (!self.address) {
        return @"Please enter your shipping address";
    }
    if (self.address.countryCode.length == 0) {
        return @"Please choose your country/region";
    }
    if (self.address.state.length == 0) {
        return @"Please enter your state";
    }
    if (self.address.city.length == 0) {
        return @"Please enter your city";
    }
    return nil;
}

@end
