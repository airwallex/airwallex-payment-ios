//
//  AWXDccResponse.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXDccResponse.h"

@interface AWXDccResponse ()

@property (nonatomic, copy, readwrite) NSString *currency;
@property (nonatomic, copy, readwrite) NSString *currencyPair;
@property (nonatomic, copy, readwrite) NSDecimalNumber *amount;
@property (nonatomic, copy, readwrite) NSString *amountString;
@property (nonatomic, copy, readwrite) NSDecimalNumber *clientRate;
@property (nonatomic, copy, readwrite) NSString *clientRateString;
@property (nonatomic, copy, readwrite) NSString *rateTimestamp, *rateExpiry;

@end

@implementation AWXDccResponse

+ (id)decodeFromJSON:(NSDictionary *)json {
    AWXDccResponse *response = [[AWXDccResponse alloc] init];
    response.currency = json[@"currency"];
    response.currencyPair = json[@"currency_pair"];
    NSNumber *amount = json[@"amount"];
    response.amount = [NSDecimalNumber decimalNumberWithDecimal:amount.decimalValue];
    response.amountString = @(amount.floatValue).description;
    NSNumber *clientRate = json[@"client_rate"];
    response.clientRate = [NSDecimalNumber decimalNumberWithDecimal:clientRate.decimalValue];
    response.clientRateString = @(clientRate.floatValue).description;
    response.rateTimestamp = json[@"rate_timestamp"];
    response.rateExpiry = json[@"rate_expiry"];
    return response;
}

+ (instancetype)decodeFromJSONData:(NSData *)data {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return [[self class] decodeFromJSON:json];
}

@end
