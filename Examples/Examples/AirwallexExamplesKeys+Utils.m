//
//  AirwallexExamplesKeys+Utils.m
//  Examples
//
//  Created by Victor Zhu on 2020/4/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AirwallexExamplesKeys+Utils.h"

@implementation AirwallexExamplesKeys (Utils)

+ (instancetype)shared
{
    static AirwallexExamplesKeys *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = [self new];
    });
    return keys;
}

@end
