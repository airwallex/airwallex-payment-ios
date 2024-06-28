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
#import <OCMock/OCMock.h>

@interface AWXPaymentIntentFunctionalTest : XCTestCase

@property (nonatomic, strong) AWXPaymentIntent *paymentIntent;

@end

@implementation AWXPaymentIntentFunctionalTest

- (void)testRetrievePaymentIntent {
    AWXRetrievePaymentIntentRequest *request = [AWXRetrievePaymentIntentRequest new];
    request.intentId = self.paymentIntent.Id;

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    
    id sessionMock = OCMClassMock([NSURLSession class]);
    OCMStub([sessionMock sharedSession]).andReturn(sessionMock);
    NSData *mockData = [@"MockData" dataUsingEncoding:NSUTF8StringEncoding];
    id responseMock = OCMClassMock([NSHTTPURLResponse class]);
    OCMStub([responseMock statusCode]).andReturn(200);
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg isKindOfClass:[NSMutableURLRequest class]] completionHandler:([OCMArg invokeBlockWithArgs:mockData, responseMock, [NSNull null], nil])]);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Retrieve payment intent"];

    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             XCTAssertNil(error);
             [expectation fulfill];
         }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

@end
