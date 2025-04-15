//
//  AWXSessionInternalTest.m
//  CoreTests
//
//  Created by Jin Wang on 5/4/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"
#import "AWXPaymentMethod.h"
#import "AWXSession+Internal.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface AWXSessionInternalTest : XCTestCase

@end

@implementation AWXSessionInternalTest

- (void)testShouldFilterOutMismatchTransactionModeAndUnsupportedTypes {
    AWXSession *session = [AWXSession new];
    AWXSession *sessionMock = OCMPartialMock(session);

    OCMStub([sessionMock transactionMode]).andReturn(@"transactionMode");

    AWXPaymentMethodType *validMethod = [AWXPaymentMethodType decodeFromJSON:@{
        @"name": @"validMethod",
        @"display_name": @"Valid Method",
        @"transaction_mode": @"transactionMode",
        @"resources": @{
            @"has_schema": @"true"
        }
    }];

    AWXPaymentMethodType *mismatchTransactionMode = [AWXPaymentMethodType new];
    mismatchTransactionMode.name = @"mismatchTransactionMode";
    mismatchTransactionMode.transactionMode = @"anotherTransactionMode";

    AWXPaymentMethodType *unsupportedMethod = [AWXPaymentMethodType new];
    unsupportedMethod.name = @"googlepay";
    unsupportedMethod.displayName = @"Google Pay";
    unsupportedMethod.transactionMode = @"transactionMode";

    AWXPaymentMethodType *methodWithoutDisplayName = [AWXPaymentMethodType new];
    methodWithoutDisplayName.name = @"card";
    methodWithoutDisplayName.transactionMode = @"transactionMode";

    NSArray<AWXPaymentMethodType *> *methodTypes = @[
        validMethod,
        mismatchTransactionMode,
        unsupportedMethod,
        methodWithoutDisplayName
    ];

    NSArray<AWXPaymentMethodType *> *filtered = [sessionMock filteredPaymentMethodTypes:methodTypes];

    XCTAssertEqual(filtered.count, 1);
    XCTAssertEqualObjects(filtered[0], validMethod);
}

- (void)testShouldFilterOutWhenProviderCannotHandleSession {
    AWXSession *session = [AWXSession new];
    AWXSession *sessionMock = OCMPartialMock(session);

    OCMStub([sessionMock transactionMode]).andReturn(@"transactionMode");

    id classMock = OCMClassMock([AWXDefaultProvider class]);
    OCMStub([classMock canHandleSession:[OCMArg any] paymentMethod:[OCMArg any]]).andReturn(NO);

    AWXPaymentMethodType *validMethod = [AWXPaymentMethodType new];
    validMethod.name = @"validMethod";
    validMethod.transactionMode = @"transactionMode";

    NSArray<AWXPaymentMethodType *> *methodTypes = @[
        validMethod
    ];

    NSArray<AWXPaymentMethodType *> *filtered = [sessionMock filteredPaymentMethodTypes:methodTypes];

    XCTAssertEqual(filtered.count, 0);
}

@end
