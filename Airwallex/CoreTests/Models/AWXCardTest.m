//
//  AWXCardTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXTestUtils.h"
#import "Coretests-Swift.h"
#import <XCTest/XCTest.h>
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

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
    AWXCard *card = [[AWXCard alloc] initWithNumber:@"12345" expiryMonth:nil expiryYear:nil name:nil cvc:nil bin:nil last4:nil brand:nil country:nil funding:nil fingerprint:nil cvcCheck:nil avsCheck:nil numberType:nil];
    XCTAssertEqualObjects([card validateAndReturnError], @"Invalid card number");
}

@end
