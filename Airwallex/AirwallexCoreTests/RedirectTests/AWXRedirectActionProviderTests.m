//
//  AWXRedirectActionProviderTests.m
//  RedirectTests
//
//  Created by Hector.Huang on 2023/3/21.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXAnalyticsLogger.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXProviderDelegateSpy.h"
#import "AWXRedirectActionProvider.h"
#import "AWXSession.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface AWXRedirectActionProviderTests : XCTestCase

@property (nonatomic, strong) id logger;
@property (nonatomic, strong) id app;

@end

@implementation AWXRedirectActionProviderTests

- (void)setUp {
    id mockLogger = OCMClassMock([AWXAnalyticsLogger class]);
    self.logger = mockLogger;
    OCMStub([mockLogger shared]).andReturn(mockLogger);

    id mockApp = OCMClassMock([UIApplication class]);
    self.app = mockApp;
    OCMStub([mockApp sharedApplication]).andReturn(mockApp);
}

- (void)testPageViewTracking {
    OCMStub([_app openURL:[OCMArg any] options:[OCMArg any] completionHandler:([OCMArg invokeBlockWithArgs:@YES, nil])]);

    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    AWXRedirectActionProvider *provider = [[AWXRedirectActionProvider alloc] initWithDelegate:delegate session:[AWXOneOffSession new]];
    AWXConfirmPaymentNextAction *nextAction = [AWXConfirmPaymentNextAction decodeFromJSON:[self testDictionary]];

    [provider handleNextAction:nextAction];
    OCMVerify(times(1), [_logger logPageViewWithName:@"payment_redirect" additionalInfo:[self testDictionary]]);
}

- (void)testErrorLogging {
    OCMStub([_app openURL:[OCMArg any] options:[OCMArg any] completionHandler:([OCMArg invokeBlockWithArgs:@NO, nil])]);

    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    AWXRedirectActionProvider *provider = [[AWXRedirectActionProvider alloc] initWithDelegate:delegate session:[AWXOneOffSession new]];
    AWXConfirmPaymentNextAction *nextAction = [AWXConfirmPaymentNextAction decodeFromJSON:[self testDictionary]];

    [provider handleNextAction:nextAction];
    NSDictionary *dict = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Redirect to app failed.", nil), NSURLErrorKey: @"http://abc.net"};
    OCMVerify(times(1), [_logger logErrorWithName:@"payment_redirect" additionalInfo:dict]);
}

- (void)testErrorWhenRedirectToFallbackUrlSuccess {
    OCMStub([_app openURL:[OCMArg checkWithBlock:^BOOL(id obj) {
                      NSURL *url = obj;
                      return [url.absoluteString containsString:@"abc"];
                  }]
                  options:[OCMArg any]
        completionHandler:([OCMArg invokeBlockWithArgs:@NO, nil])]);
    OCMStub([_app openURL:[OCMArg checkWithBlock:^BOOL(id obj) {
                      NSURL *url = obj;
                      return [url.absoluteString containsString:@"example"];
                  }]
                  options:[OCMArg any]
        completionHandler:([OCMArg invokeBlockWithArgs:@YES, nil])]);

    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    AWXRedirectActionProvider *provider = [[AWXRedirectActionProvider alloc] initWithDelegate:delegate session:[AWXOneOffSession new]];
    AWXConfirmPaymentNextAction *nextAction = [AWXConfirmPaymentNextAction decodeFromJSON:@{@"url": @"http://abc.net", @"fallback_url": @"http://example.com"}];

    [provider handleNextAction:nextAction];
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusInProgress);
}

- (void)testErrorWhenRedirectToFallbackUrlFail {
    OCMStub([_app openURL:[OCMArg any] options:[OCMArg any] completionHandler:([OCMArg invokeBlockWithArgs:@NO, nil])]);

    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    AWXRedirectActionProvider *provider = [[AWXRedirectActionProvider alloc] initWithDelegate:delegate session:[AWXOneOffSession new]];
    AWXConfirmPaymentNextAction *nextAction = [AWXConfirmPaymentNextAction decodeFromJSON:@{@"url": @"http://abc.net", @"fallback_url": @"http://example.com"}];

    [provider handleNextAction:nextAction];
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusFailure);
}

- (void)testConfirmPaymentIntent {
    AWXAPIClient *client = [self mockAPIClient];

    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    AWXRedirectActionProvider *provider = [[AWXRedirectActionProvider alloc] initWithDelegate:delegate session:[AWXOneOffSession new]];

    [provider confirmPaymentIntentWithPaymentMethodName:@"paypal" additionalInfo:@{@"name": @"John"} flow:AWXPaymentMethodFlowWeb];
    NSDictionary *dict = @{@"name": @"John", @"flow": @"mweb", @"os_type": @"ios"};
    OCMVerify(times(1), [client send:[OCMArg checkWithBlock:^BOOL(id obj) {
                                    AWXConfirmPaymentIntentRequest *request = obj;
                                    XCTAssertEqualObjects(request.paymentMethod.type, @"paypal");
                                    XCTAssertEqualObjects(request.paymentMethod.additionalParams, dict);
                                    return YES;
                                }]
                            withCompletionHandler:[OCMArg any]]);
}

- (void)testConfirmPaymentIntentWithPaymentMethodNameVariations {
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    AWXRedirectActionProvider *provider = [[AWXRedirectActionProvider alloc] initWithDelegate:delegate session:[AWXOneOffSession new]];
    NSString *expectedPaymentMethodName = @"TestMethodName";
    id paymentClassMock = OCMPartialMock(provider);
    OCMStub([paymentClassMock confirmPaymentIntentWithPaymentMethod:[OCMArg any] paymentConsent:[OCMArg any] flow:[OCMArg any]]);

    // no additional info & default flow
    [paymentClassMock confirmPaymentIntentWithPaymentMethodName:expectedPaymentMethodName];
    OCMVerify([paymentClassMock confirmPaymentIntentWithPaymentMethod:[OCMArg any] paymentConsent:nil flow:AWXPaymentMethodFlowApp]);

    // web flow
    AWXPaymentMethodFlow expectedFlow = AWXPaymentMethodFlowWeb;
    [paymentClassMock stopMocking];
    paymentClassMock = OCMPartialMock(provider);
    OCMStub([paymentClassMock confirmPaymentIntentWithPaymentMethod:[OCMArg any] paymentConsent:[OCMArg any] flow:[OCMArg any]]);
    [paymentClassMock confirmPaymentIntentWithPaymentMethodName:expectedPaymentMethodName flow:expectedFlow];
    OCMVerify([paymentClassMock confirmPaymentIntentWithPaymentMethod:[OCMArg checkWithBlock:^BOOL(AWXPaymentMethod *obj) {
                                    XCTAssert([obj.type isEqualToString:expectedPaymentMethodName]);
                                    XCTAssertNil(obj.additionalParams);
                                    return YES;
                                }]
                                                       paymentConsent:nil
                                                                 flow:AWXPaymentMethodFlowWeb]);

    // additional info
    [paymentClassMock stopMocking];
    paymentClassMock = OCMPartialMock(provider);
    OCMStub([paymentClassMock confirmPaymentIntentWithPaymentMethod:[OCMArg any] paymentConsent:[OCMArg any] flow:[OCMArg any]]);
    NSDictionary<NSString *, NSString *> *expectedAdditionalInfo = @{@"key1": @"value1"};
    [paymentClassMock confirmPaymentIntentWithPaymentMethodName:expectedPaymentMethodName additionalInfo:expectedAdditionalInfo];
    OCMVerify([paymentClassMock confirmPaymentIntentWithPaymentMethod:[OCMArg checkWithBlock:^BOOL(AWXPaymentMethod *obj) {
                                    XCTAssert([obj.type isEqualToString:expectedPaymentMethodName]);
                                    XCTAssertEqualObjects(obj.additionalParams, expectedAdditionalInfo);
                                    return YES;
                                }]
                                                       paymentConsent:nil
                                                                 flow:AWXPaymentMethodFlowApp]);

    // flow & additional info
    [paymentClassMock stopMocking];
    paymentClassMock = OCMPartialMock(provider);
    OCMStub([paymentClassMock confirmPaymentIntentWithPaymentMethod:[OCMArg any] paymentConsent:[OCMArg any] flow:[OCMArg any]]);
    [paymentClassMock confirmPaymentIntentWithPaymentMethodName:expectedPaymentMethodName additionalInfo:expectedAdditionalInfo flow:expectedFlow];
    OCMVerify([paymentClassMock confirmPaymentIntentWithPaymentMethod:[OCMArg checkWithBlock:^BOOL(AWXPaymentMethod *obj) {
                                    XCTAssert([obj.type isEqualToString:expectedPaymentMethodName]);
                                    XCTAssertEqualObjects(obj.additionalParams, expectedAdditionalInfo);
                                    return YES;
                                }]
                                                       paymentConsent:nil
                                                                 flow:expectedFlow]);
}

- (NSDictionary *)testDictionary {
    return @{@"url": @"http://abc.net"};
}

- (AWXAPIClient *)mockAPIClient {
    AWXAPIClientConfiguration *mockConfig = OCMClassMock([AWXAPIClientConfiguration class]);
    OCMStub(ClassMethod([(id)mockConfig sharedConfiguration])).andReturn(mockConfig);

    id mockClient = OCMClassMock([AWXAPIClient class]);

    OCMStub([mockClient initWithConfiguration:mockConfig]).andReturn(mockClient);
    OCMStub([mockClient alloc]).andReturn(mockClient);

    return mockClient;
}

@end
