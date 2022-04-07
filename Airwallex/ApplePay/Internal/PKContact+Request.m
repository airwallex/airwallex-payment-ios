//
//  PKContact+Request.m
//  ApplePay
//
//  Created by Jin Wang on 13/4/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "PKContact+Request.h"

@implementation PKContact (Request)

- (NSDictionary *)payloadForRequest
{
    NSMutableDictionary *billing = [NSMutableDictionary dictionary];
    
    if (self.name) {
        billing[@"first_name"] = self.name.givenName;
        billing[@"last_name"] = self.name.familyName;
    }
    
    billing[@"email"] = self.emailAddress;
    
    if (self.phoneNumber) {
        billing[@"phone_number"] = self.phoneNumber.stringValue;
    }
    
    CNPostalAddress *postalAddress = self.postalAddress;
    
    if (postalAddress) {
        billing[@"address"] = @{
            @"city": postalAddress.city,
            @"country_code": postalAddress.ISOCountryCode,
            @"postcode": postalAddress.postalCode,
            @"state": postalAddress.state,
            @"street": postalAddress.street
        };
    }
    
    return billing;
}

@end
