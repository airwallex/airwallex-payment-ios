//
//  AWTestUtils.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWTestUtils.h"
#import "AWBilling.h"

@implementation AWTestUtils

+ (NSBundle *)testBundle
{
    return [NSBundle bundleForClass:[AWTestUtils class]];
}

+ (nullable NSData *)dataFromJsonFile:(NSString *)filename
{
    NSBundle *bundle = [self testBundle];
    NSString *path = [bundle pathForResource:filename ofType:@"json"];

    if (!path) {
        return nil;
    }

    NSError *error = nil;
    NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];

    if (!jsonString) {
        return nil;
    }

    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)jsonNamed:(NSString *)name
{
    NSData *data = [self dataFromJsonFile:name];
    if (data != nil) {
        return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    return nil;
}

+ (AWPaymentConfiguration *)paymentConfiguration
{
    AWPaymentConfiguration *configuration = [AWPaymentConfiguration new];
    configuration.baseURL = [NSURL URLWithString:@"https://staging-pci-api.airwallex.com/"];
    configuration.amount = [NSDecimalNumber decimalNumberWithString:@"0.1"];
    configuration.currency = @"USD";
    AWBilling *billing = [AWBilling parseFromJsonDictionary:[AWTestUtils jsonNamed:@"Billing"]];
    configuration.shipping = billing;
    configuration.intentId = @"int_mJ25queYzvh1rrJlwziLWR88d43";
    configuration.clientSecret = @"WZlx4Ab1RMlyxQxvnSLPupjHdPKcMUvMHExoiTMO-AL9Otgb6Kc4rTxQelOx3x8xr2jWuiFY5QdaLnOWPg57TWwsvCDuqd8UwpxlGGpeO0aTDsEDXZYHrn3T1liBCh9DUeGnXHGx4OUnffLFVENbodw=";
    configuration.token = @"eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJiZWM4Zjg0ZC1jZjJjLTRmZGUtOTUxYy1jZmY5N2M3NjU2NzQiLCJzdWIiOiI3NGYxZjRiNS0wOWYxLTQ1YTgtYTMyYy03ZWM4MmU1ZDI3MGQiLCJpYXQiOjE1ODU1NTkwNTMsImV4cCI6MTU4NTU3MTA1MywiYWNjb3VudF9pZCI6ImE1ZmZiMWExLTNjMjctNDljNS1hOTAwLWJjYjgxZDRkNGNhYyIsImRhdGFfY2VudGVyX3JlZ2lvbiI6IkhLIn0.ZJSabv1LEpm1XDBZXY1Ks-O5frVLCq7uOeWo8Ij-1jw";
    return configuration;
}

@end
