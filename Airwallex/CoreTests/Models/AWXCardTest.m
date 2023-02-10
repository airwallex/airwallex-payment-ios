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

- (void)testValidation {
    AWXCard *card = [AWXCard new];
    card.number = @"12345";
    XCTAssertEqualObjects([card validate], @"Invalid card number");
}

@end
