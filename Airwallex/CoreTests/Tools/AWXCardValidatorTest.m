//
//  AWXCardValidatorTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXConstants.h"
#import <XCTest/XCTest.h>
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWXCardValidatorTest : XCTestCase

@property (nonatomic, strong) AWXCardValidator *validator;

@end

@implementation AWXCardValidatorTest

@synthesize validator;

- (void)setUp {
    self.validator = [AWXCardValidator shared];
}

- (void)testBrandForCardNumber {
    XCTAssertTrue([validator brandForCardNumber:@"4242424242424242"].type == AWXCardBrandVisa);
    XCTAssertTrue([validator brandForCardNumber:@"4012000300001003"].type == AWXCardBrandVisa);
    XCTAssertTrue([validator brandForCardNumber:@"378282246310005"].type == AWXCardBrandAmex);
    XCTAssertTrue([validator brandForCardNumber:@"6011111111111117"].type == AWXCardBrandDiscover);
    XCTAssertTrue([validator brandForCardNumber:@"3056930009020004"].type == AWXCardBrandDinersClub);
    XCTAssertTrue([validator brandForCardNumber:@"3566002020360505"].type == AWXCardBrandJCB);
    XCTAssertTrue([validator brandForCardNumber:@"6200000000000005"].type == AWXCardBrandUnionPay);
}

- (void)testNameForCardNumber {
    XCTAssertEqualObjects([validator brandForCardNumber:@"5353"].name, @"Mastercard");
    XCTAssertEqualObjects([validator brandForCardNumber:@"378282246310005"].name, @"Amex");
    XCTAssertEqualObjects([validator brandForCardNumber:@"348282246310005"].name, @"Amex");
    XCTAssertEqualObjects([validator brandForCardNumber:@"6228480088888888888"].name, @"UnionPay");
    XCTAssertEqualObjects([validator brandForCardNumber:@"3569599999097585"].name, @"JCB");
    XCTAssertEqualObjects([validator brandForCardNumber:@"36438936438936"].name, @"Diners");
    XCTAssertEqualObjects([validator brandForCardNumber:@"6011016011016011"].name, @"Discover");
}

- (void)testIsValidCardLength {
    XCTAssertTrue([validator isValidCardLength:@"4242424242424242"]);
    XCTAssertFalse([validator isValidCardLength:@"424242424242424"]);
    XCTAssertFalse([validator isValidCardLength:@"0000000000000000"]);
}

- (void)testBrandForCardName {
    XCTAssertTrue([validator brandForCardName:@"american express"].type == AWXCardBrandAmex);
    XCTAssertTrue([validator brandForCardName:@"amex"].type == AWXCardBrandAmex);
    XCTAssertTrue([validator brandForCardName:@"diners club international"].type == AWXCardBrandDinersClub);
}

- (void)testMaxLengthForCardNumber {
    XCTAssertEqual([validator maxLengthForCardNumber:@"3569"], 16);
    XCTAssertEqual([validator maxLengthForCardNumber:@"622848"], 19);
    XCTAssertEqual([validator maxLengthForCardNumber:@"6011"], 19);
    XCTAssertEqual([validator maxLengthForCardNumber:@"3643"], 19);
}

@end
