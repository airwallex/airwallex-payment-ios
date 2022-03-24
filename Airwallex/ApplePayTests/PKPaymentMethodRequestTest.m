//
//  PKPaymentMethodRequestTest.m
//  ApplePayTests
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "PKPaymentMethod+Request.h"

@interface PKPaymentMethodRequestTest : XCTestCase

@property (nonatomic, strong) PKPaymentMethod *method;
@property (nonatomic, strong) PKPaymentMethod *methodMock;

@end

@implementation PKPaymentMethodRequestTest

- (void)setUp
{
    self.method = [PKPaymentMethod new];
    self.methodMock = OCMPartialMock(self.method);
}

- (void)testTypeNameForRequestCredit
{
    OCMStub([self.methodMock type]).andReturn(PKPaymentMethodTypeCredit);
    XCTAssertEqualObjects([self.method typeNameForRequest], @"credit");
}

- (void)testTypeNameForRequestDebit
{
    OCMStub([self.methodMock type]).andReturn(PKPaymentMethodTypeDebit);
    XCTAssertEqualObjects([self.method typeNameForRequest], @"debit");
}

- (void)testTypeNameForRequestStore
{
    OCMStub([self.methodMock type]).andReturn(PKPaymentMethodTypeStore);
    XCTAssertEqualObjects([self.method typeNameForRequest], @"store");
}

- (void)testTypeNameForRequestPrepaid
{
    OCMStub([self.methodMock type]).andReturn(PKPaymentMethodTypePrepaid);
    XCTAssertEqualObjects([self.method typeNameForRequest], @"prepaid");
}

- (void)testTypeNameForRequestEMoney
{
    OCMStub([self.methodMock type]).andReturn(PKPaymentMethodTypeEMoney);
    XCTAssertEqualObjects([self.method typeNameForRequest], @"emoney");
}

- (void)testTypeNameForRequestUnknown
{
    OCMStub([self.methodMock type]).andReturn(PKPaymentMethodTypeUnknown);
    XCTAssertEqualObjects([self.method typeNameForRequest], @"unknown");
}

@end
