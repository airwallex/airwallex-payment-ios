//
//  AWXPaymentMethod.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethod.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@implementation AWXCandidate

+ (id)decodeFromJSON:(NSDictionary *)json {
    AWXCandidate *candidate = [AWXCandidate new];
    candidate.displayName = json[@"display_name"];
    candidate.value = json[@"value"];
    return candidate;
}

@end

@implementation AWXField

+ (id)decodeFromJSON:(NSDictionary *)json {
    AWXField *field = [AWXField new];
    field.name = json[@"name"];
    field.displayName = json[@"display_name"];
    field.uiType = json[@"ui_type"];
    field.type = json[@"type"];
    field.hidden = [json[@"hidden"] boolValue];
    NSMutableArray *items = [NSMutableArray array];
    NSArray *candidates = json[@"candidates"];
    if (candidates && [candidates isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in candidates) {
            [items addObject:[AWXCandidate decodeFromJSON:item]];
        }
    }
    field.candidates = items;
    return field;
}

@end

@implementation AWXSchema

+ (id)decodeFromJSON:(NSDictionary *)json {
    AWXSchema *schema = [AWXSchema new];
    schema.transactionMode = json[@"transaction_mode"];
    schema.flow = json[@"flow"];

    NSMutableArray *items = [NSMutableArray array];
    NSArray *list = json[@"fields"];
    if (list && [list isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in list) {
            [items addObject:[AWXField decodeFromJSON:item]];
        }
    }
    schema.fields = items;
    return schema;
}

@end

@implementation AWXBank

+ (id)decodeFromJSON:(NSDictionary *)json {
    AWXBank *bank = [AWXBank new];
    bank.name = json[@"bank_name"];
    bank.displayName = json[@"display_name"];
    bank.resources = [AWXResources decodeFromJSON:json[@"resources"]];
    return bank;
}

@end
