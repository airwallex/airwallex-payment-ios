//
//  AWPaymentIntentFunctionalTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWTestUtils.h"
#import "AWAPIClient.h"
#import "AWPaymentIntentRequest.h"
#import "AWPaymentIntentResponse.h"

@interface AWPaymentIntentFunctionalTest : XCTestCase

@end

@implementation AWPaymentIntentFunctionalTest

- (void)testRetrievePaymentIntent
{
    AWGetPaymentIntentRequest *request = [AWGetPaymentIntentRequest new];
    request.intentId = @"int_mJ25queYzvh1rrJlwziLWR88d43";

    AWPaymentConfiguration *configuration = [AWTestUtils paymentConfiguration];
    AWAPIClient *client = [[AWAPIClient alloc] initWithConfiguration:configuration];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Retrieve payment intent"];
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:8 handler:nil];
}

@end
