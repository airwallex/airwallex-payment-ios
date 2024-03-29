//
//  XCTestCase+Utils.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/4/2.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "AWXTestAPIClient.h"
#import "CoreTests-Swift.h"
#import "XCTestCase+Utils.h"

@implementation XCTestCase (Utils)

- (void)waitForDuration:(NSTimeInterval)duration {
    XCTestExpectation *waitExpectation = [[XCTestExpectation alloc] initWithDescription:@"Waiting"];
    NSTimeInterval when = DISPATCH_TIME_NOW + duration;
    dispatch_after(when, dispatch_get_main_queue(), ^{
        [waitExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:duration handler:nil];
}

- (void)waitForElement:(XCUIElement *)element duration:(NSTimeInterval)duration {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exists == YES"];
    [self expectationForPredicate:predicate evaluatedWithObject:element handler:nil];
    [self waitForExpectationsWithTimeout:duration handler:nil];
}

- (void)prepareEphemeralKeys:(void (^)(AWXPaymentIntent *_Nullable paymentIntent, NSError *_Nullable error))completionHandler {
    [Airwallex setDefaultBaseURL:[NSURL URLWithString:@"https://api-staging.airwallex.com/"]];

    AWXTestAPIClient *client = [AWXTestAPIClient sharedClient];
    client.paymentBaseURL = [NSURL URLWithString:@"https://api-staging.airwallex.com/"];
    client.apiKey = SecretRepository.apiKey;
    client.clientID = SecretRepository.clientId;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Get auth token"];
    [client createAuthenticationTokenWithCompletionHandler:^(NSError *_Nullable error) {
        XCTAssertNil(error);
        NSMutableDictionary *parameters = [@{@"amount": @0.10,
                                             @"currency": @"USD",
                                             @"merchant_order_id": NSUUID.UUID.UUIDString,
                                             @"request_id": NSUUID.UUID.UUIDString,
                                             @"order": @{}} mutableCopy];
        [client createPaymentIntentWithParameters:parameters
                                completionHandler:^(AWXPaymentIntent *_Nullable paymentIntent, NSError *_Nullable error) {
                                    XCTAssertNil(error);

                                    [AWXAPIClientConfiguration sharedConfiguration].clientSecret = paymentIntent.clientSecret;
                                    XCTAssertNotNil([AWXAPIClientConfiguration sharedConfiguration].clientSecret);

                                    completionHandler(paymentIntent, error);

                                    [expectation fulfill];
                                }];
    }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

@end
