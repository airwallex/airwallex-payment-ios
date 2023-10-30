//
//  AWXCardValidatorTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXCardValidator.h"
#import <XCTest/XCTest.h>

@interface AWXCardValidatorTest : XCTestCase

@property (nonatomic, strong) AWXCardValidator *validator;

@end

@implementation AWXCardValidatorTest

@synthesize validator;

- (void)setUp {
    self.validator = [AWXCardValidator sharedCardValidator];
}

- (void)testBrandForCardNumber {
    XCTAssertTrue([validator brandForCardNumber:@"4242424242424242"].type == AWXBrandTypeVisa);
    XCTAssertTrue([validator brandForCardNumber:@"4012000300001003"].type == AWXBrandTypeVisa);
    XCTAssertTrue([validator brandForCardNumber:@"378282246310005"].type == AWXBrandTypeAmex);
    XCTAssertTrue([validator brandForCardNumber:@"6011111111111117"].type == AWXBrandTypeDiscover);
    XCTAssertTrue([validator brandForCardNumber:@"3056930009020004"].type == AWXBrandTypeDinersClub);
    XCTAssertTrue([validator brandForCardNumber:@"3566002020360505"].type == AWXBrandTypeJCB);
    XCTAssertTrue([validator brandForCardNumber:@"6200000000000005"].type == AWXBrandTypeUnionPay);
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
    XCTAssertTrue([validator brandForCardName:@"american express"].type == AWXBrandTypeAmex);
    XCTAssertTrue([validator brandForCardName:@"amex"].type == AWXBrandTypeAmex);
    XCTAssertTrue([validator brandForCardName:@"diners club international"].type == AWXBrandTypeDinersClub);
}

- (void)testMaxLengthForCardNumber {
    XCTAssertEqual([validator maxLengthForCardNumber:@"3569"], 16);
    XCTAssertEqual([validator maxLengthForCardNumber:@"622848"], 19);
    XCTAssertEqual([validator maxLengthForCardNumber:@"6011"], 19);
    XCTAssertEqual([validator maxLengthForCardNumber:@"3643"], 19);
}

@end
