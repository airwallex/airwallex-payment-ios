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
        @"exp_month": self.expMonth,
        @"exp_year": self.expYear,
        @"name": self.name ?: @"",
        @"cvc": self.cvc ?: @""
    };
}

+ (id)parseFromJsonDictionary:(NSDictionary *)json
{
    AWCard *card = [AWCard new];
    card.expYear = json[@"exp_year"];
    card.expMonth = json[@"exp_month"];
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
