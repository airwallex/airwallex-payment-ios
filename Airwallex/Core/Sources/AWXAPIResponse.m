//
//  AWXAPIResponse.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIResponse.h"
#import "AWXConstants.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@implementation AWXAPIErrorResponse

- (instancetype)initWithMessage:(NSString *)message
                           code:(NSString *)code {
    if (self = [super init]) {
        _message = [message copy];
        _code = [code copy];
    }
    return self;
}

- (NSError *)error {
    return [NSError errorForAirwallexSDKWith:self.code.intValue localizedDescription:self.message];
}

@end
