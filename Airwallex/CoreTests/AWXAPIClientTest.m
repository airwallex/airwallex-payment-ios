//
//  AWXAPIClientTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "AWXAPIErrorResponse+Update.h"
#import "AWXConstants.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXTestUtils.h"
#import "Core/AWXAnalyticsLogger.h"
#import <AirwallexRisk/AirwallexRisk-Swift.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface AWXAPIClientConfiguration (Risk)

+ (AirwallexRiskEnvironment)riskEnvironmentForMode:(AirwallexSDKMode)mode;

@end

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
    OCMStub([getPaymentMethodsResponseMock parse:mockData]).andReturn(getPaymentMethodsResponseMock);

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration new]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get payment method list"];
    [client send:request
        withCompletionHandler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
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
    OCMStub([getPaymentMethodsResponseMock parse:mockData]).andReturn([AWXResponse new]);
    AWXAPIErrorResponse *errorResponseMock = [[AWXAPIErrorResponse alloc] initWithMessage:@"An error from Server" code:@"500"];
    OCMStub([getPaymentMethodsResponseMock parseError:[OCMArg any]]).andReturn(errorResponseMock);
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg isKindOfClass:[NSMutableURLRequest class]] completionHandler:([OCMArg invokeBlockWithArgs:mockData, responseMock, [NSNull null], nil])]);
    id loggerMock = OCMClassMock([AWXAnalyticsLogger class]);
    OCMStub([loggerMock shared]).andReturn(nil);

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration new]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get payment method list"];
    [client send:request
        withCompletionHandler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
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
    OCMStub([getPaymentMethodsResponseMock parse:mockData]).andReturn([AWXResponse new]);
    OCMStub([getPaymentMethodsResponseMock parseError:[OCMArg any]]).andReturn(nil);
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg isKindOfClass:[NSMutableURLRequest class]] completionHandler:([OCMArg invokeBlockWithArgs:mockData, responseMock, [NSNull null], nil])]);

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration new]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get payment method list"];
    [client send:request
        withCompletionHandler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
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

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration new]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get payment method list"];
    [client send:request
        withCompletionHandler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
            XCTAssertEqual(error.localizedDescription, mockError.localizedDescription);
            [expectation fulfill];
        }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testSetMode {
    [Airwallex setMode:AirwallexSDKStagingMode];
    XCTAssertTrue(Airwallex.mode == AirwallexSDKStagingMode);
}

- (void)testSetClientSecret {
    [[AWXAPIClientConfiguration sharedConfiguration] setClientSecret:@""];
    XCTAssertTrue([[AWXAPIClientConfiguration sharedConfiguration].clientSecret isEqualToString:@""]);
}

- (void)testAccountIDNil {
    [[AWXAPIClientConfiguration sharedConfiguration] setClientSecret:@""];
    XCTAssertNil([AWXAPIClientConfiguration sharedConfiguration].accountID);
}

- (void)testAccountID {
    [[AWXAPIClientConfiguration sharedConfiguration] setClientSecret:@"asdf.{\"account_id\":\"account_id\"}"];
    XCTAssertNil([AWXAPIClientConfiguration sharedConfiguration].accountID);
}

- (void)testDisableAnalytics {
    [Airwallex disableAnalytics];
    XCTAssertFalse([Airwallex analyticsEnabled]);
}

- (void)testEnableAnalytics {
    [Airwallex enableAnalytics];
    XCTAssertTrue([Airwallex analyticsEnabled]);
}

- (void)testEnableLocalLogFile {
    [Airwallex enableLocalLogFile];
    XCTAssertTrue([Airwallex isLocalLogFileEnabled]);
}

- (void)testDisableLocalLogFile {
    [Airwallex disableLocalLogFile];
    XCTAssertFalse([Airwallex isLocalLogFileEnabled]);
}

- (void)testRiskEnvironment {
    XCTAssertEqual([AWXAPIClientConfiguration riskEnvironmentForMode:AirwallexSDKProductionMode], AirwallexRiskEnvironmentProduction);
    XCTAssertEqual([AWXAPIClientConfiguration riskEnvironmentForMode:AirwallexSDKDemoMode], AirwallexRiskEnvironmentDemo);
    XCTAssertEqual([AWXAPIClientConfiguration riskEnvironmentForMode:AirwallexSDKStagingMode], AirwallexRiskEnvironmentStaging);
}

@end
