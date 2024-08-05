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
        @"transaction_currencies": @[],
        @"country_codes": @[],
        @"flows": @[],
        @"card_schemes": @[],
        @"active": @YES,
        @"transaction_mode": @"transactionMode",
        @"resources": @{
            @"has_schema": @YES
        }
    }];

    AWXPaymentMethodType *mismatchTransactionMode = [AWXPaymentMethodType new];
    [mismatchTransactionMode setValue:@"mismatchTransactionMode" forKey:@"name"];
    [mismatchTransactionMode setValue:@"anotherTransactionMode" forKey:@"transactionMode"];

    AWXPaymentMethodType *unsupportedMethod = [AWXPaymentMethodType new];

    [unsupportedMethod setValue:@"googlepay" forKey:@"name"];
    [unsupportedMethod setValue:@"Google Pay" forKey:@"displayName"];
    [unsupportedMethod setValue:@"transactionMode" forKey:@"transactionMode"];

    AWXPaymentMethodType *methodWithoutDisplayName = [AWXPaymentMethodType new];
    [methodWithoutDisplayName setValue:@"card" forKey:@"name"];
    [methodWithoutDisplayName setValue:@"transactionMode" forKey:@"transactionMode"];

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
    [validMethod setValue:@"validMethod" forKey:@"name"];
    [validMethod setValue:@"transactionMode" forKey:@"transactionMode"];

    NSArray<AWXPaymentMethodType *> *methodTypes = @[
        validMethod
    ];

    NSArray<AWXPaymentMethodType *> *filtered = [sessionMock filteredPaymentMethodTypes:methodTypes];

    XCTAssertEqual(filtered.count, 0);
}

@end
