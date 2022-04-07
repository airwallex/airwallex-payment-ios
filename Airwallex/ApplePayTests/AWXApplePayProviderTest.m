//
//  AWXApplePayProviderTest.m
//  ApplePayTests
//
//  Created by Jin Wang on 23/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AWXApplePayProvider.h"
#import "AWXSession.h"
#import "AWXOneOffSession+Request.h"
#import "PKPaymentToken+Request.h"
#import "AWXProviderDelegateSpy.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentIntentResponse.h"

// There's a bug where OCMockVerify will cause compiler to warn about
// Expression result unused. This pragma helps ignore the warning.

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"

@class PKPaymentAuthorizationControllerDelegate;

@interface AWXApplePayProviderTest : XCTestCase

@end

@implementation AWXApplePayProviderTest

- (void)testCanHandleSessionShouldReturnNOWithRecurringSession
{
    AWXSession *session = [AWXRecurringSession new];
    XCTAssertFalse([AWXApplePayProvider canHandleSession:session]);
}

- (void)testCanHandleSessionShouldReturnNOWithRecurringWithIntentSession
{
    AWXSession *session = [AWXRecurringWithIntentSession new];
    XCTAssertFalse([AWXApplePayProvider canHandleSession:session]);
}

- (void)testCanHandleSessionShouldReturnNOWithoutApplePayOptions
{
    AWXSession *session = [AWXOneOffSession new];
    session.applePayOptions = nil;
    XCTAssertFalse([AWXApplePayProvider canHandleSession:session]);
}

- (void)testCanHandleSessionShouldReturnNOWhenDeviceCheckFailed
{
    AWXSession *session = [AWXOneOffSession new];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    id classMock = OCMClassMock([PKPaymentAuthorizationController class]);
    OCMStub([classMock canMakePaymentsUsingNetworks:[OCMArg any] capabilities:0])
        .ignoringNonObjectArgs()
        .andReturn(NO);
    
    XCTAssertFalse([AWXApplePayProvider canHandleSession:session]);
}

- (void)testCanHandleSessionShouldReturnYES
{
    AWXSession *session = [AWXOneOffSession new];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    id classMock = OCMClassMock([PKPaymentAuthorizationController class]);
    OCMStub([classMock canMakePaymentsUsingNetworks:[OCMArg any] capabilities:0])
        .ignoringNonObjectArgs()
        .andReturn(YES);
    
    XCTAssertTrue([AWXApplePayProvider canHandleSession:session]);
}

- (void)testHandleFlowWithUnsupportedSession
{
    AWXSession *session = [AWXRecurringSession new];
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    id controllerMock = OCMClassMock([PKPaymentAuthorizationController class]);
    OCMStub([controllerMock alloc]).andReturn(controllerMock);
    
    [provider handleFlow];
    
    XCTAssertEqual(delegate.providerDidCompleteWithStatusCount, 1);
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusFailure);
    XCTAssertNotNil(delegate.lastStatusError);
    
    OCMVerify(never(), [controllerMock initWithPaymentRequest:[OCMArg any]]);
}

- (void)testHandleFlowWithNoApplePayOptions
{
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.applePayOptions = nil;
    
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    id controllerMock = OCMClassMock([PKPaymentAuthorizationController class]);
    OCMStub([controllerMock alloc]).andReturn(controllerMock);
    
    [provider handleFlow];
    
    XCTAssertEqual(delegate.providerDidCompleteWithStatusCount, 1);
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusFailure);
    XCTAssertNotNil(delegate.lastStatusError);
    
    OCMVerify(never(), [controllerMock initWithPaymentRequest:[OCMArg any]]);
}

- (void)testHandleFlowWhenPaymentControllerFailedToInitialize
{
    AWXOneOffSession *session = [self makeSession];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    
    id controllerMock = OCMClassMock([PKPaymentAuthorizationController class]);
    OCMStub([controllerMock alloc]).andReturn(controllerMock);
    OCMStub([controllerMock initWithPaymentRequest:[OCMArg any]]).andReturn(nil);
    
    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    [provider handleFlow];
    
    XCTAssertEqual(delegate.providerDidCompleteWithStatusCount, 1);
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusFailure);
    XCTAssertNotNil(delegate.lastStatusError);
    
    OCMVerify(times(1), [controllerMock initWithPaymentRequest:[OCMArg any]]);
}

- (void)testHandleFlowWhenPaymentControllerFailedToPresent
{
    AWXOneOffSession *session = [self makeSession];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    
    id controllerMock = OCMClassMock([PKPaymentAuthorizationController class]);
    OCMStub([controllerMock alloc]).andReturn(controllerMock);
    OCMStub([controllerMock initWithPaymentRequest:[OCMArg any]]).andReturn(controllerMock);
    
    OCMStub([controllerMock presentWithCompletion:([OCMArg invokeBlockWithArgs: @NO, nil])]);
    
    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    [provider handleFlow];
    
    XCTAssertEqual(delegate.providerDidCompleteWithStatusCount, 1);
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusFailure);
    XCTAssertNotNil(delegate.lastStatusError);
    
    OCMVerify(times(1), [controllerMock initWithPaymentRequest:[OCMArg any]]);
}

- (void)testHandleFlowCancelled
{
    AWXOneOffSession *session = [self makeSession];
    
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect completeWithStatus to be called"];
    expectation.inverted = YES;
    
    delegate.statusExpectation = expectation;
    
    [self prepareAuthorizationControllerMock:nil result:nil endImmediately:YES];
    
    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    
    [provider handleFlow];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertEqual(delegate.providerDidCompleteWithStatusCount, 0);
}

- (void)testHandleFlowWithInvalidPaymentToken
{
    AWXOneOffSession *session = [self makeSession];
    
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    delegate.statusExpectation = [self expectationWithDescription:@"Expect completeWithStatus to be called"];
    
    NSError *error = [NSError errorWithDomain:@"domain" code:-1 userInfo:nil];
    PKPaymentAuthorizationResult *result;
    [self prepareAuthorizationControllerMock:error
                                      result:&result];
    
    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    id providerSpy = OCMPartialMock(provider);
    
    [provider handleFlow];
    
    OCMVerify(never(), [providerSpy confirmPaymentIntentWithPaymentMethod:[OCMArg any]
                                                           paymentConsent:[OCMArg isNil]
                                                                   device:[OCMArg isNil]
                                                               completion:[OCMArg any]]);
    
    XCTAssertNotNil(result);
    XCTAssertEqual(result.status, PKPaymentAuthorizationStatusFailure);
    XCTAssertNotNil(result.errors);
    XCTAssertEqual(result.errors.count, 1);
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertEqual(delegate.providerDidCompleteWithStatusCount, 1);
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusFailure);
    XCTAssertEqualObjects(delegate.lastStatusError, error);
}

- (void)testHandleFlowWithFailedConfirmIntentRequest
{
    AWXOneOffSession *session = [self makeSession];
    
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    delegate.statusExpectation = [self expectationWithDescription:@"Expect completeWithStatus to be called"];
    
    PKPaymentAuthorizationResult *result;
    NSDictionary *additionalPayload = @{@"key": @"value"};
    
    [self prepareAuthorizationControllerMock:additionalPayload result:&result];
    
    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    id providerSpy = OCMPartialMock(provider);
    
    NSError *error = [NSError errorWithDomain:@"domain" code:-1 userInfo:nil];
    
    OCMStub([providerSpy confirmPaymentIntentWithPaymentMethod:[OCMArg any]
                                                paymentConsent:[OCMArg isNil]
                                                        device:[OCMArg isNil]
                                                    completion:([OCMArg invokeBlockWithArgs:[NSNull null], error, nil])]);
    
    [provider handleFlow];
    
    OCMVerify(times(1), [providerSpy confirmPaymentIntentWithPaymentMethod:[OCMArg checkWithBlock:^BOOL(id obj) {
        AWXPaymentMethod *method = (AWXPaymentMethod *)obj;
        XCTAssertEqualObjects(method.type, @"applepay");
        XCTAssertEqualObjects(method.customerId, session.paymentIntent.customerId);
        XCTAssertEqualObjects(method.additionalParams, additionalPayload);
        return YES;
    }]
                                                            paymentConsent:[OCMArg isNil]
                                                                    device:[OCMArg isNil]
                                                                completion:[OCMArg any]]);
    
    XCTAssertNotNil(result);
    XCTAssertEqual(result.status, PKPaymentAuthorizationStatusFailure);
    XCTAssertNotNil(result.errors);
    XCTAssertEqual(result.errors.count, 1);
    XCTAssertEqualObjects(result.errors.firstObject, error);
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertEqual(delegate.providerDidCompleteWithStatusCount, 1);
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusFailure);
    XCTAssertEqualObjects(delegate.lastStatusError, error);
}

- (void)testHandleFlowSuccessfully
{
    AWXOneOffSession *session = [self makeSession];
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    delegate.statusExpectation = [self expectationWithDescription:@"Expect completeWithStatus to be called"];
    
    PKPaymentAuthorizationResult *result;
    [self prepareAuthorizationControllerMock:@{} result:&result];
    
    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    id providerSpy = OCMPartialMock(provider);
    
    AWXConfirmPaymentIntentResponse *response = [AWXConfirmPaymentIntentResponse new];
    
    OCMStub([providerSpy confirmPaymentIntentWithPaymentMethod:[OCMArg any]
                                                paymentConsent:[OCMArg isNil]
                                                        device:[OCMArg isNil]
                                                    completion:([OCMArg invokeBlockWithArgs:response, [NSNull null], nil])]);
    
    [provider handleFlow];
    
    OCMVerify(times(1), [providerSpy confirmPaymentIntentWithPaymentMethod:[OCMArg checkWithBlock:^BOOL(id obj) {
        AWXPaymentMethod *method = (AWXPaymentMethod *)obj;
        XCTAssertEqualObjects(method.type, @"applepay");
        XCTAssertEqualObjects(method.customerId, session.paymentIntent.customerId);
        return YES;
    }]
                                                            paymentConsent:[OCMArg isNil]
                                                                    device:[OCMArg isNil]
                                                                completion:[OCMArg any]]);
    
    XCTAssertNotNil(result);
    XCTAssertEqual(result.status, PKPaymentAuthorizationStatusSuccess);
    XCTAssertEqualObjects(result.errors, [NSArray new]);
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertEqual(delegate.providerDidCompleteWithStatusCount, 1);
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusSuccess);
    XCTAssertNil(delegate.lastStatusError);
}

- (AWXOneOffSession *)makeSession
{
    AWXOneOffSession *session = [AWXOneOffSession new];
    
    AWXPaymentIntent *intent = [AWXPaymentIntent new];
    session.paymentIntent = intent;
    intent.customerId = @"customerId";
    
    AWXPlaceDetails *billing = [AWXPlaceDetails new];
    billing.firstName = @"firstName";
    billing.lastName = @"lastName";
    
    AWXAddress *address = [AWXAddress new];
    address.countryCode = @"AU";
    address.city = @"City";
    address.street = @"Street";
    
    billing.address = address;
    
    session.billing = billing;
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    
    return session;
}

- (void)prepareAuthorizationControllerMock:(id)payloadOrError
                                    result:(PKPaymentAuthorizationResult * __strong *)completionResult
                            endImmediately:(BOOL)endImmediately
{
    id controllerMock = OCMClassMock([PKPaymentAuthorizationController class]);
    OCMStub([controllerMock alloc]).andReturn(controllerMock);
    OCMStub([controllerMock initWithPaymentRequest:[OCMArg any]]).andReturn(controllerMock);
    OCMStub([controllerMock dismissWithCompletion:[OCMArg invokeBlock]]);
    
    PKPayment *payment = OCMClassMock([PKPayment class]);
    PKPaymentToken *token = OCMClassMock([PKPaymentToken class]);
    OCMStub([payment token]).andReturn(token);
    
    if ([payloadOrError isKindOfClass: [NSDictionary class]]) {
        OCMStub([token payloadForRequestWithBilling:[OCMArg any] orError:[OCMArg anyObjectRef]]).andReturn(payloadOrError);
    } else if ([payloadOrError isKindOfClass:[NSError class]]) {
        OCMStub([token payloadForRequestWithBilling:[OCMArg any] orError:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
            NSError * __autoreleasing *error;
            [invocation getArgument:&error atIndex:3];
            
            *error = payloadOrError;
            
        }).andReturn(nil);
    }
    
    OCMStub([controllerMock setDelegate:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        id<PKPaymentAuthorizationControllerDelegate> controllerDelegate;
        [invocation getArgument:&controllerDelegate atIndex:2];
        
        if (endImmediately) {
            [controllerDelegate paymentAuthorizationControllerDidFinish:controllerMock];
        } else {
            [controllerDelegate paymentAuthorizationController:controllerMock didAuthorizePayment:payment handler:^(PKPaymentAuthorizationResult * _Nonnull result) {
                *completionResult = result;
                
                [controllerDelegate paymentAuthorizationControllerDidFinish:controllerMock];
            }];
        }
    });
    
    OCMStub([controllerMock presentWithCompletion:([OCMArg invokeBlockWithArgs: @YES, nil])]);
}

- (void)prepareAuthorizationControllerMock:(id)payloadOrError
                                    result:(PKPaymentAuthorizationResult * __strong *)completionResult
{
    [self prepareAuthorizationControllerMock:payloadOrError result:completionResult endImmediately:NO];
}

@end

#pragma clang diagnostic pop
