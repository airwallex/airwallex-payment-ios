//
//  AWCard.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWCard.h"

@implementation AWCard

- (NSDictionary *)toJSONDictionary
{
    return @{
        @"number": self.number,
        @"expiry_month": self.expiryMonth,
        @"expiry_year": self.expiryYear,
        @"name": self.name ?: @"",
        @"cvc": self.cvc ?: @""
    };
}

+ (id)parseFromJsonDictionary:(NSDictionary *)json
{
    AWCard *card = [AWCard new];
    card.number = json[@"number"];
    card.cvc = json[@"cvc"];
    card.expiryYear = json[@"expiry_year"];
    card.expiryMonth = json[@"expiry_month"];
    card.name = json[@"name"];
    card.bin = json[@"bin"];
    card.last4 = json[@"last4"];
    card.brand = json[@"brand"];
    card.country = json[@"country"];
    card.funding = json[@"funding"];
    card.fingerprint = json[@"fingerprint"];
    return card;
}

@end
