//
//  AWXPaymentMethod.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethod.h"

@implementation AWXPaymentMethod

- (NSDictionary *)encodeToJSON
{
    NSMutableDictionary *items = [[NSMutableDictionary alloc] init];
    items[@"type"] = self.type;
    if (self.billing) {
        items[@"billing"] = self.billing.encodeToJSON;
    }
    if (self.card) {
        items[@"card"] = self.card.encodeToJSON;
    }
    if (self.additionalParams) {
        items[self.type] = self.additionalParams;
    }
    if (self.customerId) {
        items[@"customer_id"] = self.customerId;
    }
    return items;
}

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXPaymentMethod *method = [AWXPaymentMethod new];
    method.Id = json[@"id"];
    method.type = json[@"type"];
    NSDictionary *card = json[@"card"];
    if (card) {
        method.card = [AWXCard decodeFromJSON:card];
    }
    NSDictionary *billing = json[@"billing"];
    if (billing) {
        method.billing = [AWXPlaceDetails decodeFromJSON:billing];
    }
    method.customerId = json[@"customer_id"];
    return method;
}

- (void)appendAdditionalParams:(NSDictionary *)params
{
    if (self.additionalParams) {
        NSMutableDictionary *dictionary = [self.additionalParams mutableCopy];
        [dictionary addEntriesFromDictionary:params];
        self.additionalParams = dictionary;
    } else {
        self.additionalParams = params;
    }
}

@end

@implementation AWXResources

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXResources *resources = [AWXResources new];
    resources.logoURL = [NSURL URLWithString:json[@"logo_url"]];
    resources.hasSchema = [json[@"has_schema"] boolValue];
    return resources;
}

@end

@implementation AWXPaymentMethodType

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXPaymentMethodType *method = [AWXPaymentMethodType new];
    method.name = json[@"name"];
    method.displayName = json[@"display_name"];
    method.transactionMode = json[@"transaction_mode"];
    method.flows = json[@"flows"];
    method.transactionCurrencies = json[@"transaction_currencies"];
    method.active = [json[@"active"] boolValue];
    method.resources = [AWXResources decodeFromJSON:json[@"resources"]];
    return method;
}

- (BOOL)hasSchema
{
    return self.resources.hasSchema;
}

@end

@implementation AWXValidation

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXValidation *validation = [AWXValidation new];
    validation.regex = json[@"regex"];
    validation.max = [json[@"max"] integerValue];
    return validation;
}

@end

@implementation AWXField

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXField *field = [AWXField new];
    field.name = json[@"name"];
    field.displayName = json[@"display_name"];
    field.uiType = json[@"ui_type"];
    field.type = json[@"type"];
    NSDictionary *validations = json[@"validations"];
    if (validations) {
        field.validation = [AWXValidation decodeFromJSON:validations];
    }
    return field;
}

@end

@implementation AWXSchema

+ (id)decodeFromJSON:(NSDictionary *)json
{
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

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXBank *bank = [AWXBank new];
    bank.name = json[@"name"];
    bank.displayName = json[@"display_name"];
    bank.resources = [AWXResources decodeFromJSON:json[@"resources"]];
    return bank;
}

@end
