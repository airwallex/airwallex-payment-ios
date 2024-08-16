//
//  AWXCardProviderTests.m
//  CardTests
//
//  Created by Hector.Huang on 2022/11/9.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXCardProvider.h"
#import "AWXCardViewController.h"
#import "AWXDevice.h"
#import "AWXPaymentConsent.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodOptions.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXProviderDelegateSpy.h"
#import "AWXSession.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface AWXCardProviderTests : XCTestCase

@property (nonatomic, strong) AWXDevice *device;
@property (nonatomic, strong) AWXSession *session;
@property (nonatomic, strong) AWXPaymentMethodType *paymentMethod;

@end

@interface AWXCardProvider ()

- (void)createPaymentMethod:(AWXPaymentMethod *)paymentMethod
                 completion:(AWXRequestHandler)completion;

@end

@implementation AWXCardProviderTests

- (void)setUp {
    AWXDevice *device = [AWXDevice new];
    device.deviceId = @"abcd";
    id mockDevice = OCMClassMock([AWXDevice class]);
    OCMStub([mockDevice deviceWithRiskSessionId]).andReturn(device);
    self.device = device;
    self.session = [AWXSession new];
    self.paymentMethod = [AWXPaymentMethodType new];
}

- (void)testCanHandleSessionWhenCardSchemesIsNull {
    XCTAssertFalse([AWXCardProvider canHandleSession:_session paymentMethod:_paymentMethod]);
}

- (void)testCanHandleSessionWhenCardSchemesIsEmpty {
    _paymentMethod.cardSchemes = [NSArray new];
    XCTAssertFalse([AWXCardProvider canHandleSession:_session paymentMethod:_paymentMethod]);
}

- (void)testHandleFlow {
    id spy = OCMClassMock([AWXProviderDelegateSpy class]);
    AWXOneOffSession *session = [AWXOneOffSession new];
    AWXPaymentMethodType *paymentMethod = [AWXPaymentMethodType new];
    session.autoCapture = YES;
    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:spy session:session paymentMethodType:paymentMethod];
    [provider handleFlow];
    OCMVerify(times(1), [spy provider:provider
                            shouldPresentViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                                XCTAssertTrue([obj isKindOfClass:AWXCardViewController.class]);
                                return true;
                            }]
                                         forceToDismiss:NO
                                          withAnimation:YES]);
}

- (void)testCanHandleSessionWhenCardSchemesIsNotEmpty {
    AWXCardScheme *amexScheme = [AWXCardScheme new];
    amexScheme.name = @"amex";
    _paymentMethod.cardSchemes = @[amexScheme];
    XCTAssertTrue([AWXCardProvider canHandleSession:_session paymentMethod:_paymentMethod]);
}

- (void)testConfirmPaymentIntentWithPaymentConsentId {
    AWXAPIClient *client = [self mockAPIClient];

    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.autoCapture = YES;
    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:spy session:session];

    [provider confirmPaymentIntentWithPaymentConsentId:@"consentID"];

    OCMVerify(times(1), [client send:[OCMArg checkWithBlock:^BOOL(id obj) {
                                    AWXConfirmPaymentIntentRequest *request = obj;
                                    XCTAssert(request.options.cardOptions.autoCapture);
                                    XCTAssertEqual(request.paymentConsent.Id, @"consentID");
                                    XCTAssertEqual(request.device, self.device);
                                    return YES;
                                }]
                             handler:[OCMArg any]]);
}

- (void)testConfirmPaymentIntentWithCardNoSave {
    [self mockAPIClient];

    id spy = OCMClassMock([AWXProviderDelegateSpy class]);
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.autoCapture = YES;
    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:spy session:session];
    id providerSpy = OCMPartialMock(provider);

    AWXCard *card = [AWXCard new];
    AWXPlaceDetails *billing = [AWXPlaceDetails new];

    [providerSpy confirmPaymentIntentWithCard:card billing:billing saveCard:NO];

    OCMVerify(times(2), [spy providerDidStartRequest:provider]);
}

- (void)testConfirmPaymentIntentWithCard {
    id apiClientMock = OCMClassMock([AWXAPIClient class]);
    OCMStub([apiClientMock initWithConfiguration:[OCMArg any]]).andReturn(apiClientMock);
    OCMStub([apiClientMock alloc]).andReturn(apiClientMock);

    AWXCreatePaymentMethodResponse *response = [AWXCreatePaymentMethodResponse new];

    //    NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"error."}];
    OCMStub([apiClientMock send:[OCMArg isKindOfClass:[AWXCreatePaymentMethodRequest class]] handler:([OCMArg invokeBlockWithArgs:response, [NSNull null], nil])]);

    id spy = OCMClassMock([AWXProviderDelegateSpy class]);
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.autoCapture = YES;
    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:spy session:session];
    id providerSpy = OCMPartialMock(provider);

    AWXCard *card = [AWXCard new];
    AWXPlaceDetails *billing = [AWXPlaceDetails new];

    [provider confirmPaymentIntentWithCard:card billing:billing saveCard:YES];

    OCMVerify(times(1), [providerSpy createPaymentConsentAndConfirmIntentWithPaymentMethod:[OCMArg any] device:_device]);
}

- (void)testConfirmPaymentIntentWithCardWithError {
    id apiClientMock = OCMClassMock([AWXAPIClient class]);
    OCMStub([apiClientMock initWithConfiguration:[OCMArg any]]).andReturn(apiClientMock);
    OCMStub([apiClientMock alloc]).andReturn(apiClientMock);

    AWXCreatePaymentMethodResponse *response = [AWXCreatePaymentMethodResponse new];

    NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"error."}];
    OCMStub([apiClientMock send:[OCMArg isKindOfClass:[AWXCreatePaymentMethodRequest class]] handler:([OCMArg invokeBlockWithArgs:response, error, nil])]);

    id spy = OCMClassMock([AWXProviderDelegateSpy class]);
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.autoCapture = YES;
    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:spy session:session];

    AWXCard *card = [AWXCard new];
    AWXPlaceDetails *billing = [AWXPlaceDetails new];

    [provider confirmPaymentIntentWithCard:card billing:billing saveCard:YES];

    OCMVerify(times(1), [spy providerDidEndRequest:provider]);
    OCMVerify(times(1), [spy provider:provider didCompleteWithStatus:AirwallexPaymentStatusFailure error:error]);
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
