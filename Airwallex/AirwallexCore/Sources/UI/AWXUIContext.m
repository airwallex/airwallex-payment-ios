//
//  AWXUIContext.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/9.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXUIContext.h"
#import "AWXPaymentIntent.h"
#import "AWXPlaceDetails.h"
#import "AWXUtils.h"

@implementation AWXUIContext

+ (instancetype)sharedContext {
    static AWXUIContext *sharedContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedContext = [self new];
    });
    return sharedContext;
}

+ (void)initialize {
    if (self == [AWXUIContext class]) {
        [[NSUserDefaults awxUserDefaults] reset];
    }
}

@end
