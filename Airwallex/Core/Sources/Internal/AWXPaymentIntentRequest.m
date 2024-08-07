//
//  AWXPaymentIntentRequest.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentIntentRequest.h"
#import "AWXAPIClient.h"
#import "AWXConstants.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethod.h"
#import <UIKit/UIKit.h>
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@implementation AWXConfirmThreeDSRequest

- (NSString *)path {
    return [NSString stringWithFormat:@"/api/v1/pa/payment_intents/%@/confirm_continue", self.intentId];
}

- (AWXHTTPMethod)method {
    return AWXHTTPMethodPOST;
}

- (nullable NSDictionary *)parameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"request_id"] = self.requestId;
    parameters[@"type"] = self.type;
    if ([self.type isEqualToString:AWXThreeDSCheckEnrollment]) {
        parameters[@"three_ds"] = @{@"device_data_collection_res": self.deviceDataCollectionRes};
    } else if ([self.type isEqualToString:AWXThreeDSValidate]) {
        parameters[@"three_ds"] = @{@"ds_transaction_id": self.dsTransactionId};
    } else if ([self.type isEqualToString:AWXDCC]) {
        parameters[@"use_dcc"] = self.useDCC ? @"true" : @"false";
    } else if ([self.type isEqualToString:AWXThreeDSContinue]) {
        parameters[@"three_ds"] = @{@"acs_response": self.acsResponse, @"return_url": self.returnURL};
    }
    if (self.device) {
        parameters[@"device_data"] = [self.device encodeToJSON];
    }
    return parameters;
}

- (Class)responseClass {
    return AWXConfirmPaymentIntentResponse.class;
}

@end

@implementation AWXRetrievePaymentIntentRequest

- (NSString *)path {
    return [NSString stringWithFormat:@"/api/v1/pa/payment_intents/%@", self.intentId];
}

- (AWXHTTPMethod)method {
    return AWXHTTPMethodGET;
}

- (Class)responseClass {
    return AWXGetPaymentIntentResponse.class;
}

@end

@implementation AWXGetPaResRequest

- (NSString *)path {
    return @"/pa/webhook/cybs/paresCache";
}

- (AWXHTTPMethod)method {
    return AWXHTTPMethodGET;
}

- (nullable NSDictionary *)parameters {
    return @{@"paResId": self.paResId};
}

- (Class)responseClass {
    return AWXGetPaResResponse.class;
}

@end
