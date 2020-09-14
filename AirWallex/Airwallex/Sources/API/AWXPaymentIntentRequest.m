//
//  AWXPaymentIntentRequest.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWXConstants.h"
#import "AWXDevice.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodOptions.h"
#import "AWXPaymentIntentResponse.h"

@implementation AWXConfirmPaymentIntentRequest

- (NSString *)path
{
    return [NSString stringWithFormat:@"/api/v1/pa/payment_intents/%@/confirm", self.intentId];
}

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodPOST;
}

- (nullable NSDictionary *)parameters
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"request_id"] = self.requestId;
    if (self.customerId) {
        parameters[@"customer_id"] = self.customerId;
    }
    if (self.paymentMethod.Id) {
        [parameters addEntriesFromDictionary:@{
            @"payment_method_reference": @{
                    @"id": self.paymentMethod.Id,
                    @"cvc": self.paymentMethod.card.cvc ?: @""
            }
        }];
    } else {
        parameters[@"payment_method"] = self.paymentMethod.encodeToJSON;
    }
    if (self.options) {
        parameters[@"payment_method_options"] = self.options.encodeToJSON;
    }
    parameters[@"save_payment_method"] = @(self.savePaymentMethod);
    if (self.device) {
        parameters[@"device"] = [self.device encodeToJSON];
    }
    return parameters;
}

- (Class)responseClass
{
    return AWXConfirmPaymentIntentResponse.class;
}

@end

@implementation AWXConfirmThreeDSRequest

- (NSString *)path
{
    return [NSString stringWithFormat:@"/api/v1/pa/payment_intents/%@/confirm_continue", self.intentId];
}

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodPOST;
}

- (nullable NSDictionary *)parameters
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"request_id"] = self.requestId;
    if ([self.type isEqualToString:AWXThreeDSCheckEnrollment]) {
        parameters[@"type"] = self.type;
        parameters[@"three_ds"] = @{@"device_data_collection_res": self.deviceDataCollectionRes};
    } else if ([self.type isEqualToString:AWXThreeDSValidate]) {
        parameters[@"type"] = self.type;
        parameters[@"three_ds"] = @{@"ds_transaction_id": self.dsTransactionId};
    }
    if (self.device) {
        parameters[@"device"] = [self.device encodeToJSON];
    }
    return parameters;
}

- (Class)responseClass
{
    return AWXConfirmPaymentIntentResponse.class;
}

@end

@implementation AWXRetrievePaymentIntentRequest

- (NSString *)path
{
    return [NSString stringWithFormat:@"/api/v1/pa/payment_intents/%@", self.intentId];
}

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodGET;
}

- (Class)responseClass
{
    return AWXGetPaymentIntentResponse.class;
}

@end
