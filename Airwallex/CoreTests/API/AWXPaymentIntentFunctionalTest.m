//
//  AWXPaymentIntentFunctionalTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "AWXConstants.h"
#import "AWXPaymentIntent.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXTestUtils.h"
#import "XCTestCase+Utils.h"
#import <XCTest/XCTest.h>

@interface AWXPaymentIntentFunctionalTest : XCTestCase

@property (nonatomic, strong) AWXPaymentIntent *paymentIntent;

@end

@implementation AWXPaymentIntentFunctionalTest

- (void)setUp {
    [super setUp];
    __weak __typeof(self) weakSelf = self;
    [self prepareEphemeralKeys:^(AWXPaymentIntent *_Nullable paymentIntent, NSError *_Nullable error) {
        XCTAssertNotNil(paymentIntent);
        XCTAssertNil(error);
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.paymentIntent = paymentIntent;
    }];
}

- (void)testRetrievePaymentIntent {
    AWXRetrievePaymentIntentRequest *request = [AWXRetrievePaymentIntentRequest new];
    request.intentId = self.paymentIntent.Id;

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Retrieve payment intent"];
    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             XCTAssertNil(error);
             [expectation fulfill];
         }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

@end
