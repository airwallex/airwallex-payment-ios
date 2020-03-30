//
//  AWCardTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWTestUtils.h"
#import "AWCard.h"

@interface AWCardTest : XCTestCase

@end

@implementation AWCardTest

- (void)testCard
{
    AWCard *card = [AWCard parseFromJsonDictionary:[AWTestUtils jsonNamed:@"card"]];
    XCTAssertNotNil(card);
    XCTAssertNotNil(card.expiryYear);
    XCTAssertNotNil(card.expiryMonth);
    XCTAssertNotNil(card.name);
    XCTAssertNotNil(card.bin);
    XCTAssertNotNil(card.last4);
    XCTAssertNotNil(card.brand);
    XCTAssertNotNil(card.fingerprint);;
}

@end
