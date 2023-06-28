//
//  AWXAddress.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAddress.h"

@implementation AWXAddress

- (instancetype)initWithStreet:(NSString *)street
                          city:(NSString *)city
                         state:(NSString *)state
                      postcode:(NSString *)postcode
                   countryCode:(NSString *)countryCode {
    if (self = [super init]) {
        self.street = street;
        self.city = city;
        self.state = state;
        self.postcode = postcode;
        self.countryCode = countryCode;
    }
    return self;
}

- (NSDictionary *)encodeToJSON {
    return @{
        @"country_code": self.countryCode,
        @"city": self.city,
        @"street": self.street,
        @"state": self.state ?: @"",
        @"postcode": self.postcode ?: @""
    };
}

+ (id)decodeFromJSON:(NSDictionary *)json {
    AWXAddress *address = [AWXAddress new];
    address.countryCode = json[@"country_code"];
    address.city = json[@"city"];
    address.street = json[@"street"];
    address.state = json[@"state"];
    address.postcode = json[@"postcode"];
    return address;
}

+ (instancetype)decodeFromJSONData:(NSData *)data {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return [[self class] decodeFromJSON:json];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    AWXAddress *copy = [[AWXAddress allocWithZone:zone] init];
    copy.countryCode = [self.countryCode copyWithZone:zone];
    copy.city = [self.city copyWithZone:zone];
    copy.street = [self.street copyWithZone:zone];
    copy.state = [self.state copyWithZone:zone];
    copy.postcode = [self.postcode copyWithZone:zone];
    return copy;
}

@end
