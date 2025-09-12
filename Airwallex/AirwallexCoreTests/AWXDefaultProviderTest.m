//
//  AWXDefaultProviderTest.m
//  CoreTests
//
//  Created by Jin Wang on 22/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"
#import "AWXAnalyticsLogger.h"
#import "AWXDevice.h"
#import "AWXNextActionHandler.h"
#import "AWXPaymentConsent.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodOptions.h"
#import "AWXProviderDelegateEmpty.h"
#import "AWXProviderDelegateSpy.h"
#import "AWXSession.h"
#import "AWXTestUtils.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface AWXDefaultProvider (Testing)

- (void)createPaymentConsentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                                   customerId:(nullable NSString *)customerId
                                     currency:(NSString *)currency
                            nextTriggerByType:(AirwallexNextTriggerByType)nextTriggerByType
                                  requiresCVC:(BOOL)requiresCVC
                        merchantTriggerReason:(AirwallexMerchantTriggerReason)merchantTriggerReason
                                   completion:(AWXRequestHandler)completion;

- (void)confirmPaymentIntentWithId:(NSString *)paymentIntentId
                        customerId:(nullable NSString *)customerId
                     paymentMethod:(AWXPaymentMethod *)paymentMethod
                    paymentConsent:(nullable AWXPaymentConsent *)paymentConsent
                         returnURL:(NSString *)returnURL
                       autoCapture:(BOOL)autoCapture
                        completion:(AWXRequestHandler)completion;

- (void)verifyPaymentConsentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                               paymentConsent:(AWXPaymentConsent *)paymentConsent
                                     currency:(NSString *)currency
                                       amount:(NSDecimalNumber *)amount
                                    returnURL:(NSString *)returnURL
                                   completion:(AWXRequestHandler)completion;

@end

@interface AWXDefaultProviderTest : XCTestCase

@property (nonatomic, strong) AWXDefaultProvider *provider;
@property (nonatomic, strong) AWXDefaultProvider *providerMock;
@property (nonatomic, strong) AWXConfirmPaymentIntentResponse *response;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) id logger;

@end

NSString *const kProviderKey = @"PROVIDER";
NSString *const kMockKey = @"MOCK";

@implementation AWXDefaultProviderTest

- (void)setUp {
    id mockLogger = OCMClassMock([AWXAnalyticsLogger class]);
    self.logger = mockLogger;
    OCMStub([mockLogger shared]).andReturn(mockLogger);
}

- (void)testCanHandleSessionAndPaymentMethodDefaultImplementation {
    AWXSession *session = [AWXSession new];
    AWXPaymentMethodType *paymentMethod = [AWXPaymentMethodType new];
    paymentMethod.name = AWXCardKey;
    XCTAssertFalse([AWXDefaultProvider canHandleSession:session paymentMethod:paymentMethod]);
    paymentMethod.name = AWXApplePayKey;
    XCTAssertFalse([AWXDefaultProvider canHandleSession:session paymentMethod:paymentMethod]);
    paymentMethod.name = AWXWeChatPayKey;
    XCTAssertFalse([AWXDefaultProvider canHandleSession:session paymentMethod:paymentMethod]);
    paymentMethod.resources = [AWXResources new];
    paymentMethod.resources.hasSchema = true;
    XCTAssertTrue([AWXDefaultProvider canHandleSession:session paymentMethod:paymentMethod]);
}

- (void)testConfirmPaymentIntentWithoutCompletionBlock {
    [self createProviderAndMockWithSession:[AWXSession new]];

    [self.provider confirmPaymentIntentWithPaymentMethod:[AWXPaymentMethod new] paymentConsent:nil];

    OCMVerify(times(1), [self.providerMock confirmPaymentIntentWithPaymentMethod:[OCMArg any]
                                                                  paymentConsent:[OCMArg any]
                                                                            flow:AWXPaymentMethodFlowApp]);
}

- (void)testConfirmPaymentIntentWithCard {
    AWXAPIClient *client = [self mockAPIClient];
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.autoCapture = YES;
    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:spy session:session];

    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = AWXCardKey;
    [provider confirmPaymentIntentWithPaymentMethod:paymentMethod paymentConsent:nil];

    OCMVerify(times(1), [client send:[OCMArg checkWithBlock:^BOOL(id obj) {
                                    AWXConfirmPaymentIntentRequest *request = obj;
                                    XCTAssert(request.options.cardOptions.autoCapture);
                                    return YES;
                                }]
                            withCompletionHandler:[OCMArg any]]);
}

- (void)testConfirmPaymentIntentWithApplePay {
    AWXAPIClient *client = [self mockAPIClient];
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.autoCapture = YES;
    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:spy session:session];

    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = AWXApplePayKey;
    [provider confirmPaymentIntentWithPaymentMethod:paymentMethod paymentConsent:nil];

    OCMVerify(times(1), [client send:[OCMArg checkWithBlock:^BOOL(id obj) {
                                    AWXConfirmPaymentIntentRequest *request = obj;
                                    XCTAssert(request.options.cardOptions.autoCapture);
                                    return YES;
                                }]
                            withCompletionHandler:[OCMArg any]]);
}

- (void)testCreatePaymentConsentAndConfirmIntentWithOneOffSession {
    [self createProviderAndMockWithSession:[AWXOneOffSession new]];
    [self.provider createPaymentConsentAndConfirmIntentWithPaymentMethod:[AWXPaymentMethod new]];

    OCMVerify(times(1), [self.providerMock createPaymentConsentWithPaymentMethod:[OCMArg any]
                                                                      customerId:[OCMArg any]
                                                                        currency:[OCMArg any]
                                                               nextTriggerByType:AirwallexNextTriggerByCustomerType
                                                                     requiresCVC:[OCMArg any]
                                                           merchantTriggerReason:AirwallexMerchantTriggerReasonUndefined
                                                                      completion:([OCMArg invokeBlockWithArgs:self.response, self.error, nil])]);
    OCMVerify(times(1), [self.providerMock confirmPaymentIntentWithId:[OCMArg any]
                                                           customerId:[OCMArg any]
                                                        paymentMethod:[OCMArg any]
                                                       paymentConsent:[OCMArg any]
                                                            returnURL:[OCMArg any]
                                                          autoCapture:YES
                                                           completion:([OCMArg invokeBlockWithArgs:self.response, self.error, nil])]);
}

- (void)testCreatePaymentConsentAndConfirmIntentWithRecurringSession {
    AWXRecurringSession *session = [AWXRecurringSession new];
    session.requiresCVC = YES;
    [self createProviderAndMockWithSession:session hasError:NO];
    [self.provider createPaymentConsentAndConfirmIntentWithPaymentMethod:[AWXPaymentMethod new]];
    OCMVerify(times(1), [self.providerMock createPaymentConsentWithPaymentMethod:[OCMArg any]
                                                                      customerId:[OCMArg any]
                                                                        currency:[OCMArg any]
                                                               nextTriggerByType:AirwallexNextTriggerByCustomerType
                                                                     requiresCVC:[OCMArg any]
                                                           merchantTriggerReason:AirwallexMerchantTriggerReasonUndefined
                                                                      completion:([OCMArg invokeBlockWithArgs:self.response, [NSNull null], nil])]);
    OCMVerify(times(1), [self.providerMock verifyPaymentConsentWithPaymentMethod:[OCMArg any]
                                                                  paymentConsent:[OCMArg any]
                                                                        currency:[OCMArg any]
                                                                          amount:[OCMArg any]
                                                                       returnURL:[OCMArg any]
                                                                      completion:([OCMArg invokeBlockWithArgs:self.response, self.error, nil])]);
}

- (void)testCreatePaymentConsentAndConfirmIntentWithRecurringSessionWhenError {
    AWXRecurringSession *session = [AWXRecurringSession new];
    session.requiresCVC = YES;
    [self createProviderAndMockWithSession:session];
    [self.provider createPaymentConsentAndConfirmIntentWithPaymentMethod:[AWXPaymentMethod new]];
    OCMVerify(times(1), [self.providerMock completeWithResponse:nil error:self.error]);
}

- (void)testCreateLPMPaymentConsentAndVerifyRecurringWithIntentSession {
    AWXRecurringWithIntentSession *session = [AWXRecurringWithIntentSession new];
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = @"alipay";
    paymentMethod.additionalParams = [NSDictionary dictionary];
    session.requiresCVC = YES;
    [self createProviderAndMockWithSession:session hasError:NO];
    [self.provider createPaymentConsentAndConfirmIntentWithPaymentMethod:paymentMethod];

    OCMVerify(times(1), [self.providerMock createPaymentConsentWithPaymentMethod:[OCMArg any]
                                                                      customerId:[OCMArg any]
                                                                        currency:[OCMArg any]
                                                               nextTriggerByType:AirwallexNextTriggerByCustomerType
                                                                     requiresCVC:[OCMArg any]
                                                           merchantTriggerReason:AirwallexMerchantTriggerReasonUndefined
                                                                      completion:([OCMArg invokeBlockWithArgs:self.response, self.error, nil])]);
    OCMVerify(times(1), [self.providerMock verifyPaymentConsentWithPaymentMethod:[OCMArg any]
                                                                  paymentConsent:[OCMArg any]
                                                                        currency:[OCMArg any]
                                                                          amount:[OCMArg any]
                                                                       returnURL:[OCMArg any]
                                                                      completion:([OCMArg invokeBlockWithArgs:self.response, self.error, nil])]);
}

- (void)testCreateLPMPaymentConsentAndAbortVerifyRecurringWithIntentSession {
    AWXRecurringWithIntentSession *session = [AWXRecurringWithIntentSession new];
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = @"alipay";
    paymentMethod.additionalParams = [NSDictionary dictionary];
    session.requiresCVC = YES;
    [self createProviderAndMockWithSession:session hasError:YES];
    [self.provider createPaymentConsentAndConfirmIntentWithPaymentMethod:paymentMethod];

    OCMVerify(times(1), [self.providerMock createPaymentConsentWithPaymentMethod:[OCMArg any]
                                                                      customerId:[OCMArg any]
                                                                        currency:[OCMArg any]
                                                               nextTriggerByType:AirwallexNextTriggerByCustomerType
                                                                     requiresCVC:[OCMArg any]
                                                           merchantTriggerReason:AirwallexMerchantTriggerReasonUndefined
                                                                      completion:([OCMArg invokeBlockWithArgs:self.response, self.error, nil])]);
    // verify consent should not be called if create payment consent failed
    OCMVerify(times(0), [self.providerMock verifyPaymentConsentWithPaymentMethod:[OCMArg any]
                                                                  paymentConsent:[OCMArg any]
                                                                        currency:[OCMArg any]
                                                                          amount:[OCMArg any]
                                                                       returnURL:[OCMArg any]
                                                                      completion:([OCMArg invokeBlockWithArgs:self.response, self.error, nil])]);
}

- (void)testCreatePaymentConsentAndConfirmIntentWithRecurringWithIntentSessionAndCard {
    AWXRecurringWithIntentSession *session = [AWXRecurringWithIntentSession new];
    session.requiresCVC = YES;
    [self createProviderAndMockWithSession:session];
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = AWXCardKey;
    [self.provider createPaymentConsentAndConfirmIntentWithPaymentMethod:paymentMethod];

    OCMVerify(times(1), [self.providerMock createPaymentConsentWithPaymentMethod:[OCMArg any]
                                                                      customerId:[OCMArg any]
                                                                        currency:[OCMArg any]
                                                               nextTriggerByType:AirwallexNextTriggerByCustomerType
                                                                     requiresCVC:[OCMArg any]
                                                           merchantTriggerReason:AirwallexMerchantTriggerReasonUndefined
                                                                      completion:([OCMArg invokeBlockWithArgs:self.response, self.error, nil])]);
    OCMVerify(times(1), [self.providerMock confirmPaymentIntentWithId:[OCMArg any]
                                                           customerId:[OCMArg any]
                                                        paymentMethod:[OCMArg any]
                                                       paymentConsent:[OCMArg any]
                                                            returnURL:[OCMArg any]
                                                          autoCapture:YES
                                                           completion:([OCMArg invokeBlockWithArgs:self.response, self.error, nil])]);
}

- (void)testCompleteWithResponseWithPaymentConsentId {
    id mockDelegateSpy = OCMClassMock([AWXProviderDelegateSpy class]);
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = AWXCardKey;
    AWXPaymentConsent *paymentConsent = [AWXPaymentConsent new];
    paymentConsent.Id = @"consentId";
    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:mockDelegateSpy session:[AWXOneOffSession new] paymentMethodType:[AWXPaymentMethodType new]];

    [provider confirmPaymentIntentWithPaymentMethod:paymentMethod
                                     paymentConsent:paymentConsent];
    [provider completeWithResponse:[AWXConfirmPaymentIntentResponse new] error:nil];
    OCMVerify(times(1), [mockDelegateSpy provider:provider didCompleteWithPaymentConsentId:@"consentId"]);
}

- (void)testCompleteWithResponseWhenHasNextAction {
    AWXProviderDelegateEmpty *spy = [AWXProviderDelegateEmpty new];
    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:spy session:[AWXOneOffSession new] paymentMethodType:[AWXPaymentMethodType new]];
    id mockHandler = OCMClassMock([AWXNextActionHandler class]);
    OCMStub([mockHandler initWithDelegate:[OCMArg any] session:[OCMArg any]]).andReturn(mockHandler);
    OCMStub([mockHandler alloc]).andReturn(mockHandler);

    NSData *confirmResponseData = [NSJSONSerialization dataWithJSONObject:[AWXTestUtils jsonNamed:@"ConfirmPaymentIntent"] options:0 error:nil];
    AWXResponse *response = [AWXConfirmPaymentIntentResponse parse:confirmResponseData];
    AWXConfirmPaymentIntentResponse *confirmResponse = (AWXConfirmPaymentIntentResponse *)response;
    [provider completeWithResponse:confirmResponse error:nil];

    OCMVerify(times(1), [mockHandler handleNextAction:[OCMArg any]]);
}

- (void)testHandleFlow {
    [self createProviderAndMockWithSession:[AWXSession new]];
    [self.provider handleFlow];
    OCMVerify(times(1), [self.providerMock confirmPaymentIntentWithPaymentMethod:[OCMArg any]
                                                                  paymentConsent:[OCMArg any]]);
}

- (void)testVerifyPaymentConsentWithPaymentMethod {
    AWXAPIClient *client = [self mockAPIClient];
    AWXPaymentConsent *paymentConsent = [AWXPaymentConsent new];
    paymentConsent.Id = @"consentId";
    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:spy session:[AWXOneOffSession new]];

    [provider verifyPaymentConsentWithPaymentMethod:[AWXPaymentMethod new]
                                     paymentConsent:paymentConsent
                                           currency:@"USD"
                                             amount:[[NSDecimalNumber alloc] initWithString:@"99.99"]
                                          returnURL:@"https://www.airwallex.com"
                                         completion:nil];

    id request = [OCMArg checkWithBlock:^BOOL(AWXConfirmPaymentIntentRequest *obj) {
        XCTAssert([obj.device.deviceId isEqualToString:[AWXDevice deviceWithRiskSessionId].deviceId]);
        return YES;
    }];
    OCMVerify(times(1), [client send:request withCompletionHandler:[OCMArg any]]);
}

- (void)createProviderAndMockWithSession:(AWXSession *)session {
    [self createProviderAndMockWithSession:session hasError:YES];
}

- (void)createProviderAndMockWithSession:(AWXSession *)session hasError:(BOOL)hasError {
    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:spy session:session];
    id providerMock = OCMPartialMock(provider);

    AWXConfirmPaymentIntentResponse *response = [AWXConfirmPaymentIntentResponse new];
    NSError *error = [NSError errorWithDomain:@"Domain" code:-1 userInfo:nil];
    OCMStub([providerMock confirmPaymentIntentWithPaymentMethod:[OCMArg any]
                                                 paymentConsent:[OCMArg any]
                                                     completion:([OCMArg invokeBlockWithArgs:response, error, nil])]);

    if (hasError) {
        OCMStub([providerMock createPaymentConsentWithPaymentMethod:[OCMArg any]
                                                         customerId:[OCMArg any]
                                                           currency:[OCMArg any]
                                                  nextTriggerByType:AirwallexNextTriggerByCustomerType
                                                        requiresCVC:[OCMArg any]
                                              merchantTriggerReason:AirwallexMerchantTriggerReasonUndefined
                                                         completion:([OCMArg invokeBlockWithArgs:response, error, nil])]);
    } else {
        OCMStub([providerMock createPaymentConsentWithPaymentMethod:[OCMArg any]
                                                         customerId:[OCMArg any]
                                                           currency:[OCMArg any]
                                                  nextTriggerByType:AirwallexNextTriggerByCustomerType
                                                        requiresCVC:[OCMArg any]
                                              merchantTriggerReason:AirwallexMerchantTriggerReasonUndefined
                                                         completion:([OCMArg invokeBlockWithArgs:response, [NSNull null], nil])]);
    }

    OCMStub([providerMock confirmPaymentIntentWithId:[OCMArg any]
                                          customerId:[OCMArg any]
                                       paymentMethod:[OCMArg any]
                                      paymentConsent:[OCMArg any]
                                           returnURL:[OCMArg any]
                                         autoCapture:YES
                                          completion:([OCMArg invokeBlockWithArgs:response, error, nil])]);
    OCMStub([providerMock verifyPaymentConsentWithPaymentMethod:[OCMArg any]
                                                 paymentConsent:[OCMArg any]
                                                       currency:[OCMArg any]
                                                         amount:[OCMArg any]
                                                      returnURL:[OCMArg any]
                                                     completion:([OCMArg invokeBlockWithArgs:response, error, nil])]);
    self.provider = provider;
    self.providerMock = providerMock;
    self.response = response;
    self.error = error;
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
