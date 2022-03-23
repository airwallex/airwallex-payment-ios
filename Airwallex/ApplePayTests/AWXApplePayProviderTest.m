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

@interface AWXApplePayProviderTest : XCTestCase

@end

@implementation AWXApplePayProviderTest

- (void)testShouldReturnNOWithRecurringSession {
    AWXSession *session = [AWXRecurringSession new];
    XCTAssertFalse([AWXApplePayProvider canHandleSession:session]);
}

- (void)testShouldReturnNOWithRecurringWithIntentSession {
    AWXSession *session = [AWXRecurringWithIntentSession new];
    XCTAssertFalse([AWXApplePayProvider canHandleSession:session]);
}

- (void)testShouldReturnNOWithoutApplePayOptions {
    AWXSession *session = [AWXOneOffSession new];
    session.applePayOptions = nil;
    XCTAssertFalse([AWXApplePayProvider canHandleSession:session]);
}

- (void)testShouldReturnNOWhenDeviceCheckFailed {
    AWXSession *session = [AWXOneOffSession new];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    id classMock = OCMClassMock([PKPaymentAuthorizationController class]);
    OCMStub([classMock canMakePaymentsUsingNetworks:[OCMArg any] capabilities:0])
        .ignoringNonObjectArgs()
        .andReturn(NO);
    
    XCTAssertFalse([AWXApplePayProvider canHandleSession:session]);
}

- (void)testShouldReturnYES {
    AWXSession *session = [AWXOneOffSession new];
    session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    id classMock = OCMClassMock([PKPaymentAuthorizationController class]);
    OCMStub([classMock canMakePaymentsUsingNetworks:[OCMArg any] capabilities:0])
        .ignoringNonObjectArgs()
        .andReturn(YES);
    
    XCTAssertTrue([AWXApplePayProvider canHandleSession:session]);
}

@end
