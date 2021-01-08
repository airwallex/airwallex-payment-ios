//
//  AWXNonCard.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/1/8.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWXNonCard.h"

@implementation AWXNonCard

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.flow = @"inapp";
        self.osType = @"ios";
    }
    return self;
}

- (NSDictionary *)encodeToJSON
{
    return @{@"flow": self.flow, @"os_type": self.osType};
}

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXNonCard *pay = [AWXNonCard new];
    pay.flow = json[@"flow"];
    pay.osType = json[@"os_type"];
    return pay;
}

@end
