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
    XCTAssertNotNil(paymentMethod.Id);
    XCTAssertNotNil(paymentMethod.type);
    XCTAssertNotNil(paymentMethod.card);
    XCTAssertNotNil(paymentMethod.billing);
}

- (void)testPaymentMethodType {
    AWXPaymentMethodType *paymentMethodType = [AWXPaymentMethodType decodeFromJSON:[AWXTestUtils jsonNamed:@"PaymentMethodType"]];
    XCTAssertEqualObjects(paymentMethodType.name, @"card");
    XCTAssertEqualObjects(paymentMethodType.displayName, @"Card");
    XCTAssertEqualObjects(paymentMethodType.transactionMode, AWXPaymentTransactionModeOneOff);
    XCTAssertEqual(paymentMethodType.flows, [NSArray new]);
    NSArray *currencies = @[@"CHF", @"MXN", @"*", @"NOK", @"EGP"];
    XCTAssertEqualObjects(paymentMethodType.transactionCurrencies, currencies);
    XCTAssertTrue(paymentMethodType.active);
    XCTAssertFalse(paymentMethodType.hasSchema);
    AWXCardScheme *amexScheme = paymentMethodType.cardSchemes[3];
    XCTAssertEqualObjects(amexScheme.name, @"amex");
}

- (void)testPaymentMethodEncodeWithId {
    // Test encoding with Id property set
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.Id = @"pm_123456789";
    paymentMethod.type = @"card";

    NSDictionary *json = [paymentMethod encodeToJSON];

    // Verify Id is properly encoded to "id" key
    XCTAssertEqualObjects(json[@"id"], @"pm_123456789");
    XCTAssertEqualObjects(json[@"type"], @"card");
}

- (void)testPaymentMethodEncodeWithoutId {
    // Test encoding without Id property
    AWXPaymentMethod *paymentMethodWithoutId = [AWXPaymentMethod new];
    paymentMethodWithoutId.type = @"card";

    NSDictionary *jsonWithoutId = [paymentMethodWithoutId encodeToJSON];

    // Verify "id" key is not present when Id property is not set
    XCTAssertNil(jsonWithoutId[@"id"]);
    XCTAssertEqualObjects(jsonWithoutId[@"type"], @"card");
}

- (void)testPaymentMethodEncodeWithAllProperties {
    // Test with all properties set
    AWXPaymentMethod *fullPaymentMethod = [AWXPaymentMethod new];
    fullPaymentMethod.Id = @"pm_987654321";
    fullPaymentMethod.type = @"card";
    fullPaymentMethod.customerId = @"cus_123456";

    // Create mock card and billing objects
    AWXCard *card = [AWXCard new];
    card.number = @"4242424242424242";

    AWXPlaceDetails *billing = [AWXPlaceDetails new];

    fullPaymentMethod.card = card;
    fullPaymentMethod.billing = billing;

    NSDictionary *fullJson = [fullPaymentMethod encodeToJSON];

    // Verify all properties are encoded correctly, especially Id
    XCTAssertEqualObjects(fullJson[@"id"], @"pm_987654321");
    XCTAssertEqualObjects(fullJson[@"type"], @"card");
    XCTAssertEqualObjects(fullJson[@"customer_id"], @"cus_123456");
    XCTAssertNotNil(fullJson[@"card"]);
    XCTAssertNotNil(fullJson[@"billing"]);
}

- (void)testPaymentMethodEncodeWithAdditionalParams {
    // Test the behavior of additionalParams in encodeToJSON

    // Test 1: With card property set but no additionalParams
    AWXPaymentMethod *methodWithCard = [AWXPaymentMethod new];
    methodWithCard.type = @"card";

    AWXCard *card = [AWXCard new];
    card.number = @"4242424242424242";
    methodWithCard.card = card;

    NSDictionary *jsonWithCard = [methodWithCard encodeToJSON];

    // Verify card info is encoded
    XCTAssertNotNil(jsonWithCard[@"card"]);
    XCTAssertEqualObjects(jsonWithCard[@"card"], @{@"number": @"4242424242424242"});

    // Test 2: With both card and additionalParams set with type="card"
    AWXPaymentMethod *methodWithBoth = [AWXPaymentMethod new];
    methodWithBoth.type = @"card";

    AWXCard *card2 = [AWXCard new];
    card2.number = @"4242424242424242";
    methodWithBoth.card = card2;

    // Add additionalParams
    NSDictionary *additionalParams = @{@"save": @YES, @"custom_field": @"value"};
    methodWithBoth.additionalParams = additionalParams;

    NSDictionary *jsonWithBoth = [methodWithBoth encodeToJSON];

    // Verify that additionalParams overrides card info when type is "card"
    // This happens because items[@"card"] is set first by card.encodeToJSON,
    // then overwritten by items[self.type] = self.additionalParams when type="card"
    XCTAssertNotNil(jsonWithBoth[@"card"]);
    XCTAssertEqualObjects(jsonWithBoth[@"card"], additionalParams);

    // Test 3: With both card and additionalParams set with a different type
    AWXPaymentMethod *methodWithBothDiffType = [AWXPaymentMethod new];
    methodWithBothDiffType.type = @"alipay";

    AWXCard *card3 = [AWXCard new];
    card3.number = @"4242424242424242";
    methodWithBothDiffType.card = card3;
    methodWithBothDiffType.additionalParams = additionalParams;

    NSDictionary *jsonWithBothDiffType = [methodWithBothDiffType encodeToJSON];

    // Verify both card and additionalParams are included when type is not "card"
    XCTAssertNotNil(jsonWithBothDiffType[@"card"]);
    XCTAssertEqualObjects(jsonWithBothDiffType[@"card"], @{@"number": @"4242424242424242"});
    XCTAssertNotNil(jsonWithBothDiffType[@"alipay"]);
    XCTAssertEqualObjects(jsonWithBothDiffType[@"alipay"], additionalParams);

    // Test 4: With only additionalParams (no card)
    AWXPaymentMethod *methodWithParamsOnly = [AWXPaymentMethod new];
    methodWithParamsOnly.type = @"card";
    methodWithParamsOnly.additionalParams = additionalParams;
    // Intentionally not setting card property

    NSDictionary *jsonWithParamsOnly = [methodWithParamsOnly encodeToJSON];

    // Verify that additionalParams is added using the type as key
    XCTAssertNotNil(jsonWithParamsOnly[@"card"]); // additionalParams with type="card" as key
    XCTAssertEqualObjects(jsonWithParamsOnly[@"card"], additionalParams);
}

@end
