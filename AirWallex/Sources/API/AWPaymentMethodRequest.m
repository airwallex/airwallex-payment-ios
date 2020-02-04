//
//  AWPaymentMethodRequest.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/4.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentMethodRequest.h"
#import "AWPaymentMethodResponse.h"

@implementation AWGetPaymentMethodsRequest

- (NSString *)path
{
    return @"/api/v1/pa/payment_methods";
}

- (AWHTTPMethod)method
{
    return AWHTTPMethodGET;
}

- (Class)responseClass
{
    return AWGetPaymentMethodsResponse.class;
}

@end
