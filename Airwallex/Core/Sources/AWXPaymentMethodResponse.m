//
//  AWXPaymentMethodResponse.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/4.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodResponse.h"
#import "AWXPage.h"
#import "AWXPaymentMethod.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWXGetPaymentMethodsResponse ()

@property (nonatomic, readwrite) BOOL hasMore;
@property (nonatomic, copy, readwrite) NSArray<AWXPaymentMethod *> *items;

@end

@implementation AWXGetPaymentMethodsResponse

+ (AWXResponse *)parse:(NSData *)data {
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXGetPaymentMethodsResponse *response = [AWXGetPaymentMethodsResponse new];
    response.hasMore = [responseObject[@"has_more"] boolValue];
    NSMutableArray *items = [NSMutableArray array];
    NSArray *list = responseObject[@"items"];
    if (list && [list isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in list) {
            [items addObject:[AWXPaymentMethod decodeFromJSON:item]];
        }
    }
    response.items = items;
    return response;
}

@end

@interface AWXGetPaymentMethodTypesResponse ()

@property (nonatomic, readwrite) BOOL hasMore;
@property (nonatomic, copy, readwrite) NSArray<AWXPaymentMethodType *> *items;

@end

@implementation AWXGetPaymentMethodTypesResponse

+ (AWXResponse *)parse:(NSData *)data {
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXGetPaymentMethodTypesResponse *response = [AWXGetPaymentMethodTypesResponse new];
    response.hasMore = [responseObject[@"has_more"] boolValue];
    NSMutableArray *items = [NSMutableArray array];
    NSArray *list = responseObject[@"items"];
    if (list && [list isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in list) {
            [items addObject:[AWXPaymentMethodType decodeFromJSON:item]];
        }
    }
    response.items = items;
    return response;
}

@end

@interface AWXGetPaymentMethodTypeResponse ()

@end

@implementation AWXGetPaymentMethodTypeResponse

+ (AWXResponse *)parse:(NSData *)data {
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXGetPaymentMethodTypeResponse *response = [AWXGetPaymentMethodTypeResponse new];
    response.name = responseObject[@"name"];
    response.displayName = responseObject[@"display_name"];
    response.logoURL = responseObject[@"logo_url"];
    response.hasSchema = [responseObject[@"has_schema"] boolValue];

    NSMutableArray *items = [NSMutableArray array];
    NSArray *list = responseObject[@"field_schemas"];
    if (list && [list isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in list) {
            [items addObject:[AWXSchema decodeFromJSON:item]];
        }
    }
    response.schemas = items;
    return response;
}

@end

@interface AWXGetAvailableBanksResponse ()

@property (nonatomic, readwrite) BOOL hasMore;
@property (nonatomic, copy, readwrite) NSArray<AWXBank *> *items;

@end

@implementation AWXGetAvailableBanksResponse

+ (AWXResponse *)parse:(NSData *)data {
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXGetAvailableBanksResponse *response = [AWXGetAvailableBanksResponse new];
    response.hasMore = [responseObject[@"has_more"] boolValue];
    NSMutableArray *items = [NSMutableArray array];
    NSArray *list = responseObject[@"items"];
    if (list && [list isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in list) {
            [items addObject:[AWXBank decodeFromJSON:item]];
        }
    }
    response.items = items;
    return response;
}

@end

@interface AWXCreatePaymentMethodResponse ()

@property (nonatomic, strong, readwrite) AWXPaymentMethod *paymentMethod;

@end

@implementation AWXCreatePaymentMethodResponse

+ (AWXResponse *)parse:(NSData *)data {
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXCreatePaymentMethodResponse *response = [AWXCreatePaymentMethodResponse new];
    response.paymentMethod = [AWXPaymentMethod decodeFromJSON:responseObject];
    return response;
}

@end

@interface AWXDisablePaymentConsentResponse ()

@property (nonatomic, strong, readwrite) AWXPaymentConsent *paymentConsent;

@end

@implementation AWXDisablePaymentConsentResponse

+ (AWXResponse *)parse:(NSData *)data {
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXDisablePaymentConsentResponse *response = [AWXDisablePaymentConsentResponse new];
    response.paymentConsent = [AWXPaymentConsent decodeFromJSON:responseObject];
    return response;
}

@end
