//
//  PKPaymentToken+Request.m
//  ApplePay
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "PKPaymentToken+Request.h"
#import "PKPaymentMethod+Request.h"

@implementation PKPaymentToken (Request)

- (nullable NSDictionary *)payloadForRequestWithBilling:(nullable NSDictionary *)billingPayload
                                                orError:(NSError * _Nullable *)error;
{
    NSData *paymentData = self.paymentData;
    NSDictionary *paymentJSON = [NSJSONSerialization JSONObjectWithData:paymentData
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
