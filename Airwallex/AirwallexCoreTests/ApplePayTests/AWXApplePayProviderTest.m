//
//  AWXApplePayProviderTest.m
//  ApplePayTests
//
//  Created by Jin Wang on 23/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXApplePayProvider.h"
#import "AWXAnalyticsLogger.h"
#import "AWXDevice.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethod.h"
#import "AWXProviderDelegateSpy.h"
#import "AWXSession+Request.h"
#import "AWXSession.h"
#import "PKContact+Request.h"
#import "PKPaymentToken+Request.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

// There's a bug where OCMockVerify will cause compiler to warn about
// Expression result unused. This pragma helps ignore the warning.

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"

@class PKPaymentAuthorizationControllerDelegate;

@interface AWXApplePayProviderTest : XCTestCase

@property (nonatomic, strong) AWXDevice *device;
@property (nonatomic, strong) id logger;

@end

@implementation AWXApplePayProviderTest

- (void)setUp {
    [super setUp];
    AWXDevice *device = [AWXDevice new];
    device.deviceId = @"abcd";
    id mockDevice = OCMClassMock([AWXDevice class]);
    OCMStub([mockDevice deviceWithRiskSessionId]).andReturn(device);
    self.device = device;

    id mockLogger = OCMClassMock([AWXAnalyticsLogger class]);
    self.logger = mockLogger;
    OCMStub([mockLogger shared]).andReturn(mockLogger);
}

- (void)testCanHandleSessionShouldReturnNOWithoutApplePayOptions {
    AWXSession *session = [AWXOneOffSession new];
    session.applePayOptions = nil;
    XCTAssertFalse([self canHandleSession:session]);
}

- (void)testCanHandleSessionShouldReturnNOWhenDeviceCheckFailed {
    AWXSession *session = [AWXOneOffSession new];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    [self mockPKCanMakePayments:NO];

    XCTAssertFalse([self canHandleSession:session]);
}

- (void)testCanHandleSessionShouldReturnYESWithOneOffSession {
    AWXSession *session = [AWXOneOffSession new];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    [self mockPKCanMakePayments:YES];

    XCTAssertTrue([self canHandleSession:session]);
}

- (void)testCanHandleSessionShouldReturnYESWithRecurringSession_MIT {
    AWXRecurringSession *session = [AWXRecurringSession new];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    session.nextTriggerByType = AirwallexNextTriggerByMerchantType;
    [self mockPKCanMakePayments:YES];

    XCTAssertTrue([self canHandleSession:session]);
}

- (void)testCanHandleSessionShouldReturnYESWithRecurringWithIntentSession_MIT {
    AWXRecurringWithIntentSession *session = [AWXRecurringWithIntentSession new];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    session.nextTriggerByType = AirwallexNextTriggerByMerchantType;
    [self mockPKCanMakePayments:YES];

    XCTAssertTrue([self canHandleSession:session]);
}

- (void)testCanHandleSessionShouldReturnFalseWithRecurringSession_CIT {
    AWXRecurringSession *session = [AWXRecurringSession new];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    [self mockPKCanMakePayments:YES];
    session.nextTriggerByType = AirwallexNextTriggerByCustomerType;
    XCTAssertFalse([self canHandleSession:session]);
}

- (void)testCanHandleSessionShouldReturnFalseWithRecurringWithIntentSession_CIT {
    AWXRecurringWithIntentSession *session = [AWXRecurringWithIntentSession new];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    [self mockPKCanMakePayments:YES];
    session.nextTriggerByType = AirwallexNextTriggerByCustomerType;
    XCTAssertFalse([self canHandleSession:session]);
}

- (void)testHandleFlowWithNoApplePayOptions {
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

- (void)testHandleFlowWhenPaymentControllerFailedToInitialize {
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
    NSError *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to initialize Apple Pay Controller.", nil)}];
    OCMVerify(times(1), [_logger logError:error withEventName:@"apple_pay_sheet"]);
}

- (void)testHandleFlowWhenPaymentControllerFailedToPresent {
    AWXOneOffSession *session = [self makeSession];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];

    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];

    id controllerMock = OCMClassMock([PKPaymentAuthorizationController class]);
    OCMStub([controllerMock alloc]).andReturn(controllerMock);
    OCMStub([controllerMock initWithPaymentRequest:[OCMArg any]]).andReturn(controllerMock);

    OCMStub([controllerMock presentWithCompletion:([OCMArg invokeBlockWithArgs:@NO, nil])]);

    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    [provider handleFlow];

    XCTAssertEqual(delegate.providerDidCompleteWithStatusCount, 1);
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusFailure);
    XCTAssertNotNil(delegate.lastStatusError);

    OCMVerify(times(1), [controllerMock initWithPaymentRequest:[OCMArg any]]);
    NSError *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to present Apple Pay Controller.", nil)}];
    OCMVerify(times(1), [_logger logError:error withEventName:@"apple_pay_sheet"]);
}

- (void)testHandleFlowCancelled {
    AWXOneOffSession *session = [self makeSession];

    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect completeWithStatus to be called"];

    delegate.statusExpectation = expectation;
    PKPaymentAuthorizationResult *result;

    [self prepareAuthorizationControllerMock:@{} billingPayload:nil result:&result endImmediately:NO];

    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];

    [provider handleFlow];

    [self waitForExpectationsWithTimeout:1 handler:nil];

    XCTAssertEqual(delegate.providerDidCompleteWithStatusCount, 1);
}

- (void)testHandleFlowWithFailedConfirmIntentRequest {
    AWXOneOffSession *session = [self makeSession];

    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    delegate.statusExpectation = [self expectationWithDescription:@"Expect completeWithStatus to be called"];

    PKPaymentAuthorizationResult *result;
    [self prepareAuthorizationControllerMock:@{} billingPayload:@{} result:&result];

    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    id providerSpy = OCMPartialMock(provider);

    NSError *error = [NSError errorWithDomain:@"domain" code:-1 userInfo:nil];

    OCMStub([providerSpy confirmPaymentIntentWithPaymentMethod:[OCMArg any]
                                                paymentConsent:[OCMArg isNil]
                                                    completion:([OCMArg invokeBlockWithArgs:[NSNull null], error, nil])]);

    [provider handleFlow];

    OCMVerify(times(1), [providerSpy confirmPaymentIntentWithPaymentMethod:[OCMArg checkWithBlock:^BOOL(id obj) {
                                         AWXPaymentMethod *method = (AWXPaymentMethod *)obj;
                                         XCTAssertEqualObjects(method.type, @"applepay");
                                         XCTAssertEqualObjects(method.customerId, session.paymentIntent.customerId);
                                         return YES;
                                     }]
                                                            paymentConsent:[OCMArg isNil]
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

- (void)testHandleFlowSuccessfullyWithOneOffSession {
    AWXOneOffSession *session = [self makeSession];
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    delegate.statusExpectation = [self expectationWithDescription:@"Expect completeWithStatus to be called"];

    PKPaymentAuthorizationResult *result;
    NSDictionary *additionalPayload = @{@"key": @"value"};
    NSDictionary *billingPayload = @{@"billingKey": @"billingValue"};

    [self prepareAuthorizationControllerMock:additionalPayload billingPayload:billingPayload result:&result];

    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    id providerSpy = OCMPartialMock(provider);

    AWXConfirmPaymentIntentResponse *response = [AWXConfirmPaymentIntentResponse new];

    OCMStub([providerSpy confirmPaymentIntentWithPaymentMethod:[OCMArg any]
                                                paymentConsent:[OCMArg isNil]
                                                    completion:([OCMArg invokeBlockWithArgs:response, [NSNull null], nil])]);

    [provider handleFlow];

    OCMVerify(times(1), [_logger logPageViewWithName:@"apple_pay_sheet"
                                      additionalInfo:@{
                                          @"supported_networks": session.applePayOptions.supportedNetworks ?: @[]
                                      }]);

    OCMVerify(times(1), [providerSpy confirmPaymentIntentWithPaymentMethod:[OCMArg checkWithBlock:^BOOL(id obj) {
                                         AWXPaymentMethod *method = (AWXPaymentMethod *)obj;
                                         XCTAssertEqualObjects(method.type, @"applepay");
                                         XCTAssertEqualObjects(method.customerId, session.paymentIntent.customerId);
                                         XCTAssertEqualObjects(method.additionalParams, additionalPayload);
                                         return YES;
                                     }]
                                                            paymentConsent:[OCMArg isNil]
                                                                completion:[OCMArg any]]);

    XCTAssertNotNil(result);
    XCTAssertEqual(result.status, PKPaymentAuthorizationStatusSuccess);
    XCTAssertEqualObjects(result.errors, [NSArray new]);

    [self waitForExpectationsWithTimeout:1 handler:nil];

    XCTAssertEqual(delegate.providerDidCompleteWithStatusCount, 1);
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusSuccess);
    XCTAssertNil(delegate.lastStatusError);
}

- (void)testHandleFlowSuccessfullyWithRecurringSession {
    AWXRecurringSession *session = [AWXRecurringSession new];
    session.countryCode = @"AU";
    session.amount = [NSDecimalNumber zero];
    session.currency = @"AUD";
    session.customerId = @"customerId";
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];

    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    delegate.statusExpectation = [self expectationWithDescription:@"Expect completeWithStatus to be called"];

    PKPaymentAuthorizationResult *result;
    NSDictionary *additionalPayload = @{@"key": @"value"};
    NSDictionary *billingPayload = @{@"billingKey": @"billingValue"};

    [self prepareAuthorizationControllerMock:additionalPayload billingPayload:billingPayload result:&result];

    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    id providerSpy = OCMPartialMock(provider);

    AWXConfirmPaymentIntentResponse *response = [AWXConfirmPaymentIntentResponse new];

    OCMStub([providerSpy createPaymentConsentAndConfirmIntentWithPaymentMethod:[OCMArg any]
                                                                    completion:([OCMArg invokeBlockWithArgs:response, [NSNull null], nil])]);

    [provider handleFlow];

    OCMVerify(times(1), [_logger logPageViewWithName:@"apple_pay_sheet"
                                      additionalInfo:@{
                                          @"supported_networks": session.applePayOptions.supportedNetworks ?: @[]
                                      }]);

    OCMVerify(times(1), [providerSpy createPaymentConsentAndConfirmIntentWithPaymentMethod:[OCMArg checkWithBlock:^BOOL(id obj) {
                                         AWXPaymentMethod *method = (AWXPaymentMethod *)obj;
                                         XCTAssertEqualObjects(method.type, @"applepay");
                                         XCTAssertEqualObjects(method.customerId, session.customerId);
                                         XCTAssertEqualObjects(method.additionalParams, additionalPayload);
                                         return YES;
                                     }]
                                                                                completion:[OCMArg any]]);

    XCTAssertNotNil(result);
    XCTAssertEqual(result.status, PKPaymentAuthorizationStatusSuccess);
    XCTAssertEqualObjects(result.errors, [NSArray new]);

    [self waitForExpectationsWithTimeout:1 handler:nil];

    XCTAssertEqual(delegate.providerDidCompleteWithStatusCount, 1);
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusSuccess);
    XCTAssertNil(delegate.lastStatusError);
}

- (void)testStartPaymentWithValidOneOffSessionCallsHandleFlow {
    AWXSession *session = [AWXOneOffSession new];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    [self mockPKCanMakePayments:YES];
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    id providerSpy = OCMPartialMock(provider);

    [provider startPayment];

    OCMVerify(times(1), [providerSpy handleFlow]);
}

- (void)testStartPaymentWithMissingApplePayOptionsReturnsError {
    AWXSession *session = [AWXOneOffSession new];
    session.applePayOptions = nil;
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    id providerSpy = OCMPartialMock(provider);

    [provider startPayment];

    OCMVerify(never(), [providerSpy handleFlow]);
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusFailure);
    XCTAssertEqualObjects(delegate.lastStatusError, [NSError errorWithDomain:AWXSDKErrorDomain
                                                                        code:-1
                                                                    userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Missing Apple Pay options in session.", nil)}]);
}

- (void)testStartPaymentWithUnsupportedCapabilitiesReturnsError {
    AWXSession *session = [AWXOneOffSession new];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    [self mockPKCanMakePayments:NO];
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    id providerSpy = OCMPartialMock(provider);

    [provider startPayment];

    OCMVerify(never(), [providerSpy handleFlow]);
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusFailure);
    XCTAssertEqualObjects(delegate.lastStatusError, [NSError errorWithDomain:AWXSDKErrorDomain
                                                                        code:-1
                                                                    userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Payment not supported via Apple Pay.", nil)}]);
}

- (void)testStartPaymentWhenPaymentControllerFailedToPresent {
    AWXSession *session = [self makeSession];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    id controllerMock = OCMClassMock([PKPaymentAuthorizationController class]);
    OCMStub([controllerMock alloc]).andReturn(controllerMock);
    OCMStub([controllerMock initWithPaymentRequest:[OCMArg any]]).andReturn(controllerMock);
    OCMStub([controllerMock setDelegate:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        id<PKPaymentAuthorizationControllerDelegate> controllerDelegate;
        [invocation getArgument:&controllerDelegate atIndex:2];

        [controllerDelegate paymentAuthorizationControllerDidFinish:controllerMock];
    });

    [provider startPayment];

    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusFailure);
    XCTAssertEqualObjects(delegate.lastStatusError, [NSError errorWithDomain:AWXSDKErrorDomain
                                                                        code:-1
                                                                    userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to present Apple Pay Controller.", nil)}]);
}

- (void)testStartPaymentWhenPaymentControllerCancelled {
    AWXSession *session = [self makeSession];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    delegate.statusExpectation = [self expectationWithDescription:@"Expect completeWithStatus to be called"];
    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:delegate session:session];
    id controllerMock = OCMClassMock([PKPaymentAuthorizationController class]);
    OCMStub([controllerMock alloc]).andReturn(controllerMock);
    OCMStub([controllerMock initWithPaymentRequest:[OCMArg any]]).andReturn(controllerMock);
    OCMStub([controllerMock dismissWithCompletion:[OCMArg invokeBlock]]);
    OCMStub([controllerMock setDelegate:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        id<PKPaymentAuthorizationControllerDelegate> controllerDelegate;
        [invocation getArgument:&controllerDelegate atIndex:2];
        id paymentMock = OCMClassMock([PKPayment class]);
        [controllerDelegate paymentAuthorizationController:controllerMock
                                       didAuthorizePayment:paymentMock
                                                   handler:^(PKPaymentAuthorizationResult *_Nonnull result) {
                                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                           [controllerDelegate paymentAuthorizationControllerDidFinish:controllerMock];
                                                       });
                                                   }];
    });
    OCMStub([controllerMock presentWithCompletion:([OCMArg invokeBlockWithArgs:@YES, nil])]);

    [provider startPayment];

    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusCancel);
}

- (AWXOneOffSession *)makeSession {
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.countryCode = @"AU";

    AWXPaymentIntent *intent = [AWXPaymentIntent new];
    session.paymentIntent = intent;
    intent.Id = @"PaymentIntentId";
    intent.currency = @"AUD";
    intent.amount = [[NSDecimalNumber alloc] initWithInt:50];
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
                            billingPayload:(nullable NSDictionary *)billingPayload
                                    result:(PKPaymentAuthorizationResult *__strong *)completionResult
                            endImmediately:(BOOL)endImmediately {
    id controllerMock = OCMClassMock([PKPaymentAuthorizationController class]);
    OCMStub([controllerMock alloc]).andReturn(controllerMock);
    OCMStub([controllerMock initWithPaymentRequest:[OCMArg any]]).andReturn(controllerMock);
    OCMStub([controllerMock dismissWithCompletion:[OCMArg invokeBlock]]);

    PKPayment *payment = OCMClassMock([PKPayment class]);
    PKPaymentToken *token = OCMClassMock([PKPaymentToken class]);
    PKContact *contact = OCMClassMock([PKContact class]);
    OCMStub([contact payloadForRequest]).andReturn(billingPayload);

    OCMStub([payment token]).andReturn(token);
    OCMStub([payment billingContact]).andReturn(contact);

    if ([payloadOrError isKindOfClass:[NSDictionary class]]) {
        OCMStub([token payloadForRequestWithBilling:billingPayload orError:[OCMArg anyObjectRef]]).andReturn(payloadOrError);
    } else if ([payloadOrError isKindOfClass:[NSError class]]) {
        OCMStub([token payloadForRequestWithBilling:billingPayload orError:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
                                                                                                      NSError *__autoreleasing *error;
                                                                                                      [invocation getArgument:&error atIndex:3];

                                                                                                      *error = payloadOrError;
                                                                                                  })
            .andReturn(nil);
    }

    OCMStub([controllerMock presentWithCompletion:([OCMArg invokeBlockWithArgs:@YES, nil])]);

    OCMStub([controllerMock setDelegate:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        id<PKPaymentAuthorizationControllerDelegate> controllerDelegate;
        [invocation getArgument:&controllerDelegate atIndex:2];

        if (endImmediately) {
            [controllerDelegate paymentAuthorizationControllerDidFinish:controllerMock];
        } else {
            [controllerDelegate paymentAuthorizationController:controllerMock
                                           didAuthorizePayment:payment
                                                       handler:^(PKPaymentAuthorizationResult *_Nonnull result) {
                                                           *completionResult = result;

                                                           [controllerDelegate paymentAuthorizationControllerDidFinish:controllerMock];
                                                       }];
        }
    });
}

- (void)prepareAuthorizationControllerMock:(id)payloadOrError
                            billingPayload:(nullable NSDictionary *)billingPayload
                                    result:(PKPaymentAuthorizationResult *__strong *)completionResult {
    [self prepareAuthorizationControllerMock:payloadOrError billingPayload:billingPayload result:completionResult endImmediately:NO];
}

- (BOOL)canHandleSession:(AWXSession *)session {
    AWXPaymentMethodType *paymentMethod = [AWXPaymentMethodType new];
    return [AWXApplePayProvider canHandleSession:session paymentMethod:paymentMethod];
}

- (void)mockPKCanMakePayments:(BOOL)canMakePayment {
    id classMock = OCMClassMock([PKPaymentAuthorizationController class]);
    if (@available(iOS 15.0, *)) {
        OCMStub([classMock canMakePayments])
            .ignoringNonObjectArgs()
            .andReturn(canMakePayment);
    } else {
        OCMStub([classMock canMakePaymentsUsingNetworks:[OCMArg any] capabilities:0])
            .ignoringNonObjectArgs()
            .andReturn(canMakePayment);
    }
}

@end

#pragma clang diagnostic pop
