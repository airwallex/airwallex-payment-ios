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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pageNum = 0;
        self.pageSize = 10;
    }
    return self;
}

- (NSString *)path
{
    return @"/api/v1/pa/payment_methods";
}

- (AWHTTPMethod)method
{
    return AWHTTPMethodGET;
}

- (nullable NSDictionary *)parameters
{
    NSMutableDictionary *_parameters = [NSMutableDictionary dictionary];
    if (self.customerId) {
        _parameters[@"customer_id"] = self.customerId;
    }
    _parameters[@"page_num"] = @(self.pageNum);
    _parameters[@"page_size"] = @(self.pageSize);
    if (self.methodType) {
        _parameters[@"method"] = self.methodType;
    }
    if (self.fromCreatedAt) {
        _parameters[@"from_created_at"] = self.fromCreatedAt;
    }
    if (self.toCreatedAt) {
        _parameters[@"to_created_at"] = self.toCreatedAt;
    }
    return _parameters;
}

- (Class)responseClass
{
    return AWGetPaymentMethodsResponse.class;
}

@end

@implementation AWCreatePaymentMethodRequest

- (NSString *)path
{
    return @"/api/v1/pa/payment_methods/create";
}

- (AWHTTPMethod)method
{
    return AWHTTPMethodPOST;
}

- (nullable NSDictionary *)parameters
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"request_id"] = self.requestId;
    [parameters addEntriesFromDictionary:self.paymentMethod.toJSONDictionary];
    return parameters;
}

- (Class)responseClass
{
    return AWCreatePaymentMethodResponse.class;
}

@end
