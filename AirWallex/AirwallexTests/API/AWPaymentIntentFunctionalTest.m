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
#import "AWPaymentIntent.h"

@interface AWPaymentIntentFunctionalTest : XCTestCase

@property (nonatomic, strong) AWPaymentIntent *paymentIntent;

@end

@implementation AWPaymentIntentFunctionalTest

- (void)setUp
{
    [super setUp];
    __weak __typeof(self)weakSelf = self;
    [self prepareEphemeralKeys:^(AWPaymentIntent * _Nullable paymentIntent, NSError * _Nullable error) {
        XCTAssertNotNil(paymentIntent);
        XCTAssertNil(error);
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.paymentIntent = paymentIntent;
    }];
}

- (void)testRetrievePaymentIntent
{
    AWRetrievePaymentIntentRequest *request = [AWRetrievePaymentIntentRequest new];
    request.intentId = self.paymentIntent.Id;

    AWAPIClient *client = [[AWAPIClient alloc] initWithConfiguration:[AWAPIClientConfiguration sharedConfiguration]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Retrieve payment intent"];
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

@end
