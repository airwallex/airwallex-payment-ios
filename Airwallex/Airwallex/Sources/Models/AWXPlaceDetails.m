//
//  AWXPlaceDetails.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPlaceDetails.h"

@implementation AWXPlaceDetails

- (NSDictionary *)encodeToJSON
{
    NSMutableDictionary *json = [@{
        @"first_name": self.firstName,
        @"last_name": self.lastName,
        @"date_of_birth": self.dateOfBirth ?: @"",
        @"address": self.address.encodeToJSON} mutableCopy];
    if (self.email && self.email.length > 0) {
        json[@"email"] = self.email;
    }
    if (self.phoneNumber && self.phoneNumber.length > 0) {
        json[@"phone_number"] = self.phoneNumber;
    }
    return json;
}

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXPlaceDetails *billing = [AWXPlaceDetails new];
    billing.firstName = json[@"first_name"];
    billing.lastName = json[@"last_name"];
    billing.email = json[@"email"];
    billing.dateOfBirth = json[@"date_of_birth"];
    billing.phoneNumber = json[@"phone_number"];
    billing.address = [AWXAddress decodeFromJSON:json[@"address"]];
    return billing;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    AWXPlaceDetails *copy = [[AWXPlaceDetails allocWithZone:zone] init];
    copy.address = [self.address copyWithZone:zone];
    copy.firstName = [self.firstName copyWithZone:zone];
    copy.lastName = [self.lastName copyWithZone:zone];
    copy.email = [self.email copyWithZone:zone];
    copy.phoneNumber = [self.phoneNumber copyWithZone:zone];
    copy.dateOfBirth = [self.dateOfBirth copyWithZone:zone];
    return copy;
}

@end

@implementation AWXPlaceDetails (Utils)

- (nullable NSString *)validate
{
    if (self.firstName.length == 0) {
        return @"Please enter your first name";
    }
    if (self.lastName.length == 0) {
        return @"Please enter your last name";
    }
    if (self.phoneNumber.length == 0) {
        return @"Please enter your Phone Number";
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
