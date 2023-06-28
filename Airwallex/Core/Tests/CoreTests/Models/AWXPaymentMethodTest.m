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
    NSData *data = [AWXTestUtils dataFromJsonFile:@"PaymentMethod"];
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod decodeFromJSONData:data];

    XCTAssertNotNil(paymentMethod);
    XCTAssertNotNil(paymentMethod.Id);
    XCTAssertNotNil(paymentMethod.type);
    XCTAssertNotNil(paymentMethod.card);
    XCTAssertNotNil(paymentMethod.billing);
}

- (void)testPaymentMethodType {
    NSData *data = [AWXTestUtils dataFromJsonFile:@"PaymentMethodType"];
    AWXPaymentMethodType *paymentMethodType = [AWXPaymentMethodType decodeFromJSONData:data];

    XCTAssertEqualObjects(paymentMethodType.name, @"card");
    XCTAssertEqualObjects(paymentMethodType.displayName, @"Card");
    XCTAssertEqualObjects(paymentMethodType.transactionMode, @"oneoff");
    XCTAssertEqual(paymentMethodType.flows, [NSArray new]);
    NSArray *currencies = @[@"CHF", @"MXN", @"*", @"NOK", @"EGP"];
    XCTAssertEqualObjects(paymentMethodType.transactionCurrencies, currencies);
    XCTAssertTrue(paymentMethodType.active);
    XCTAssertFalse(paymentMethodType.hasSchema);
    AWXCardScheme *amexScheme = paymentMethodType.cardSchemes[3];
    XCTAssertEqualObjects(amexScheme.name, @"amex");
}

@end
