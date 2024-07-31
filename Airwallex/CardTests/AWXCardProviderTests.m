//
//  AWXCardProviderTests.m
//  CardTests
//
//  Created by Hector.Huang on 2022/11/9.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXCardProvider.h"
#import "AWXCardValidator.h"
#import "AWXDefaultProvider+Security.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXProviderDelegateSpy.h"
#import "AWXSession.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#ifdef AirwallexSDK
#import <Card/Card-Swift.h>
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWXCardProviderTests : XCTestCase

@property (nonatomic, strong) AWXSession *session;
@property (nonatomic, strong) AWXPaymentMethodType *paymentMethod;

@end

@interface AWXCardProvider ()

- (void)createPaymentMethod:(AWXPaymentMethod *)paymentMethod
                 completion:(AWXRequestHandler)completion;
- (AWXCardScheme *)getSchemeFrom:(int)type;

@end

@implementation AWXCardProviderTests

- (void)setUp {
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

- (void)testHandleFlowWithCardSchemes {
    id spy = OCMClassMock([AWXProviderDelegateSpy class]);
    AWXOneOffSession *session = [AWXOneOffSession new];
    AWXPaymentMethodType *paymentMethod = [AWXPaymentMethodType new];
    session.autoCapture = YES;

    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:spy session:session paymentMethodType:paymentMethod];

    provider.cardSchemes = @[@(AWXBrandTypeVisa), @(AWXBrandTypeMastercard)];

    [provider handleFlow];

    OCMVerify(times(1), [spy provider:provider
                            shouldPresentViewController:[OCMArg any]
                                         forceToDismiss:NO
                                          withAnimation:YES]);
}

- (void)testGetSchemeFrom {
    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.autoCapture = YES;
    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:spy session:session];
    id providerSpy = OCMPartialMock(provider);

    // Define a dictionary to map card types to their expected scheme names
    NSDictionary<NSNumber *, NSString *> *expectedSchemes = @{
        @(AWXBrandTypeAmex): @"amex",
        @(AWXBrandTypeMastercard): @"mastercard",
        @(AWXBrandTypeVisa): @"visa",
        @(AWXBrandTypeUnionPay): @"unionpay",
        @(AWXBrandTypeJCB): @"jcb",
        @(AWXBrandTypeDinersClub): @"diners",
        @(AWXBrandTypeDiscover): @"discover",
        @(999): @"" // For unknown card type
    };

    [expectedSchemes enumerateKeysAndObjectsUsingBlock:^(NSNumber *type, NSString *expectedName, BOOL *stop) {
        AWXCardScheme *scheme = [provider getSchemeFrom:type.intValue];
        XCTAssertEqualObjects(scheme.name, expectedName, @"Expected scheme.name for type %@ is %@, but got %@", type, expectedName, scheme.name);
    }];
}

- (void)testCanHandleSessionWhenCardSchemesIsNotEmpty {
    AWXCardScheme *amexScheme = [AWXCardScheme new];
    amexScheme.name = @"amex";
    _paymentMethod.cardSchemes = @[amexScheme];
    XCTAssertTrue([AWXCardProvider canHandleSession:_session paymentMethod:_paymentMethod]);
}

- (void)testConfirmPaymentIntentWithPaymentConsentId {
    AWXDevice *device = [AWXDevice new];
    AWXAPIClient *client = [self mockAPIClient];

    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.autoCapture = YES;
    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:spy session:session];
    id providerSpy = OCMPartialMock(provider);

    OCMStub([providerSpy setDevice:([OCMArg invokeBlockWithArgs:device, nil])]);

    [provider confirmPaymentIntentWithPaymentConsentId:@"consentID"];

    OCMVerify(times(1), [client send:[OCMArg checkWithBlock:^BOOL(id obj) {
                                    AWXConfirmPaymentIntentRequest *request = obj;
                                    XCTAssert(request.options.cardOptions.autoCapture);
                                    XCTAssertEqual(request.paymentConsent.Id, @"consentID");
                                    XCTAssertEqual(request.device, device);
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
    AWXDevice *device = [AWXDevice new];

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
    OCMStub([providerSpy setDevice:([OCMArg invokeBlockWithArgs:device, nil])]);

    AWXCard *card = [AWXCard new];
    AWXPlaceDetails *billing = [AWXPlaceDetails new];

    [provider confirmPaymentIntentWithCard:card billing:billing saveCard:YES];

    OCMVerify(times(1), [providerSpy createPaymentConsentAndConfirmIntentWithPaymentMethod:[OCMArg any] device:device]);
}

- (void)testConfirmPaymentIntentWithCardWithError {
    AWXDevice *device = [AWXDevice new];

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
    id providerSpy = OCMPartialMock(provider);
    OCMStub([providerSpy setDevice:([OCMArg invokeBlockWithArgs:device, nil])]);

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
