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
#import "AWXPaymentConsent.h"
#import "AWXAPIClient.h"

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
    
    if (self.paymentConsent && self.paymentConsent.Id) {
        NSMutableDictionary *consentParams = @{
            @"id": self.paymentConsent.Id,
        }.mutableCopy;
        
        if (self.paymentMethod.card.cvc) {
            consentParams[@"cvc"] = self.paymentMethod.card.cvc ?: @"";
        }
        [parameters addEntriesFromDictionary:@{
            @"payment_consent_reference": consentParams
        }];
    } else {
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
    }
    
    if (self.options) {
        parameters[@"payment_method_options"] = self.options.encodeToJSON;
    }
    parameters[@"save_payment_method"] = @(self.savePaymentMethod);
    if (self.device) {
        parameters[@"device"] = [self.device encodeToJSON];
    }
    parameters[@"integration_data"] = @{@"type": @"mobile_sdk",
                                        @"version": [NSString stringWithFormat:@"ios-%@-%@", @"release", AIRWALLEX_VERSION]};
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
    parameters[@"type"] = self.type;
    if ([self.type isEqualToString:AWXThreeDSCheckEnrollment]) {
        parameters[@"three_ds"] = @{@"device_data_collection_res": self.deviceDataCollectionRes};
    } else if ([self.type isEqualToString:AWXThreeDSValidate]) {
        parameters[@"three_ds"] = @{@"ds_transaction_id": self.dsTransactionId};
    } else if ([self.type isEqualToString:AWXDCC]) {
        parameters[@"use_dcc"] = self.useDCC ? @"true" : @"false";
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

@implementation AWXGetPaResRequest

- (NSString *)path
{
    return @"/pa/webhook/cybs/paresCache";
}

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodGET;
}

- (nullable NSDictionary *)parameters
{
    return @{@"paResId": self.paResId};
}

- (Class)responseClass
{
    return AWXGetPaResResponse.class;
}

@end
