//
//  AWXCard.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXCard.h"

@implementation AWXCard

- (NSDictionary *)encodeToJSON
{
    return @{
        @"number": self.number,
        @"expiry_month": self.expiryMonth,
        @"expiry_year": self.expiryYear,
        @"name": self.name ?: @"",
        @"cvc": self.cvc ?: @""
    };
}

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXCard *card = [AWXCard new];
    NSString *number = json[@"number"];
    NSString *last4 = json[@"last4"];
    if (number) {
        card.number = number;
    } else if (last4) {
        card.number = [NSString stringWithFormat:@"•••• %@", last4];
    }
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
    card.cvcCheck = json[@"cvc_check"];
    card.avsCheck = json[@"avs_check"];
    return card;
}

@end

@implementation AWXCard (Utils)

- (nullable NSString *)validate
{
    if (self.number.length == 0) {
        return @"Invalid card number";
    }
    if (self.name.length == 0) {
        return @"Invalid name on card";
    }
    if (self.expiryYear.length == 0 || self.expiryMonth.length == 0) {
        return @"Invalid expires date";
    }
    if (self.cvc.length == 0) {
        return @"Invalid CVC / VCC";
    }
    return nil;
}

@end
