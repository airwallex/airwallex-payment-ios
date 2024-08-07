//
//  AWXDefaultProviderTest.m
//  CoreTests
//
//  Created by Jin Wang on 22/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"
#import "AWXAPIResponse.h"
#import "AWXAnalyticsLogger.h"
#import "AWXNextActionHandler.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethod.h"
#import "AWXProviderDelegateEmpty.h"
#import "AWXProviderDelegateSpy.h"
#import "AWXSession.h"
#import "AWXTestUtils.h"
#import "CoreTests-Swift.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

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
                            device:(AWXDevice *)device
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
    AWXPaymentMethodType *paymentMethod = [self emptyPaymentMethodType];
    XCTAssertTrue([AWXDefaultProvider canHandleSession:session paymentMethod:paymentMethod]);
}

- (void)testConfirmPaymentIntentWithoutCompletionBlock {
    [self createProviderAndMockWithSession:[AWXSession new]];

    [self.provider confirmPaymentIntentWithPaymentMethod:[self emptyPaymentMethod] paymentConsent:nil device:nil];

    OCMVerify(times(1), [self.providerMock confirmPaymentIntentWithPaymentMethod:[OCMArg any]
                                                                  paymentConsent:[OCMArg any]
                                                                          device:[OCMArg any]
                                                                      completion:[OCMArg any]]);
    OCMVerify(times(1), [self.providerMock completeWithResponse:self.response error:self.error]);
}

- (void)testConfirmPaymentIntentWithCard {
    id mockClient = OCMClassMock([AWXAPIClientSwift class]);
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.autoCapture = YES;
    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:spy session:session];

    AWXPaymentMethod *paymentMethod = [[AWXPaymentMethod alloc] initWithType:AWXCardKey id:nil billing:nil card:nil additionalParams:nil customerId:nil];
    [provider confirmPaymentIntentWithPaymentMethod:paymentMethod paymentConsent:nil device:nil];

    OCMVerify(times(1), [mockClient confirmPaymentIntentWithConfiguration:[OCMArg any] completion:[OCMArg any]]);
}

- (void)testConfirmPaymentIntentWithApplePay {
    id mockClient = OCMClassMock([AWXAPIClientSwift class]);
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.autoCapture = YES;
    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:spy session:session];

    AWXPaymentMethod *paymentMethod = [[AWXPaymentMethod alloc] initWithType:AWXApplePayKey id:nil billing:nil card:nil additionalParams:nil customerId:nil];
    [provider confirmPaymentIntentWithPaymentMethod:paymentMethod paymentConsent:nil device:nil];

    OCMVerify(times(1), [mockClient confirmPaymentIntentWithConfiguration:[OCMArg any] completion:[OCMArg any]]);
}

- (void)testCreatePaymentConsentAndConfirmIntentWithOneOffSession {
    [self createProviderAndMockWithSession:[AWXOneOffSession new]];
    [self.provider createPaymentConsentAndConfirmIntentWithPaymentMethod:[self emptyPaymentMethod]
                                                                  device:nil];

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
                                                               device:[OCMArg any]
                                                            returnURL:[OCMArg any]
                                                          autoCapture:YES
                                                           completion:([OCMArg invokeBlockWithArgs:self.response, self.error, nil])]);
}

- (void)testCreatePaymentConsentAndConfirmIntentWithRecurringSession {
    AWXRecurringSession *session = [AWXRecurringSession new];
    session.requiresCVC = YES;
    [self createProviderAndMockWithSession:session hasError:NO];
    [self.provider createPaymentConsentAndConfirmIntentWithPaymentMethod:[self emptyPaymentMethod]
                                                                  device:nil];
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
    [self.provider createPaymentConsentAndConfirmIntentWithPaymentMethod:[self emptyPaymentMethod]
                                                                  device:nil];
    OCMVerify(times(1), [self.providerMock completeWithResponse:nil error:self.error]);
}

- (void)testCreatePaymentConsentAndConfirmIntentWithRecurringWithIntentSession {
    AWXRecurringWithIntentSession *session = [AWXRecurringWithIntentSession new];
    AWXPaymentMethod *paymentMethod = [self emptyPaymentMethod];
    paymentMethod.additionalParams = [NSDictionary dictionary];
    session.requiresCVC = YES;
    [self createProviderAndMockWithSession:session];
    [self.provider createPaymentConsentAndConfirmIntentWithPaymentMethod:paymentMethod
                                                                  device:nil];

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

- (void)testCreatePaymentConsentAndConfirmIntentWithRecurringWithIntentSessionAndCard {
    AWXRecurringWithIntentSession *session = [AWXRecurringWithIntentSession new];
    session.requiresCVC = YES;
    [self createProviderAndMockWithSession:session];
    AWXPaymentMethod *paymentMethod = [[AWXPaymentMethod alloc] initWithType:AWXCardKey id:nil billing:nil card:nil additionalParams:nil customerId:nil];
    [self.provider createPaymentConsentAndConfirmIntentWithPaymentMethod:paymentMethod
                                                                  device:nil];

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
                                                               device:[OCMArg any]
                                                            returnURL:[OCMArg any]
                                                          autoCapture:YES
                                                           completion:([OCMArg invokeBlockWithArgs:self.response, self.error, nil])]);
}

- (void)testActionLoggingWithPaymentMethod {
    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    AWXPaymentMethodType *paymentMethod = [[AWXPaymentMethodType alloc] initWithName:@"card" displayName:nil transactionMode:nil flows:nil transactionCurrencies:nil active:NO resources:nil cardSchemes:nil];
    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:spy session:[AWXOneOffSession new] paymentMethodType:paymentMethod];
    AWXConfirmPaymentIntentResponse *response = [[AWXConfirmPaymentIntentResponse alloc] initWithCurrency:nil amount:nil status:nil nextAction:nil latestPaymentAttempt:nil];
    [provider completeWithResponse:response error:nil];
    OCMVerify(times(1), [_logger logActionWithName:@"payment_success" additionalInfo:@{@"paymentMethod": @"card"}]);
}

- (void)testActionLoggingWithoutPaymentMethod {
    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:spy session:[AWXOneOffSession new] paymentMethodType:[self emptyPaymentMethodType]];
    AWXConfirmPaymentIntentResponse *response = [[AWXConfirmPaymentIntentResponse alloc] initWithCurrency:nil amount:nil status:nil nextAction:nil latestPaymentAttempt:nil];
    [provider completeWithResponse:response error:nil];
    OCMVerify(times(1), [_logger logActionWithName:@"payment_success"]);
}

- (void)testCompleteWithResponseWithPaymentConsentId {
    id mockDelegateSpy = OCMClassMock([AWXProviderDelegateSpy class]);
    AWXPaymentMethod *paymentMethod = [[AWXPaymentMethod alloc] initWithType:AWXCardKey id:nil billing:nil card:nil additionalParams:nil customerId:nil];
    AWXPaymentConsent *paymentConsent = [[AWXPaymentConsent alloc] initWithId:@"consentId" requestId:nil customerId:nil status:nil paymentMethod:nil nextTriggeredBy:nil merchantTriggerReason:nil createdAt:nil updatedAt:nil clientSecret:nil];
    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:mockDelegateSpy session:[AWXOneOffSession new] paymentMethodType:[self emptyPaymentMethodType]];

    [provider confirmPaymentIntentWithPaymentMethod:paymentMethod
                                     paymentConsent:paymentConsent
                                             device:nil];
    [provider completeWithResponse:[[AWXConfirmPaymentIntentResponse alloc] initWithCurrency:nil amount:nil status:nil nextAction:nil latestPaymentAttempt:nil] error:nil];
    OCMVerify(times(1), [mockDelegateSpy provider:provider didCompleteWithPaymentConsentId:@"consentId"]);
}

- (void)testCompleteWithResponseWhenHasNextAction {
    AWXProviderDelegateEmpty *spy = [AWXProviderDelegateEmpty new];
    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:spy session:[AWXOneOffSession new] paymentMethodType:[[AWXPaymentMethodType alloc] initWithName:nil displayName:nil transactionMode:nil flows:nil transactionCurrencies:nil active:NO resources:nil cardSchemes:nil]];
    id mockHandler = OCMClassMock([AWXNextActionHandler class]);
    OCMStub([mockHandler initWithDelegate:[OCMArg any] session:[OCMArg any]]).andReturn(mockHandler);
    OCMStub([mockHandler alloc]).andReturn(mockHandler);

    AWXConfirmPaymentIntentResponse *response = [AWXConfirmPaymentIntentResponse decodeFromJSON:[AWXTestUtils jsonNamed:@"ConfirmPaymentIntent"]];
    [provider completeWithResponse:response error:nil];

    OCMVerify(times(1), [mockHandler handleNextAction:[OCMArg any]]);
}

- (void)createProviderAndMockWithSession:(AWXSession *)session {
    [self createProviderAndMockWithSession:session hasError:YES];
}

- (void)createProviderAndMockWithSession:(AWXSession *)session hasError:(BOOL)hasError {
    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:spy session:session];
    id providerMock = OCMPartialMock(provider);

    AWXConfirmPaymentIntentResponse *response = [[AWXConfirmPaymentIntentResponse alloc] initWithCurrency:nil amount:nil status:nil nextAction:nil latestPaymentAttempt:nil];
    NSError *error = [NSError errorWithDomain:@"Domain" code:-1 userInfo:nil];
    OCMStub([providerMock confirmPaymentIntentWithPaymentMethod:[OCMArg any]
                                                 paymentConsent:[OCMArg any]
                                                         device:[OCMArg any]
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
                                              device:[OCMArg any]
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

- (void)testObjcAmountFromValidAmount {
    // Given
    AWXConfirmPaymentIntentResponse *response = [[AWXConfirmPaymentIntentResponse alloc] initWithCurrency:nil amount:nil status:nil nextAction:nil latestPaymentAttempt:nil];
    [response setAmount:@123.45];

    // When
    NSNumber *amount = response.objcAmount;

    // Then
    XCTAssertEqualObjects(amount, @123.45);
}

- (void)testObjcAmountFromNilAmount {
    // Given
    AWXConfirmPaymentIntentResponse *response = [[AWXConfirmPaymentIntentResponse alloc] initWithCurrency:nil amount:nil status:nil nextAction:nil latestPaymentAttempt:nil];
    [response setAmount:nil];

    // When
    NSNumber *amount = response.objcAmount;

    // Then
    XCTAssertNil(amount);
}

- (void)testDecodeFromJSONSuccess {
    // Given
    NSDictionary *json = @{
        @"currency": @"USD",
        @"amount": @100.0,
        @"status": @"success",
        @"next_action": [NSNull null], // Assuming a nullable type here
        @"latest_payment_attempt": [NSNull null] // Assuming a nullable type here
    };

    // When
    AWXConfirmPaymentIntentResponse *response = [AWXConfirmPaymentIntentResponse decodeFromJSON:json];

    // Then
    XCTAssertNotNil(response);
    XCTAssertEqualObjects(response.currency, @"USD");
    XCTAssertEqualObjects(response.objcAmount, @100.0);
    XCTAssertEqualObjects(response.status, @"success");
    XCTAssertNil(response.nextAction);
    XCTAssertNil(response.latestPaymentAttempt);
}

- (void)testDecodeFromJSONFailure {
    // Given
    NSDictionary *invalidJSON = @{};

    // When
    AWXConfirmPaymentIntentResponse *response = [AWXConfirmPaymentIntentResponse decodeFromJSON:invalidJSON];

    // Then
    XCTAssertNotNil(response); // Ensure that even if decoding fails, we return an initialized object
    XCTAssertNil(response.currency);
    XCTAssertNil(response.objcAmount);
    XCTAssertNil(response.status);
    XCTAssertNil(response.nextAction);
    XCTAssertNil(response.latestPaymentAttempt);
}

- (void)testParseErrorFromValidJSON {
    // Given
    NSString *jsonString = @"{\"message\":\"An error occurred\",\"code\":\"1234\"}";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    // When
    AWXAPIErrorResponse *errorResponse = [AWXConfirmPaymentIntentResponse parseError:jsonData];

    // Then
    XCTAssertNotNil(errorResponse);
    XCTAssertEqualObjects(errorResponse.message, @"An error occurred");
    XCTAssertEqualObjects(errorResponse.code, @"1234");
}

- (void)testParseErrorFromInvalidJSON {
    // Given
    NSString *invalidJsonString = @"{";
    NSData *jsonData = [invalidJsonString dataUsingEncoding:NSUTF8StringEncoding];

    // When
    AWXAPIErrorResponse *errorResponse = [AWXConfirmPaymentIntentResponse parseError:jsonData];

    // Then
    XCTAssertNil(errorResponse);
}

- (void)testParseErrorFromValidJSONWithoutMessageAndCode {
    // Given
    NSString *jsonString = @"{}";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    // When
    AWXAPIErrorResponse *errorResponse = [AWXConfirmPaymentIntentResponse parseError:jsonData];

    // Then
    XCTAssertNotNil(errorResponse);
    XCTAssertNil(errorResponse.message);
    XCTAssertNil(errorResponse.code);
}

- (AWXPaymentMethodType *)emptyPaymentMethodType {
    AWXPaymentMethodType *type = [[AWXPaymentMethodType alloc] initWithName:nil displayName:nil transactionMode:nil flows:nil transactionCurrencies:nil active:NO resources:nil cardSchemes:nil];
    return type;
}

- (AWXPaymentMethod *)emptyPaymentMethod {
    AWXPaymentMethod *method = [[AWXPaymentMethod alloc] initWithType:nil id:nil billing:nil card:nil additionalParams:nil customerId:nil];
    return method;
}

@end
