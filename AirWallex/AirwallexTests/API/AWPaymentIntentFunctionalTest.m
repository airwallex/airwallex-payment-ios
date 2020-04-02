//
//  AWPaymentIntentFunctionalTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTestCase+Utils.h"
#import "AWTestUtils.h"
#import "AWConstants.h"
#import "AWAPIClient.h"
#import "AWPaymentIntentRequest.h"
#import "AWPaymentIntentResponse.h"

@interface AWPaymentIntentFunctionalTest : XCTestCase

@end

@implementation AWPaymentIntentFunctionalTest

- (void)setUp
{
    [super setUp];
    [self prepareEphemeralKeys];
}

- (void)testRetrievePaymentIntent
{
    AWRetrievePaymentIntentRequest *request = [AWRetrievePaymentIntentRequest new];
    request.intentId = @"int_mJ25queYzvh1rrJlwziLWR88d43";

    AWAPIClient *client = [AWAPIClient sharedClient];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Retrieve payment intent"];
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

@end
