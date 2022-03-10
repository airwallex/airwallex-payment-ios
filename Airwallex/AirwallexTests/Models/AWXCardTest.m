//
//  AWXCardTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWXTestUtils.h"
#import "AWXCard.h"

@interface AWXCardTest : XCTestCase

@end

@implementation AWXCardTest

- (void)testCard
{
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

@end
