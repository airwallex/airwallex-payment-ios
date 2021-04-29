//
//  AWXPaymentMethodRequest.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/4.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"

@implementation AWXGetPaymentMethodsRequest

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

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodGET;
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
    if (self.cardType) {
        _parameters[@"type"] = self.cardType;
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
    return AWXGetPaymentMethodsResponse.class;
}

@end

@implementation AWXGetPaymentMethodsTypeRequest

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
    return @"/api/v1/pa/config/payment_method_types";
}

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodGET;
}

- (nullable NSDictionary *)parameters
{
    NSMutableDictionary *_parameters = [NSMutableDictionary dictionary];

    _parameters[@"page_num"] = @(self.pageNum);
    _parameters[@"page_size"] = @(self.pageSize);
    _parameters[@"active"] =   [NSNumber numberWithBool:self.active];
    if (self.transactionCurrency) {
        _parameters[@"transaction_currency"] = self.transactionCurrency;
    }
    return _parameters;
}

- (Class)responseClass
{
    return AWXGetPaymentMethodTypeResponse.class;
}

@end

@implementation AWXCreatePaymentMethodRequest

- (NSString *)path
{
    return @"/api/v1/pa/payment_methods/create";
}

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodPOST;
}

- (nullable NSDictionary *)parameters
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"request_id"] = self.requestId;
    [parameters addEntriesFromDictionary:self.paymentMethod.encodeToJSON];
    return parameters;
}

- (Class)responseClass
{
    return AWXCreatePaymentMethodResponse.class;
}

@end

@implementation AWXDisablePaymentMethodRequest

- (NSString *)path
{
    return [NSString stringWithFormat:@"/api/v1/pa/payment_methods/%@/disable", self.paymentMethodId];
}

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodPOST;
}

- (nullable NSDictionary *)parameters
{
    return @{@"request_id": self.requestId};
}

- (Class)responseClass
{
    return AWXDisablePaymentMethodResponse.class;
}

@end
