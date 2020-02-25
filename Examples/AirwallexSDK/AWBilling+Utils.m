//
//  AWBilling+Utils.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWBilling+Utils.h"

@implementation AWBilling (Utils)

- (nullable NSString *)validate
{
    if (self.firstName.length == 0) {
        return @"Please enter your first name";
    }
    if (self.lastName.length == 0) {
        return @"Please enter your last name";
    }
    if (self.email.length == 0) {
        return @"Please enter your email";
    } else {
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
