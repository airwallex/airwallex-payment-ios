//
//  AWXPaymentConsentRequest.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXPaymentConsentRequest.h"
#import "AWXConstants.h"
#import "AWXDevice.h"
#import "AWXPaymentConsent.h"
#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodOptions.h"

@implementation AWXCreatePaymentConsentRequest

- (NSString *)path {
    return [NSString stringWithFormat:@"/api/v1/pa/payment_consents/create"];
}

- (AWXHTTPMethod)method {
    return AWXHTTPMethodPOST;
}

- (nullable NSDictionary *)parameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"request_id"] = self.requestId;
    parameters[@"customer_id"] = self.customerId;
    parameters[@"currency"] = self.currency;
    parameters[@"requires_cvc"] = [NSNumber numberWithBool:self.requiresCVC];
    parameters[@"next_triggered_by"] = FormatNextTriggerByType(self.nextTriggerByType);
    NSString *merchantTriggerReasonString = FormatMerchantTriggerReason(self.merchantTriggerReason);
    if (merchantTriggerReasonString) {
        parameters[@"merchant_trigger_reason"] = merchantTriggerReasonString;
    }
    NSMutableDictionary *paymentParams = @{}.mutableCopy;
    if (self.paymentMethod.Id) {
        paymentParams[@"id"] = self.paymentMethod.Id;
    }
    if (self.paymentMethod.type) {
        paymentParams[@"type"] = self.paymentMethod.type;
    }
    if (paymentParams.allKeys) {
        [parameters addEntriesFromDictionary:@{
            @"payment_method": paymentParams
        }];
    }

    return parameters;
}

- (Class)responseClass {
    return AWXCreatePaymentConsentResponse.class;
}

@end

@implementation AWXVerifyPaymentConsentRequest

- (NSString *)path {
    return [NSString stringWithFormat:@"/api/v1/pa/payment_consents/%@/verify", self.consent.Id];
}

- (AWXHTTPMethod)method {
    return AWXHTTPMethodPOST;
}

- (nullable NSDictionary *)parameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"request_id"] = self.requestId;
    if (self.returnURL) {
        parameters[@"return_url"] = self.returnURL;
    }
    NSDictionary *params = self.options.encodeToJSON;
    id value = [params valueForKey:self.options.type];
    if (value) {
        if (self.options.card) {
            NSMutableDictionary *cardParams = @{}.mutableCopy;
            cardParams[@"amount"] = self.amount.stringValue;
            cardParams[@"currency"] = self.currency;
            if (self.options.card.cvc) {
                cardParams[@"cvc"] = self.options.card.cvc;
            }
            value = cardParams.copy;
        }
    }

    NSDictionary *options = @{
        self.options.type: value
    };
    parameters[@"verification_options"] = options;
    return parameters;
}

- (Class)responseClass {
    return AWXVerifyPaymentConsentResponse.class;
}

@end

@implementation AWXRetrievePaymentConsentRequest

- (NSString *)path {
    return [NSString stringWithFormat:@"/api/v1/pa/payment_consents/%@", self.consentId];
}

- (AWXHTTPMethod)method {
    return AWXHTTPMethodGET;
}

- (Class)responseClass {
    return AWXCreatePaymentConsentResponse.class;
}

@end

@implementation AWXGetPaymentConsentsRequest

- (NSString *)path {
    return @"/api/v1/pa/payment_consents";
}

- (AWXHTTPMethod)method {
    return AWXHTTPMethodGET;
}

- (NSDictionary *)parameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"customer_id"] = self.customerId;
    parameters[@"page_num"] = @(self.pageNum);
    parameters[@"page_size"] = @(self.pageSize);
    NSString *merchantTriggerReasonString = FormatMerchantTriggerReason(self.merchantTriggerReason);
    if (merchantTriggerReasonString) {
        parameters[@"merchant_trigger_reason"] = merchantTriggerReasonString;
    }
    if (self.nextTriggeredBy) {
        parameters[@"next_triggered_by"] = self.nextTriggeredBy;
    }
    if (self.status) {
        parameters[@"status"] = self.status;
    }
    return parameters;
}

- (Class)responseClass {
    return AWXGetPaymentConsentsResponse.class;
}

@end
