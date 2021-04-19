//
//  AWXPaymentConsentRequest.m
//  Airwallex
//
//  Created by 秋风木叶下 on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXPaymentConsentRequest.h"
#import "AWXConstants.h"
#import "AWXDevice.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodOptions.h"
#import "AWXPaymentConsentResponse.h"
#import "Airwallex.h"
#import "AWXPaymentConsent.h"


@implementation AWXCreatePaymentConsentRequest

- (NSString *)path
{
    return [NSString stringWithFormat:@"/api/v1/pa/payment_consents/create"];
}

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodPOST;
}

- (nullable NSDictionary *)parameters
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"request_id"]        = self.requestId;
    parameters[@"customer_id"]       = self.customerId;
    parameters[@"next_triggered_by"] = self.next_triggered_by;
    parameters[@"requires_cvc"] = [NSNumber numberWithBool:NO];
    parameters[@"merchant_trigger_reason"] = [Airwallex paymentMode] == AirwallexPaymentNormalMode ? @"unscheduled" : @"scheduled";
    if ([Airwallex userType] == AirwallexUserTypeCustomer) {
        parameters[@"next_triggered_by"] = @"customer";
        if (self.paymentMethod.card) {
            parameters[@"requires_cvc"] = [NSNumber numberWithBool:YES];
        }
    }else{
        parameters[@"next_triggered_by"]       = @"merchant";
    }

    NSMutableDictionary *paymentParams = @{}.mutableCopy;
    if (self.paymentMethod.Id) {
        paymentParams[@"id"]   = self.paymentMethod.Id;
    }
    if (self.paymentMethod.type) {
        paymentParams[@"type"] = self.paymentMethod.type;
    }
    if (paymentParams.allKeys) {
        [parameters addEntriesFromDictionary:@{
            @"payment_method":paymentParams
        }];
    }
    
    return parameters;
}

- (Class)responseClass
{
    return AWXPaymentConsentResponse.class;
}

@end

@implementation AWXVerifyPaymentConsentRequest

- (NSString *)path
{
    return [NSString stringWithFormat:@"/api/v1/pa/payment_consents/%@/verify",self.consent.Id];
}

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodPOST;
}

- (nullable NSDictionary *)parameters
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"request_id"] = self.requestId;
    NSDictionary *options = @{};
    if (self.options.card) {
        NSMutableDictionary *cardParams = @{}.mutableCopy;
        AWXPaymentIntent * intent = [AWXUIContext sharedContext].paymentIntent;
        cardParams[@"amount"] = @"0.00";
        if (intent.currency) {
            cardParams[@"currency"] = intent.currency;
        }
        if (self.options.card.cvc && self.consent.requires_cvc) {
            cardParams[@"cvc"] = self.options.card.cvc;
        }
        options = cardParams.copy;
    }else{
        NSDictionary *params = self.options.encodeToJSON;
        options = params;
        id value = [params valueForKey:self.options.type];
        if (value) {
            options = @{
                self.options.type : value
            };
        }
    }
    parameters[@"verification_options"] = options;
    return parameters;
}

- (Class)responseClass
{
    return AWXPaymentConsentResponse.class;
}

@end

@implementation AWXRetrievePaymentConsentRequest

- (NSString *)path
{
    return [NSString stringWithFormat:@"/api/v1/pa/payment_consents/%@",self.consentId];
}

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodGET;
}

- (Class)responseClass
{
    return AWXPaymentConsentResponse.class;
}

@end
