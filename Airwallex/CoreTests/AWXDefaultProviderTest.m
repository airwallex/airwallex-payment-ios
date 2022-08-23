//
//  AWXDefaultProviderTest.m
//  CoreTests
//
//  Created by Jin Wang on 22/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethod.h"
#import "AWXProviderDelegateSpy.h"
#import "AWXSession.h"
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

@end

NSString *const kProviderKey = @"PROVIDER";
NSString *const kMockKey = @"MOCK";

@implementation AWXDefaultProviderTest

- (void)testCanHandleSessionDefaultImplementation {
    AWXSession *session = [AWXSession new];
    XCTAssertTrue([AWXDefaultProvider canHandleSession:session]);
}

- (void)testConfirmPaymentIntentWithoutCompletionBlock {
    [self createProviderAndMockWithSession:[AWXSession new]];

    [self.provider confirmPaymentIntentWithPaymentMethod:[AWXPaymentMethod new] paymentConsent:nil device:nil];

    OCMVerify(times(1), [self.providerMock confirmPaymentIntentWithPaymentMethod:[OCMArg any]
                                                                  paymentConsent:[OCMArg any]
                                                                          device:[OCMArg any]
                                                                      completion:[OCMArg any]]);
    OCMVerify(times(1), [self.providerMock completeWithResponse:self.response error:self.error]);
}

- (void)testCreatePaymentConsentAndConfirmIntentWithOneOffSession {
    [self createProviderAndMockWithSession:[AWXOneOffSession new]];
    [self.provider createPaymentConsentAndConfirmIntentWithPaymentMethod:[AWXPaymentMethod new]
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
                                                          autoCapture:NO
                                                           completion:([OCMArg invokeBlockWithArgs:self.response, self.error, nil])]);
}

- (void)testCreatePaymentConsentAndConfirmIntentWithRecurringSession {
    AWXRecurringSession *session = [AWXRecurringSession new];
    session.requiresCVC = YES;
    [self createProviderAndMockWithSession:session hasError:NO];
    [self.provider createPaymentConsentAndConfirmIntentWithPaymentMethod:[AWXPaymentMethod new]
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
    [self.provider createPaymentConsentAndConfirmIntentWithPaymentMethod:[AWXPaymentMethod new]
                                                                  device:nil];
    OCMVerify(times(1), [self.providerMock completeWithResponse:nil error:self.error]);
}

- (void)testCreatePaymentConsentAndConfirmIntentWithRecurringWithIntentSession {
    AWXRecurringWithIntentSession *session = [AWXRecurringWithIntentSession new];
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
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
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = AWXCardKey;
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
                                                          autoCapture:NO
                                                           completion:([OCMArg invokeBlockWithArgs:self.response, self.error, nil])]);
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
                                         autoCapture:NO
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

@end
