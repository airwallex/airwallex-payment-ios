//
//  AWBilling+Utils.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWBilling+Utils.h"

@implementation AWBilling (Utils)

- (BOOL)isValid
{
    if (self.lastName.length > 0 && self.firstName.length > 0 && self.address != nil) {
        if (self.address.countryCode.length > 0 && self.address.state.length > 0 && self.address.city.length > 0 && self.address.street.length > 0) {
            return YES;
        }
    }
    return NO;
}

- (nullable NSString *)validate
{
    if (self.lastName.length == 0) {
        return @"Please enter your last name";
    }
    if (self.firstName.length == 0) {
        return @"Please enter your first name";
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
