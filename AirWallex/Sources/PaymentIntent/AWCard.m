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

@end
