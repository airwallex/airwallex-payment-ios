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
#import "AWXSession.h"
#import <AirTracker/AirTracker-Swift.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface AWXAnalyticsLogger (Testing)

- (Environment)trackerEnvironment;

@end

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
    NSDictionary *dict = @{@"accountId": @"5a1d6022-2fbb-4a5e-a428-d3ae8a26a123", @"merchantAppVersion": @"test_app", @"merchantAppName": @"test_app", @"framework": @"native"};
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
    [logger logErrorWithName:eventName url:url response:response additionalInfo:@{@"requestId": @"123456"}];
    NSDictionary *errorDict = @{@"message": @"abc", @"code": @"invalid_key", @"eventType": @"pa_api_request", @"url": @"http://airwallex.com", @"requestId": @"123456"};
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

- (void)testBindSession {
    AWXAnalyticsLogger *logger = [AWXAnalyticsLogger new];

    id mockSession = OCMClassMock([AWXSession class]);
    OCMStub([mockSession paymentIntentId]).andReturn(@"test_intent_id");

    NSDictionary *additionalInfo = @{
        @"launchType": @"dropin",
        @"layout": @"tab",
        @"transactionMode": @"oneoff"
    };

    [logger bindSession:mockSession additionalInfo:additionalInfo];

    // Verify that subsequent logs include session info
    NSString *actionName = @"test_action";
    [logger logActionWithName:actionName];

    NSDictionary *expectedDict = @{
        @"eventType": @"action",
        @"paymentIntentId": @"test_intent_id",
        @"launchType": @"dropin",
        @"layout": @"tab",
        @"transactionMode": @"oneoff"
    };
    OCMVerify(times(1), [_tracker infoWithEventName:actionName extraInfo:expectedDict]);
}

- (void)testBindSessionWithNilPaymentIntentId {
    AWXAnalyticsLogger *logger = [AWXAnalyticsLogger new];

    id mockSession = OCMClassMock([AWXSession class]);
    OCMStub([mockSession paymentIntentId]).andReturn(nil);

    NSDictionary *additionalInfo = @{@"launchType": @"component"};

    [logger bindSession:mockSession additionalInfo:additionalInfo];

    NSString *actionName = @"test_action";
    [logger logActionWithName:actionName];

    // Without payment intent id, only additional info should be included
    NSDictionary *expectedDict = @{
        @"eventType": @"action",
        @"launchType": @"component"
    };
    OCMVerify(times(1), [_tracker infoWithEventName:actionName extraInfo:expectedDict]);
}

- (void)testBindExtraCommonData {
    AWXAnalyticsLogger *logger = [AWXAnalyticsLogger new];

    NSDictionary *initialData = @{@"existingKey": @"existingValue"};
    OCMStub([_tracker extraCommonData]).andReturn(initialData);

    NSDictionary *newData = @{@"newKey": @"newValue", @"anotherKey": @"anotherValue"};
    [logger bindExtraCommonData:newData];

    NSDictionary *expectedData = @{
        @"existingKey": @"existingValue",
        @"newKey": @"newValue",
        @"anotherKey": @"anotherValue"
    };
    OCMVerify(times(1), [_tracker setExtraCommonData:expectedData]);
}

- (void)testLogPageViewWithBoundSession {
    AWXAnalyticsLogger *logger = [AWXAnalyticsLogger new];

    id mockSession = OCMClassMock([AWXSession class]);
    OCMStub([mockSession paymentIntentId]).andReturn(@"intent_123");

    NSDictionary *sessionInfo = @{@"expressCheckout": @YES};
    [logger bindSession:mockSession additionalInfo:sessionInfo];

    NSString *pageName = @"payment_method_list";
    [logger logPageViewWithName:pageName];

    NSDictionary *expectedDict = @{
        @"eventType": @"page_view",
        @"paymentIntentId": @"intent_123",
        @"expressCheckout": @YES
    };
    OCMVerify(times(1), [_tracker infoWithEventName:pageName extraInfo:expectedDict]);
}

- (void)testLogPaymentMethodViewWithBoundSession {
    AWXAnalyticsLogger *logger = [AWXAnalyticsLogger new];

    id mockSession = OCMClassMock([AWXSession class]);
    OCMStub([mockSession paymentIntentId]).andReturn(@"intent_456");

    NSDictionary *sessionInfo = @{@"layout": @"accordion"};
    [logger bindSession:mockSession additionalInfo:sessionInfo];

    [logger logPaymentMethodViewWithName:AWXCardKey];

    NSDictionary *expectedDict = @{
        @"eventType": @"payment_method_view",
        @"paymentIntentId": @"intent_456",
        @"layout": @"accordion"
    };
    OCMVerify(times(1), [_tracker infoWithEventName:AWXCardKey extraInfo:expectedDict]);
}

- (void)testLogErrorWithBoundSession {
    AWXAnalyticsLogger *logger = [AWXAnalyticsLogger new];

    id mockSession = OCMClassMock([AWXSession class]);
    OCMStub([mockSession paymentIntentId]).andReturn(@"intent_789");

    NSDictionary *sessionInfo = @{@"transactionMode": @"recurring"};
    [logger bindSession:mockSession additionalInfo:sessionInfo];

    NSError *error = [[NSError alloc] initWithDomain:@"test" code:100 userInfo:@{NSLocalizedDescriptionKey: @"Test error"}];
    [logger logError:error withEventName:@"payment_failed"];

    // Verify error is logged with session info
    OCMVerify(times(1), [_tracker errorWithEventName:@"payment_failed"
                                           extraInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *extraInfo) {
                                               return [extraInfo[@"paymentIntentId"] isEqualToString:@"intent_789"] &&
                                                      [extraInfo[@"transactionMode"] isEqualToString:@"recurring"] &&
                                                      [extraInfo[@"code"] isEqualToString:@"100"];
                                           }]]);
}

- (void)testLogWithoutBoundSession {
    AWXAnalyticsLogger *logger = [AWXAnalyticsLogger new];

    // Don't bind any session - sessionInfo should default to empty dict
    NSString *actionName = @"test_action";
    [logger logActionWithName:actionName];

    // Verify logging works without a bound session
    OCMVerify(times(1), [_tracker infoWithEventName:actionName extraInfo:@{@"eventType": @"action"}]);
}

- (void)testTrackerEnvironment {
    AWXAnalyticsLogger *logger = [AWXAnalyticsLogger new];
    AirwallexSDKMode originalMode = Airwallex.mode;

    [Airwallex setMode:AirwallexSDKDemoMode];
    XCTAssertEqual([logger trackerEnvironment], EnvironmentDemo);
    [Airwallex setMode:AirwallexSDKStagingMode];
    XCTAssertEqual([logger trackerEnvironment], EnvironmentStaging);
    [Airwallex setMode:AirwallexSDKProductionMode];
    XCTAssertEqual([logger trackerEnvironment], EnvironmentProd);
    [Airwallex setMode:AirwallexSDKPreviewMode];
    XCTAssertEqual([logger trackerEnvironment], EnvironmentPreview);

    [Airwallex setMode:originalMode];
}

- (void)testBindSessionResetsAdditionalInfo {
    AWXAnalyticsLogger *logger = [AWXAnalyticsLogger new];

    id mockSession = OCMClassMock([AWXSession class]);
    OCMStub([mockSession paymentIntentId]).andReturn(@"intent_123");

    // First bind with some additional info
    NSDictionary *initialInfo = @{@"launchType": @"dropin", @"layout": @"tab"};
    [logger bindSession:mockSession additionalInfo:initialInfo];

    [logger logActionWithName:@"action1"];
    NSDictionary *expectedDict1 = @{
        @"eventType": @"action",
        @"paymentIntentId": @"intent_123",
        @"launchType": @"dropin",
        @"layout": @"tab"
    };
    OCMVerify(times(1), [_tracker infoWithEventName:@"action1" extraInfo:expectedDict1]);

    // Rebind with different additional info - should replace previous info
    NSDictionary *newInfo = @{@"launchType": @"component"};
    [logger bindSession:mockSession additionalInfo:newInfo];

    [logger logActionWithName:@"action2"];
    NSDictionary *expectedDict2 = @{
        @"eventType": @"action",
        @"paymentIntentId": @"intent_123",
        @"launchType": @"component"
    };
    OCMVerify(times(1), [_tracker infoWithEventName:@"action2" extraInfo:expectedDict2]);
}

@end
