//
//  AWXCardScheme.m
//  Core
//
//  Created by Hector.Huang on 2022/11/9.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXCardScheme.h"

@implementation AWXCardScheme

+ (id)decodeFromJSON:(NSDictionary *)json {
    AWXCardScheme *cardScheme = [AWXCardScheme new];
    cardScheme.name = json[@"name"];
    return cardScheme;
}

@end
