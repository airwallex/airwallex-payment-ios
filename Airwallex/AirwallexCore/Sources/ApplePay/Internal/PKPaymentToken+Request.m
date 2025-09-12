//
//  PKPaymentToken+Request.m
//  ApplePay
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "PKPaymentMethod+Request.h"
#import "PKPaymentToken+Request.h"

@implementation PKPaymentToken (Request)

- (nullable NSDictionary *)payloadForRequestWithBilling:(nullable NSDictionary *)billingPayload
                                                orError:(NSError *_Nullable *)error;
{
    NSDictionary *paymentJSON = nil;
    NSData *paymentData = self.paymentData;
    if ([NSProcessInfo.processInfo.environment[@"IS_UI_TESTING"] isEqualToString:@"1"] && NSProcessInfo.processInfo.environment[@"UI_TESTING_MOCK_APPLEPAY_TOKEN"].length > 0) {
        paymentData = [NSProcessInfo.processInfo.environment[@"UI_TESTING_MOCK_APPLEPAY_TOKEN"] dataUsingEncoding:NSUTF8StringEncoding];
    }
    paymentJSON = [NSJSONSerialization JSONObjectWithData:paymentData
                                                  options:0
                                                    error:error];
    if (!paymentJSON) {
        return nil;
    }

    NSDictionary *header = paymentJSON[@"header"];

    NSMutableDictionary *payload = [NSMutableDictionary dictionary];

    if (billingPayload) {
        payload[@"billing"] = billingPayload;
    }

    [payload addEntriesFromDictionary:@{
        @"card_brand": self.paymentMethod.network.lowercaseString,
        @"card_type": self.paymentMethod.typeNameForRequest,
        @"data": paymentJSON[@"data"],
        @"ephemeral_public_key": header[@"ephemeralPublicKey"],
        @"public_key_hash": header[@"publicKeyHash"],
        @"transaction_id": header[@"transactionId"],
        @"signature": paymentJSON[@"signature"],
        @"version": paymentJSON[@"version"]
    }];

    return payload;
}

@end
