//
//  AWXAPIResponse.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIResponse.h"
#import "AWXConstants.h"

@implementation AWXAPIErrorResponse

- (instancetype)initWithMessage:(NSString *)message
                           code:(NSString *)code
{
    if (self = [super init]) {
        _message = [message copy];
        _code = [code copy];
    }
    return self;
}

- (NSError *)error
{
    return [NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: self.message, NSLocalizedFailureReasonErrorKey: self.code}];
}

@end
