//
//  AWXPaymentMethodFunctionalTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "AWXConstants.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXTestUtils.h"
#import "XCTestCase+Utils.h"
#import <XCTest/XCTest.h>

@interface AWXPaymentMethodFunctionalTest : XCTestCase

@end

@implementation AWXPaymentMethodFunctionalTest

- (void)setUp {
    [super setUp];
    [self prepareEphemeralKeys:^(AWXPaymentIntent *_Nullable paymentIntent, NSError *_Nullable error) {
        XCTAssertNotNil(paymentIntent);
        XCTAssertNil(error);
    }];
}

- (void)testGetPaymentMethodList {
    AWXGetPaymentMethodTypesRequest *request = [AWXGetPaymentMethodTypesRequest new];
    request.active = YES;
    request.pageNum = 0;
    request.transactionCurrency = @"HKD";

    XCTAssertEqualObjects(request.flow, @"inapp");

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get payment method list"];
    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             XCTAssertNil(error);
             [expectation fulfill];
         }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testCreatePaymentMethod {
    AWXCreatePaymentMethodRequest *request = [AWXCreatePaymentMethodRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = AWXCardKey;
    paymentMethod.billing = [AWXPlaceDetails decodeFromJSON:[AWXTestUtils jsonNamed:@"Billing"]];
    paymentMethod.card = [AWXCard decodeFromJSON:@{
        @"number": @"4012000300001010",
        @"cvc": @"123",
        @"expiry_year": @"2020",
        @"name": @"Adam",
        @"expiry_month": @"12"
    }];
    paymentMethod.customerId = @"cus_gSItdRkbwWQcyocadV93vQmdW0l";
    request.paymentMethod = paymentMethod;

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Create payment method"];
    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             XCTAssertNotNil(error);
             [expectation fulfill];
         }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

@end
