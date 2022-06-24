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

@interface AWXDefaultProviderTest : XCTestCase

@end

@implementation AWXDefaultProviderTest

- (void)testCanHandleSessionDefaultImplementation {
    AWXSession *session = [AWXSession new];
    XCTAssertTrue([AWXDefaultProvider canHandleSession:session]);
}

- (void)testConfirmPaymentIntentWithoutCompletionBlock {
    AWXSession *session = [AWXSession new];
    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];

    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:spy session:session];
    id providerMock = OCMPartialMock(provider);

    AWXConfirmPaymentIntentResponse *response = [AWXConfirmPaymentIntentResponse new];
    NSError *error = [NSError errorWithDomain:@"Domain" code:-1 userInfo:nil];
    OCMStub([providerMock confirmPaymentIntentWithPaymentMethod:[OCMArg any]
                                                 paymentConsent:[OCMArg any]
                                                         device:[OCMArg any]
                                                     completion:([OCMArg invokeBlockWithArgs:response, error, nil])]);

    [provider confirmPaymentIntentWithPaymentMethod:[AWXPaymentMethod new] paymentConsent:nil device:nil];

    OCMVerify(times(1), [providerMock confirmPaymentIntentWithPaymentMethod:[OCMArg any]
                                                             paymentConsent:[OCMArg any]
                                                                     device:[OCMArg any]
                                                                 completion:[OCMArg any]]);
    OCMVerify(times(1), [providerMock completeWithResponse:response error:error]);
}

@end
