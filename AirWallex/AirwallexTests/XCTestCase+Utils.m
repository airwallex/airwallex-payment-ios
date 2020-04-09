//
//  XCTestCase+Utils.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/4/2.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "XCTestCase+Utils.h"
#import "AWTestAPIClient.h"
#import "AWAPIClient.h"

@implementation XCTestCase (Utils)

- (void)waitForDuration:(NSTimeInterval)duration
{
    XCTestExpectation *waitExpectation = [[XCTestExpectation alloc] initWithDescription:@"Waiting"];
    NSTimeInterval when = DISPATCH_TIME_NOW + duration;
    dispatch_after(when, dispatch_get_main_queue(), ^{
        [waitExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:duration handler:nil];
}

- (void)waitForElement:(XCUIElement *)element duration:(NSTimeInterval)duration
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exists == YES"];
    [self expectationForPredicate:predicate evaluatedWithObject:element handler:nil];
    [self waitForExpectationsWithTimeout:duration handler:nil];
}

- (void)prepareEphemeralKeys:(void (^)(AWPaymentIntent * _Nullable paymentIntent, NSError * _Nullable error))completionHandler
{
    [Airwallex setDefaultBaseURL:[NSURL URLWithString:@"https://staging-pci-api.airwallex.com/"]];

    AWTestAPIClient *client = [AWTestAPIClient sharedClient];
    client.authBaseURL = [NSURL URLWithString:@"https://api-staging.airwallex.com/"];
    client.paymentBaseURL = [NSURL URLWithString:@"https://staging-pci-api.airwallex.com/"];
    client.apiKey = @"e70420bb90a34c6c2be422387f4209eaf3a7aa84bc8cc4fc2af23cfde121370407833f0649261723e2a91aec552f56ee";
    client.clientID = @"dPH0tQnxRaijLH7ILl0nDQ";

    XCTestExpectation *expectation = [self expectationWithDescription:@"Get auth token"];
    [client createAuthenticationTokenWithCompletionHandler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        NSMutableDictionary *parameters = [@{@"amount": @0.10,
                                             @"currency": @"USD",
                                             @"merchant_order_id": NSUUID.UUID.UUIDString,
                                             @"request_id": NSUUID.UUID.UUIDString,
                                             @"order": @{},
                                             @"customer_id": @"cus_gSItdRkbwWQcyocadV93vQmdW0l"} mutableCopy];
        [client createPaymentIntentWithParameters:parameters
                                completionHandler:^(AWPaymentIntent * _Nullable paymentIntent, NSError * _Nullable error) {
            XCTAssertNil(error);

            [AWAPIClientConfiguration sharedConfiguration].clientSecret = paymentIntent.clientSecret;
            XCTAssertNotNil([AWAPIClientConfiguration sharedConfiguration].clientSecret);

            completionHandler(paymentIntent, error);

            [expectation fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

@end
