//
//  AWXCardTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXCard.h"
#import "AWXTestUtils.h"
#import <XCTest/XCTest.h>

@interface AWXCardTest : XCTestCase

@end

@implementation AWXCardTest

- (void)testCard {
    AWXCard *card = [AWXCard decodeFromJSON:[AWXTestUtils jsonNamed:@"Card"]];
    XCTAssertNotNil(card);
    XCTAssertNotNil(card.expiryYear);
    XCTAssertNotNil(card.expiryMonth);
    XCTAssertNotNil(card.name);
    XCTAssertNotNil(card.bin);
    XCTAssertNotNil(card.last4);
    XCTAssertNotNil(card.brand);
    XCTAssertNotNil(card.fingerprint);
}

- (void)testCardEncode {
    // Test 1: Card with no properties set - should return empty dictionary
    AWXCard *emptyCard = [AWXCard new];
    NSDictionary *emptyJson = [emptyCard encodeToJSON];
    XCTAssertEqual(emptyJson.count, 0, @"Empty card should encode to empty dictionary");

    // Test 2: Card with all properties set - should include all properties
    AWXCard *fullCard = [AWXCard new];
    fullCard.number = @"4242424242424242";
    fullCard.expiryMonth = @"12";
    fullCard.expiryYear = @"25";
    fullCard.name = @"Test User";
    fullCard.cvc = @"123";

    NSDictionary *fullJson = [fullCard encodeToJSON];

    // Verify all properties are included with correct values
    XCTAssertEqualObjects(fullJson[@"number"], @"4242424242424242");
    XCTAssertEqualObjects(fullJson[@"expiry_month"], @"12");
    XCTAssertEqualObjects(fullJson[@"expiry_year"], @"25");
    XCTAssertEqualObjects(fullJson[@"name"], @"Test User");
    XCTAssertEqualObjects(fullJson[@"cvc"], @"123");
    XCTAssertEqual(fullJson.count, 5, @"Full card should encode all 5 properties");

    // Test 3: Test individual property encoding behavior

    // Number property
    AWXCard *numberCard = [AWXCard new];
    numberCard.number = @"4111111111111111";
    NSDictionary *numberJson = [numberCard encodeToJSON];
    XCTAssertEqualObjects(numberJson[@"number"], @"4111111111111111");
    XCTAssertEqual(numberJson.count, 1);

    // ExpiryMonth property
    AWXCard *monthCard = [AWXCard new];
    monthCard.expiryMonth = @"06";
    NSDictionary *monthJson = [monthCard encodeToJSON];
    XCTAssertEqualObjects(monthJson[@"expiry_month"], @"06");
    XCTAssertEqual(monthJson.count, 1);

    // ExpiryYear property
    AWXCard *yearCard = [AWXCard new];
    yearCard.expiryYear = @"28";
    NSDictionary *yearJson = [yearCard encodeToJSON];
    XCTAssertEqualObjects(yearJson[@"expiry_year"], @"28");
    XCTAssertEqual(yearJson.count, 1);

    // Name property
    AWXCard *nameCard = [AWXCard new];
    nameCard.name = @"John Doe";
    NSDictionary *nameJson = [nameCard encodeToJSON];
    XCTAssertEqualObjects(nameJson[@"name"], @"John Doe");
    XCTAssertEqual(nameJson.count, 1);

    // CVC property
    AWXCard *cvcCard = [AWXCard new];
    cvcCard.cvc = @"789";
    NSDictionary *cvcJson = [cvcCard encodeToJSON];
    XCTAssertEqualObjects(cvcJson[@"cvc"], @"789");
    XCTAssertEqual(cvcJson.count, 1);
}

- (void)testValidationWhenInvalidCardNumber {
    AWXCard *card = [AWXCard new];
    card.number = @"12345";
    XCTAssertEqualObjects([card validate], @"Invalid card number");
}

- (void)testValidationWhenInvalidCvc {
    AWXCard *card = [AWXCard new];
    card.number = @"378282246310005";
    card.name = @"name";
    card.expiryYear = @"25";
    card.expiryMonth = @"8";
    card.cvc = @"123";
    XCTAssertEqualObjects([card validate], @"Invalid CVC / CVV");
}

@end
