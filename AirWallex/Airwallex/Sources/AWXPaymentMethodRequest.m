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

@implementation AWXGetPaymentMethodTypesRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.active = YES;
        self.pageNum = 0;
        self.pageSize = 10;
        self.resources = YES;
        self.osType = @"ios";
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
    
    _parameters[@"active"] = [NSNumber numberWithBool:self.active];
    _parameters[@"page_num"] = @(self.pageNum);
    _parameters[@"page_size"] = @(self.pageSize);
    if (self.transactionCurrency) {
        _parameters[@"transaction_currency"] = self.transactionCurrency;
    }
    if (self.transactionMode) {
        _parameters[@"transaction_mode"] = self.transactionMode;
    }
    if (self.countryCode) {
        _parameters[@"country_code"] = self.countryCode;
    }
    if (self.resources) {
        _parameters[@"__resources"] = @(self.resources);
    }
    if (self.lang) {
        _parameters[@"lang"] = self.lang;
    }
    if (self.osType) {
        _parameters[@"os_type"] = self.osType;
    }
    return _parameters;
}

- (Class)responseClass
{
    return AWXGetPaymentMethodTypesResponse.class;
}

@end

@implementation AWXGetPaymentMethodTypeRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.flow = @"inapp";
        self.osType = @"ios";
    }
    return self;
}

- (NSString *)path
{
    return [NSString stringWithFormat:@"/api/v1/pa/config/payment_method_types/%@", self.name];
}

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodGET;
}

- (nullable NSDictionary *)parameters
{
    NSMutableDictionary *_parameters = [NSMutableDictionary dictionary];
    
    if (self.flow) {
        _parameters[@"flow"] = self.flow;
    }
    if (self.transactionMode) {
        _parameters[@"transaction_mode"] = self.transactionMode;
    }
    if (self.lang) {
        _parameters[@"lang"] = self.lang;
    }
    if (self.osType) {
        _parameters[@"os_type"] = self.osType;
    }
    return _parameters;
}

- (Class)responseClass
{
    return AWXGetPaymentMethodTypeResponse.class;
}

@end

@implementation AWXGetAvailableBanksRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.osType = @"ios";
    }
    return self;
}

- (NSString *)path
{
    return @"/api/v1/pa/config/banks";
}

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodGET;
}

- (nullable NSDictionary *)parameters
{
    NSMutableDictionary *_parameters = [NSMutableDictionary dictionary];
    
    _parameters[@"payment_method_type"] = self.paymentMethodType;
    if (self.lang) {
        _parameters[@"lang"] = self.lang;
    }
    if (self.osType) {
        _parameters[@"os_type"] = self.osType;
    }
    if (self.countryCode) {
        _parameters[@"country_code"] = self.countryCode;
    }
    return _parameters;
}

- (Class)responseClass
{
    return AWXGetAvailableBanksResponse.class;
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

@implementation AWXDisablePaymentConsentRequest

- (NSString *)path
{
    return [NSString stringWithFormat:@"/api/v1/pa/payment_consents/%@/disable", self.Id];
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
    return AWXDisablePaymentConsentResponse.class;
}

@end
