//
//  AWAPIResponse.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWAPIResponse.h"

@implementation AWAPIErrorResponse

- (instancetype)initWithMessage:(NSString *)message
                           code:(NSString *)code
                           type:(NSString *)type
                     statusCode:(NSNumber *)statusCode
{
    if (self = [super init]) {
        _message = [message copy];
        _code = [code copy];
        _type = [type copy];
        _statusCode = [statusCode copy];
    }
    return self;
}

- (NSDictionary *)dictionary
{
    return @{
             @"message": self.message,
             @"code": self.code,
             @"type": self.type,
             @"statusCode": self.statusCode,
             };
}

@end
