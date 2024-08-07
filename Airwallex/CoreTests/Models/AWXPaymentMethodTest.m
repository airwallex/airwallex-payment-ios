//
//  AWXPaymentMethodTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethod.h"
#import "AWXTestUtils.h"
#import <XCTest/XCTest.h>

@interface AWXPaymentMethodTest : XCTestCase

@end

@implementation AWXPaymentMethodTest

- (void)testPaymentMethod {
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod decodeFromJSON:[AWXTestUtils jsonNamed:@"PaymentMethod"]];
    XCTAssertNotNil(paymentMethod);
    XCTAssertNotNil(paymentMethod.id);
    XCTAssertNotNil(paymentMethod.type);
    XCTAssertNotNil(paymentMethod.card);
    XCTAssertNotNil(paymentMethod.billing);
}

- (void)testPaymentMethodType {
    NSDictionary *dic = [AWXTestUtils jsonNamed:@"PaymentMethodType"];

    AWXPaymentMethodType *paymentMethodType = [AWXPaymentMethodType decodeFromJSON:dic];
    XCTAssertEqualObjects(paymentMethodType.name, @"card");
    XCTAssertEqualObjects(paymentMethodType.displayName, @"Card");
    XCTAssertEqualObjects(paymentMethodType.transactionMode, @"oneoff");
    XCTAssertEqualObjects(paymentMethodType.flows, [NSArray new]);
    NSArray *currencies = @[@"CHF", @"MXN", @"*", @"NOK", @"EGP"];
    XCTAssertEqualObjects(paymentMethodType.transactionCurrencies, currencies);
    XCTAssertTrue(paymentMethodType.active);
    XCTAssertFalse(paymentMethodType.hasSchema);
    AWXCardScheme *amexScheme = paymentMethodType.cardSchemes[3];
    XCTAssertEqualObjects(amexScheme.name, @"amex");
}

- (void)testPaymentMethodTypeEmpty {
    NSDictionary *dic = @{@"name": @1};

    AWXPaymentMethodType *paymentMethodType = [AWXPaymentMethodType decodeFromJSON:dic];
    XCTAssertNil(paymentMethodType.name);
}

- (void)testAWXCardScheme {
    NSDictionary *dic = @{@"name": @"abc"};

    AWXCardScheme *scheme = [AWXCardScheme decodeFromJSON:dic];
    XCTAssertEqualObjects(scheme.name, @"abc");
}

- (void)testAWXCardSchemeNameEmpty {
    NSDictionary *dic = @{@"name": @1};

    AWXCardScheme *scheme = [AWXCardScheme decodeFromJSON:dic];
    XCTAssertEqualObjects(scheme.name, @"");
}

@end
