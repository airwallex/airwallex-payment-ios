//
//  AWXPaymentMethodTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWXTestUtils.h"
#import "AWXPaymentMethod.h"

@interface AWXPaymentMethodTest : XCTestCase

@end

@implementation AWXPaymentMethodTest

- (void)testPaymentMethod
{
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod decodeFromJSON:[AWXTestUtils jsonNamed:@"PaymentMethod"]];
    XCTAssertNotNil(paymentMethod);
    XCTAssertNotNil(paymentMethod.Id);
    XCTAssertNotNil(paymentMethod.type);
    XCTAssertNotNil(paymentMethod.card);
    XCTAssertNotNil(paymentMethod.billing);
}

@end
