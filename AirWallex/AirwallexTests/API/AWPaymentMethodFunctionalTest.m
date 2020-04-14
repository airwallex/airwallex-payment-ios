//
//  AWPaymentMethodFunctionalTest.m
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
#import "AWPaymentMethodRequest.h"
#import "AWPaymentMethodResponse.h"

@interface AWPaymentMethodFunctionalTest : XCTestCase

@end

@implementation AWPaymentMethodFunctionalTest

- (void)setUp
{
    [super setUp];
    [self prepareEphemeralKeys:^(AWPaymentIntent * _Nullable paymentIntent, NSError * _Nullable error) {
        XCTAssertNotNil(paymentIntent);
        XCTAssertNil(error);
    }];
}

- (void)testGetPaymentMethodList
{
    AWGetPaymentMethodsRequest *request = [AWGetPaymentMethodsRequest new];
    request.customerId = @"cus_gSItdRkbwWQcyocadV93vQmdW0l";

    AWAPIClient *client = [AWAPIClient sharedClient];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get payment method list"];
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testCreatePaymentMethod
{
    AWCreatePaymentMethodRequest *request = [AWCreatePaymentMethodRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    AWPaymentMethod *paymentMethod = [AWPaymentMethod new];
    paymentMethod.type = AWCardKey;
    paymentMethod.billing = [AWPlaceDetails decodeFromJSON:[AWTestUtils jsonNamed:@"Billing"]];
    paymentMethod.card = [AWCard decodeFromJSON:@{
        @"number": @"4012000300001010",
        @"cvc": @"123",
        @"expiry_year": @"2020",
        @"name": @"Adam",
        @"expiry_month": @"12"
    }];
    paymentMethod.customerId = @"cus_gSItdRkbwWQcyocadV93vQmdW0l";
    request.paymentMethod = paymentMethod;

    AWAPIClient *client = [AWAPIClient sharedClient];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Create payment method"];
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

@end
