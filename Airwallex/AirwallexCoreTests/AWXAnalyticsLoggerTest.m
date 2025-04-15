//
//  AWXAnalyticsLoggerTest.m
//  CoreTests
//
//  Created by Hector.Huang on 2023/3/22.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXAnalyticsLogger.h"
#import "AWXAPIClient.h"
#import "AWXAPIResponse.h"
#import <AirTracker/AirTracker-Swift.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface AWXAnalyticsLoggerTest : XCTestCase

@property (nonatomic, strong) id tracker;

@end

@implementation AWXAnalyticsLoggerTest

- (void)setUp {
    NSString *clientSecret = @"a.eyJ0eXBlIjoiY2xpZW50LXNlY3JldCIsInBhZGMiOiJISyIsImFjY291bnRfaWQiOiI1YTFkNjAyMi0yZmJiLTRhNWUtYTQyOC1kM2FlOGEyNmExMjMiLCJidXNpbmVzc19uYW1lIjoiRGVtbyBmb3IifQ";
    id mockConfig = OCMClassMock([AWXAPIClientConfiguration class]);
    OCMStub([mockConfig clientSecret]).andReturn(clientSecret);
    OCMStub([mockConfig sharedConfiguration]).andReturn(mockConfig);
    OCMStub([mockConfig accountID]).andReturn(@"5a1d6022-2fbb-4a5e-a428-d3ae8a26a123");

    id mockTracker = OCMClassMock([Tracker class]);
    self.tracker = mockTracker;
    OCMStub([mockTracker alloc]).andReturn(mockTracker);
    OCMStub([mockTracker initWithConfig:[OCMArg any]]).andReturn(mockTracker);
}

- (void)testInitialize {
    id mockBundle = OCMClassMock([NSBundle class]);
    OCMStub([mockBundle objectForInfoDictionaryKey:[OCMArg any]]).andReturn(@"test_app");
    OCMStub([mockBundle mainBundle]).andReturn(mockBundle);

    [AWXAnalyticsLogger shared];
    NSDictionary *dict = @{@"accountId": @"5a1d6022-2fbb-4a5e-a428-d3ae8a26a123", @"merchantAppVersion": @"test_app", @"merchantAppName": @"test_app"};
    OCMVerify(times(1), [_tracker setExtraCommonData:dict]);
}

- (void)testLogPageView {
    AWXAnalyticsLogger *logger = [AWXAnalyticsLogger new];

    NSString *pageName = @"bank_list";
    [logger logPageViewWithName:pageName];
    OCMVerify(times(1), [_tracker infoWithEventName:pageName extraInfo:@{@"eventType": @"page_view"}]);

    [logger logPageViewWithName:pageName additionalInfo:@{@"bank": @"ABC"}];
    NSDictionary *dict = @{@"bank": @"ABC", @"eventType": @"page_view"};
    OCMVerify(times(1), [_tracker infoWithEventName:pageName extraInfo:dict]);
}

- (void)testLogPaymentView {
    AWXAnalyticsLogger *logger = [AWXAnalyticsLogger new];

    [logger logPaymentMethodViewWithName:AWXCardKey];
    OCMVerify(times(1), [_tracker infoWithEventName:AWXCardKey extraInfo:@{@"eventType": @"payment_method_view"}]);

    [logger logPaymentMethodViewWithName:AWXCardKey additionalInfo:@{@"bank": @"ABC"}];
    NSDictionary *dict = @{@"bank": @"ABC", @"eventType": @"payment_method_view"};
    OCMVerify(times(1), [_tracker infoWithEventName:AWXCardKey extraInfo:dict]);
}

- (void)testLogError {
    AWXAnalyticsLogger *logger = [AWXAnalyticsLogger new];

    NSString *eventName = @"confirm_payment";
    NSError *error = [[NSError alloc] initWithDomain:@"airwallex" code:100 userInfo:@{@"message": @"something"}];
    [logger logError:error withEventName:eventName];
    OCMVerify(times(1), [_tracker errorWithEventName:eventName extraInfo:[OCMArg any]]);

    NSDictionary *dict = @{@"bank": @"ABC"};
    [logger logErrorWithName:eventName additionalInfo:dict];
    OCMVerify(times(1), [_tracker errorWithEventName:eventName extraInfo:dict]);

    NSURL *url = [NSURL URLWithString:@"http://airwallex.com"];
    AWXAPIErrorResponse *response = [[AWXAPIErrorResponse alloc] initWithMessage:@"abc" code:@"invalid_key"];
    [logger logErrorWithName:eventName url:url response:response];
    NSDictionary *errorDict = @{@"message": @"abc", @"code": @"invalid_key", @"eventType": @"pa_api_request", @"url": @"http://airwallex.com"};
    OCMVerify(times(1), [_tracker errorWithEventName:eventName extraInfo:errorDict]);
}

- (void)testLogAction {
    AWXAnalyticsLogger *logger = [AWXAnalyticsLogger new];

    NSString *actionName = @"select_payment";
    [logger logActionWithName:actionName];
    OCMVerify(times(1), [_tracker infoWithEventName:actionName extraInfo:@{@"eventType": @"action"}]);

    [logger logActionWithName:actionName additionalInfo:@{@"method": @"card"}];
    NSDictionary *dict = @{@"eventType": @"action", @"method": @"card"};
    OCMVerify(times(1), [_tracker infoWithEventName:actionName extraInfo:dict]);
}

@end
