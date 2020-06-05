//
//  AWXPaymentMethodOptions.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodOptions.h"

@implementation AWXThreeDs

- (NSDictionary *)encodeToJSON
{
    NSMutableDictionary *threeDs = [NSMutableDictionary dictionary];
    if (self.paRes) {
        threeDs[@"pa_res"] = self.paRes;
    }
    if (self.returnURL) {
        threeDs[@"return_url"] = self.returnURL;
    }
    if (self.attemptId) {
        threeDs[@"attempt_id"] = self.attemptId;
    }
    if (self.deviceDataCollectionRes) {
        threeDs[@"device_data_collection_res"] = self.deviceDataCollectionRes;
    }
    if (self.dsTransactionId) {
        threeDs[@"ds_transaction_id"] = self.dsTransactionId;
    }
    return threeDs;
}

@end

@implementation AWXCardOptions

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.autoCapture = YES;
    }
    return self;
}

- (NSDictionary *)encodeToJSON
{
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    if (self.threeDs) {
        options[@"three_ds"] = [self.threeDs encodeToJSON];
    }
    options[@"auto_capture"] = @(self.autoCapture);
    return options;
}

@end

@implementation AWXPaymentMethodOptions

- (NSDictionary *)encodeToJSON
{
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    if (self.cardOptions) {
        options[@"card"] = [self.cardOptions encodeToJSON];
    }
    return options;
}

@end
