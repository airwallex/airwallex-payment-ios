//
//  AWXAPIClientTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "AWXConstants.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXAPIErrorResponse+Update.h"
#import "AWXTestUtils.h"
#import "XCTestCase+Utils.h"
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

@interface AWXAPIClientTest : XCTestCase

@end

@implementation AWXAPIClientTest

- (void)testSendWithSuccess {
    AWXGetPaymentMethodTypesRequest *request = [AWXGetPaymentMethodTypesRequest new];
    request.active = YES;
    request.pageNum = 0;
    request.transactionCurrency = @"HKD";

    XCTAssertEqualObjects(request.flow, @"inapp");

    id sessionMock = OCMClassMock([NSURLSession class]);
    OCMStub([sessionMock sharedSession]).andReturn(sessionMock);
    NSData *mockData = [@"MockData" dataUsingEncoding:NSUTF8StringEncoding];
    id responseMock = OCMClassMock([NSHTTPURLResponse class]);
    OCMStub([responseMock statusCode]).andReturn(200);
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg isKindOfClass:[NSMutableURLRequest class]] completionHandler:([OCMArg invokeBlockWithArgs:mockData, responseMock, [NSNull null], nil])]);
    id getPaymentMethodsResponseMock = OCMClassMock([AWXGetPaymentMethodTypesResponse class]);
    OCMStub([getPaymentMethodsResponseMock parse: mockData]).andReturn(getPaymentMethodsResponseMock);
    
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get payment method list"];
    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             XCTAssertEqualObjects(response, getPaymentMethodsResponseMock);
             XCTAssertNil(error);
             [expectation fulfill];
         }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testSendWithFailureWithResponseError {
    AWXGetPaymentMethodTypesRequest *request = [AWXGetPaymentMethodTypesRequest new];
    request.active = YES;
    request.pageNum = 0;
    request.transactionCurrency = @"HKD";

    XCTAssertEqualObjects(request.flow, @"inapp");

    id sessionMock = OCMClassMock([NSURLSession class]);
    OCMStub([sessionMock sharedSession]).andReturn(sessionMock);
    NSData *mockData = [@"MockData" dataUsingEncoding:NSUTF8StringEncoding];
    id responseMock = OCMClassMock([NSHTTPURLResponse class]);
    OCMStub([responseMock statusCode]).andReturn(500);
    id getPaymentMethodsResponseMock = OCMClassMock([AWXGetPaymentMethodTypesResponse class]);
    OCMStub([getPaymentMethodsResponseMock parse: mockData]).andReturn([AWXResponse new]);
    AWXAPIErrorResponse *errorResponseMock = [[AWXAPIErrorResponse alloc] initWithMessage:@"An error from Server" code:@"500"];
    OCMStub([getPaymentMethodsResponseMock parseError: [OCMArg any]]).andReturn(errorResponseMock);

    OCMStub([sessionMock dataTaskWithRequest:[OCMArg isKindOfClass:[NSMutableURLRequest class]] completionHandler:([OCMArg invokeBlockWithArgs:mockData, responseMock, [NSNull null], nil])]);
    
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get payment method list"];
    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             XCTAssertEqualObjects(error.localizedDescription, errorResponseMock.message);
             [expectation fulfill];
         }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testSendWithFailureWithoutResponseError {
    AWXGetPaymentMethodTypesRequest *request = [AWXGetPaymentMethodTypesRequest new];
    request.active = YES;
    request.pageNum = 0;
    request.transactionCurrency = @"HKD";

    XCTAssertEqualObjects(request.flow, @"inapp");

    id sessionMock = OCMClassMock([NSURLSession class]);
    OCMStub([sessionMock sharedSession]).andReturn(sessionMock);
    NSData *mockData = [@"MockData" dataUsingEncoding:NSUTF8StringEncoding];
    id responseMock = OCMClassMock([NSHTTPURLResponse class]);
    OCMStub([responseMock statusCode]).andReturn(500);
    id getPaymentMethodsResponseMock = OCMClassMock([AWXGetPaymentMethodTypesResponse class]);
    OCMStub([getPaymentMethodsResponseMock parse: mockData]).andReturn([AWXResponse new]);
    OCMStub([getPaymentMethodsResponseMock parseError: [OCMArg any]]).andReturn(nil);

    OCMStub([sessionMock dataTaskWithRequest:[OCMArg isKindOfClass:[NSMutableURLRequest class]] completionHandler:([OCMArg invokeBlockWithArgs:mockData, responseMock, [NSNull null], nil])]);
    
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get payment method list"];
    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             XCTAssertEqualObjects(error.localizedDescription, @"Couldn't parse response.");
             [expectation fulfill];
         }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}


- (void)testSendWithFailureWithNetworkError {
    AWXGetPaymentMethodTypesRequest *request = [AWXGetPaymentMethodTypesRequest new];
    request.active = YES;
    request.pageNum = 0;
    request.transactionCurrency = @"HKD";

    XCTAssertEqualObjects(request.flow, @"inapp");

    id sessionMock = OCMClassMock([NSURLSession class]);
    OCMStub([sessionMock sharedSession]).andReturn(sessionMock);
    NSData *mockData = [@"MockData" dataUsingEncoding:NSUTF8StringEncoding];
    id responseMock = OCMClassMock([NSHTTPURLResponse class]);
    OCMStub([responseMock statusCode]).andReturn(200);
    NSError *mockError = [NSError errorWithDomain:AWXSDKErrorDomain
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"An error.", nil)}];
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg isKindOfClass:[NSMutableURLRequest class]] completionHandler:([OCMArg invokeBlockWithArgs:mockData, responseMock, mockError, nil])]);
    
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get payment method list"];
    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             XCTAssertEqual(error.localizedDescription, mockError.localizedDescription);
             [expectation fulfill];
         }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

@end
