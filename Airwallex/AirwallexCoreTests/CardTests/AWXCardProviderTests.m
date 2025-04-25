//
//  AWXCardProviderTests.m
//  CardTests
//
//  Created by Hector.Huang on 2022/11/9.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXCardCVCViewController.h"
#import "AWXCardProvider.h"
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
                            withCompletionHandler:[OCMArg any]]);
}

- (void)testConfirmPaymentIntentWithPanPaymentConsent {
    id mockViewController = OCMClassMock([UIViewController class]);
    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    spy.hostVC = mockViewController;
    AWXOneOffSession *session = [AWXOneOffSession new];
    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:spy session:session];

    AWXPaymentConsent *consent = [AWXPaymentConsent new];
    AWXPaymentMethod *method = [AWXPaymentMethod new];
    AWXCard *card = [AWXCard new];
    card.numberType = @"PAN";
    method.card = card;
    consent.Id = @"consentID";
    consent.paymentMethod = method;

    [provider confirmPaymentIntentWithPaymentConsent:consent];
    OCMVerify(times(1), [mockViewController presentViewController:[OCMArg isKindOfClass:[UINavigationController class]]
                                                         animated:YES
                                                       completion:nil]);
}

- (void)testConfirmPaymentIntentWithNonPanPaymentConsent {
    AWXAPIClient *client = [self mockAPIClient];
    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    spy.hostVC = [UIViewController new];
    AWXOneOffSession *session = [AWXOneOffSession new];
    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:spy session:session];

    AWXPaymentConsent *consent = [AWXPaymentConsent new];
    consent.Id = @"consentID";

    [provider confirmPaymentIntentWithPaymentConsent:consent];
    OCMVerify(times(1), [client send:[OCMArg checkWithBlock:^BOOL(id obj) {
                                    AWXConfirmPaymentIntentRequest *request = obj;
                                    XCTAssertEqual(request.paymentConsent.Id, @"consentID");
                                    XCTAssertEqual(request.device, self.device);
                                    return YES;
                                }]
                            withCompletionHandler:[OCMArg any]]);
}

- (void)testPaymentResultDelegate {
    id mockViewController = OCMClassMock([UIViewController class]);
    OCMStub([mockViewController dismissViewControllerAnimated:YES completion:[OCMArg invokeBlockWithArgs:nil]]);
    id mockDelegate = OCMClassMock([AWXProviderDelegateSpy class]);
    AWXOneOffSession *session = [AWXOneOffSession new];
    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:mockDelegate session:session];

    [provider paymentViewController:mockViewController didCompleteWithStatus:AirwallexPaymentStatusSuccess error:nil];
    OCMVerify(times(1), [mockViewController dismissViewControllerAnimated:YES completion:[OCMArg any]]);
    OCMVerify(times(1), [mockDelegate provider:provider didCompleteWithStatus:AirwallexPaymentStatusSuccess error:nil]);

    [provider paymentViewController:mockViewController didCompleteWithPaymentConsentId:@"consentID"];
    OCMVerify(times(1), [mockDelegate provider:provider didCompleteWithPaymentConsentId:@"consentID"]);
}

- (void)testClose {
    id mockDelegate = OCMClassMock([AWXProviderDelegateSpy class]);
    AWXOneOffSession *session = [AWXOneOffSession new];
    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:mockDelegate session:session];
    AWXCardCVCViewController *paymentVC = [[AWXCardCVCViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:paymentVC];

    // Set up the mock to return a hostViewController
    id hostVCMock = OCMClassMock([UIViewController class]);
    OCMStub([mockDelegate hostViewController]).andReturn(hostVCMock);
    OCMStub([hostVCMock presentedViewController]).andReturn(navController);

    // Set expectations for delegate method calls
    OCMExpect([mockDelegate provider:provider didCompleteWithStatus:AirwallexPaymentStatusCancel error:nil]);

    // Call the method
    [provider performSelector:@selector(close)];

    // Verify the results with a small delay to allow for animation completion block
    XCTestExpectation *expectation = [self expectationWithDescription:@"Dismissal"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        OCMVerifyAll(mockDelegate);
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
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
    OCMStub([apiClientMock send:[OCMArg isKindOfClass:[AWXCreatePaymentMethodRequest class]] withCompletionHandler:([OCMArg invokeBlockWithArgs:response, [NSNull null], nil])]);

    id spy = OCMClassMock([AWXProviderDelegateSpy class]);
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.autoCapture = YES;
    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:spy session:session];
    id providerSpy = OCMPartialMock(provider);

    AWXCard *card = [AWXCard new];
    AWXPlaceDetails *billing = [AWXPlaceDetails new];

    [provider confirmPaymentIntentWithCard:card billing:billing saveCard:YES];

    OCMVerify(times(1), [providerSpy createPaymentConsentAndConfirmIntentWithPaymentMethod:[OCMArg any]]);
}

- (void)testConfirmPaymentIntentWithCardWithError {
    id apiClientMock = OCMClassMock([AWXAPIClient class]);
    OCMStub([apiClientMock initWithConfiguration:[OCMArg any]]).andReturn(apiClientMock);
    OCMStub([apiClientMock alloc]).andReturn(apiClientMock);

    AWXCreatePaymentMethodResponse *response = [AWXCreatePaymentMethodResponse new];

    NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"error."}];
    OCMStub([apiClientMock send:[OCMArg isKindOfClass:[AWXCreatePaymentMethodRequest class]] withCompletionHandler:([OCMArg invokeBlockWithArgs:response, error, nil])]);

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
