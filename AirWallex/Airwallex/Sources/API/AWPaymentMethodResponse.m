//
//  AWPaymentMethodResponse.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/4.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentMethodResponse.h"
#import "AWPaymentMethod.h"

@interface AWGetPaymentMethodsResponse ()

@property (nonatomic, copy, readwrite) NSString *hasMore;
@property (nonatomic, copy, readwrite) NSArray <AWPaymentMethod *> *items;

@end

@implementation AWGetPaymentMethodsResponse

+ (id<AWResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWGetPaymentMethodsResponse *response = [AWGetPaymentMethodsResponse new];
    response.hasMore = responseObject[@"has_more"];
    NSMutableArray *items = [NSMutableArray array];
    NSArray *list = responseObject[@"items"];
    if (list && [list isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in list) {
            [items addObject:[AWPaymentMethod decodeFromJSON:item]];
        }
    }
    response.items = items;
    return response;
}

@end

@interface AWCreatePaymentMethodResponse ()

@property (nonatomic, strong, readwrite) AWPaymentMethod *paymentMethod;

@end

@implementation AWCreatePaymentMethodResponse

+ (id<AWResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWCreatePaymentMethodResponse *response = [AWCreatePaymentMethodResponse new];
    response.paymentMethod = [AWPaymentMethod decodeFromJSON:responseObject];
    return response;
}

@end
