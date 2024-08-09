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

    AWXPaymentMethodType *mismatchTransactionMode = [[AWXPaymentMethodType alloc] initWithName:@"mismatchTransactionMode" displayName:nil transactionMode:@"anotherTransactionMode" flows:nil transactionCurrencies:nil active:NO resources:nil cardSchemes:nil];

    AWXPaymentMethodType *unsupportedMethod = [[AWXPaymentMethodType alloc] initWithName:@"googlepay" displayName:@"Google Pay" transactionMode:@"transactionMode" flows:nil transactionCurrencies:nil active:NO resources:nil cardSchemes:nil];

    AWXPaymentMethodType *methodWithoutDisplayName = [[AWXPaymentMethodType alloc] initWithName:@"card" displayName:nil transactionMode:@"transactionMode" flows:nil transactionCurrencies:nil active:NO resources:nil cardSchemes:nil];

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

    AWXPaymentMethodType *validMethod = [[AWXPaymentMethodType alloc] initWithName:@"validMethod" displayName:nil transactionMode:@"transactionMode" flows:nil transactionCurrencies:nil active:NO resources:nil cardSchemes:nil];

    NSArray<AWXPaymentMethodType *> *methodTypes = @[
        validMethod
    ];

    NSArray<AWXPaymentMethodType *> *filtered = [sessionMock filteredPaymentMethodTypes:methodTypes];

    XCTAssertEqual(filtered.count, 0);
}

@end
