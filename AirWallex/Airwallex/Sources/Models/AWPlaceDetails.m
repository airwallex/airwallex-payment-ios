//
//  AWPlaceDetails.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPlaceDetails.h"

@implementation AWPlaceDetails

- (NSDictionary *)encodeToJSON
{
    return @{
        @"first_name": self.firstName,
        @"last_name": self.lastName,
        @"email": self.email ?: @"",
        @"date_of_birth": self.dateOfBirth ?: @"",
        @"phone_number": self.phoneNumber ?: @"",
        @"address": self.address.encodeToJSON
    };
}

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWPlaceDetails *billing = [AWPlaceDetails new];
    billing.firstName = json[@"first_name"];
    billing.lastName = json[@"last_name"];
    billing.email = json[@"email"];
    billing.dateOfBirth = json[@"date_of_birth"];
    billing.phoneNumber = json[@"phone_number"];
    billing.address = [AWAddress decodeFromJSON:json[@"address"]];
    return billing;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    AWPlaceDetails *copy = [[AWPlaceDetails allocWithZone:zone] init];
    copy.address = [self.address copyWithZone:zone];
    copy.firstName = [self.firstName copyWithZone:zone];
    copy.lastName = [self.lastName copyWithZone:zone];
    copy.email = [self.email copyWithZone:zone];
    copy.phoneNumber = [self.phoneNumber copyWithZone:zone];
    copy.dateOfBirth = [self.dateOfBirth copyWithZone:zone];
    return copy;
}

@end

@implementation AWPlaceDetails (Utils)

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
    if (self.address.city.length == 0) {
        return @"Please enter your city";
    }
    if (self.address.street.length == 0) {
        return @"Please enter your street";
    }
    return nil;
}

@end
