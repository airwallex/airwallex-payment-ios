//
//  AWXPaymentMethodResponse.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/4.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodResponse.h"
#import "AWXPaymentMethod.h"

@interface AWXGetPaymentMethodsResponse ()

@property (nonatomic, readwrite) BOOL hasMore;
@property (nonatomic, copy, readwrite) NSArray <AWXPaymentMethod *> *items;

@end

@implementation AWXGetPaymentMethodsResponse

+ (id<AWXResponseProtocol>)parse:(NSData *)data
{
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

@interface AWXGetPaymentMethodTypeResponse ()

@property (nonatomic, readwrite) BOOL hasMore;
@property (nonatomic, copy, readwrite) NSArray <AWXPaymentMethodType *> *items;

@end

@implementation AWXGetPaymentMethodTypeResponse

+ (id<AWXResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXGetPaymentMethodTypeResponse *response = [AWXGetPaymentMethodTypeResponse new];
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



@interface AWXCreatePaymentMethodResponse ()

@property (nonatomic, strong, readwrite) AWXPaymentMethod *paymentMethod;

@end

@implementation AWXCreatePaymentMethodResponse

+ (id<AWXResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXCreatePaymentMethodResponse *response = [AWXCreatePaymentMethodResponse new];
    response.paymentMethod = [AWXPaymentMethod decodeFromJSON:responseObject];
    return response;
}

@end

@interface AWXDisablePaymentMethodResponse ()

@property (nonatomic, strong, readwrite) AWXPaymentMethod *paymentMethod;

@end

@implementation AWXDisablePaymentMethodResponse

+ (id<AWXResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXDisablePaymentMethodResponse *response = [AWXDisablePaymentMethodResponse new];
    response.paymentMethod = [AWXPaymentMethod decodeFromJSON:responseObject];
    return response;
}

@end
