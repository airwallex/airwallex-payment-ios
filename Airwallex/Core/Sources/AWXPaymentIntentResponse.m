//
//  AWXPaymentintentResponse.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethod.h"

@interface AWXGetPaymentIntentResponse ()

@property (nonatomic, copy, readwrite) NSString *Id;
@property (nonatomic, copy, readwrite) NSString *requestId;
@property (nonatomic, copy, readwrite) NSDecimalNumber *amount;
@property (nonatomic, copy, readwrite) NSString *currency;
@property (nonatomic, copy, readwrite) NSString *merchantOrderId;
@property (nonatomic, copy, readwrite) NSDictionary *order;
@property (nonatomic, copy, readwrite) NSString *customerId;
@property (nonatomic, copy, readwrite) NSString *status;
@property (nonatomic, copy, readwrite) NSDecimalNumber *capturedAmount;
@property (nonatomic, copy, readwrite) NSString *createdAt;
@property (nonatomic, copy, readwrite) NSString *updatedAt;
@property (nonatomic, copy, readwrite) NSArray<NSString *> *availablePaymentMethodTypes;
@property (nonatomic, copy, readwrite) NSString *clientSecret;

@end

@implementation AWXGetPaymentIntentResponse

+ (AWXResponse *)parse:(NSData *)data {
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXGetPaymentIntentResponse *response = [[AWXGetPaymentIntentResponse alloc] init];
    response.Id = json[@"id"];
    response.requestId = json[@"request_id"];
    NSNumber *amount = json[@"amount"];
    response.amount = [NSDecimalNumber decimalNumberWithDecimal:amount.decimalValue];
    response.currency = json[@"currency"];
    response.merchantOrderId = json[@"merchant_order_id"];
    response.order = json[@"order"];
    response.customerId = json[@"customer_id"];
    response.status = json[@"status"];
    NSNumber *capturedAmount = json[@"captured_amount"];
    response.capturedAmount = [NSDecimalNumber decimalNumberWithDecimal:capturedAmount.decimalValue];
    response.createdAt = json[@"created_at"];
    response.updatedAt = json[@"updated_at"];
    response.availablePaymentMethodTypes = json[@"available_payment_method_types"];
    response.clientSecret = json[@"client_secret"];
    return response;
}

@end

@interface AWXGetPaResResponse ()

@property (nonatomic, copy, readwrite) NSString *paRes;

@end

@implementation AWXGetPaResResponse

+ (AWXResponse *)parse:(NSData *)data {
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXGetPaResResponse *response = [[AWXGetPaResResponse alloc] init];
    response.paRes = json[@"pares"];
    return response;
}

@end
