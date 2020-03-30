//
//  AWPaymentMethodTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWTestUtils.h"
#import "AWPaymentMethod.h"

@interface AWPaymentMethodTest : XCTestCase

@end

@implementation AWPaymentMethodTest

- (void)testPaymentMethod
{
    AWPaymentMethod *paymentMethod = [AWPaymentMethod parseFromJsonDictionary:[AWTestUtils jsonNamed:@"PaymentMethod"]];
    XCTAssertNotNil(paymentMethod);
    XCTAssertNotNil(paymentMethod.Id);
    XCTAssertNotNil(paymentMethod.type);
    XCTAssertNotNil(paymentMethod.card);
    XCTAssertNotNil(paymentMethod.billing);
    XCTAssertNil(paymentMethod.wechatpay);
}

@end
