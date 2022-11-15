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

@end

@implementation AWXCardValidatorTest

- (void)testBrandForCardNumber {
    XCTAssertTrue([[AWXCardValidator sharedCardValidator] brandForCardNumber:@"4242424242424242"].type == AWXBrandTypeVisa);
    XCTAssertTrue([[AWXCardValidator sharedCardValidator] brandForCardNumber:@"4012000300001003"].type == AWXBrandTypeVisa);
    XCTAssertTrue([[AWXCardValidator sharedCardValidator] brandForCardNumber:@"378282246310005"].type == AWXBrandTypeAmex);
    XCTAssertTrue([[AWXCardValidator sharedCardValidator] brandForCardNumber:@"6011111111111117"].type == AWXBrandTypeDiscover);
    XCTAssertTrue([[AWXCardValidator sharedCardValidator] brandForCardNumber:@"3056930009020004"].type == AWXBrandTypeDinersClub);
    XCTAssertTrue([[AWXCardValidator sharedCardValidator] brandForCardNumber:@"3566002020360505"].type == AWXBrandTypeJCB);
    XCTAssertTrue([[AWXCardValidator sharedCardValidator] brandForCardNumber:@"6200000000000005"].type == AWXBrandTypeUnionPay);
}

- (void)testNameForCardNumber {
    XCTAssertEqualObjects([[AWXCardValidator sharedCardValidator] brandForCardNumber:@"378282246310005"].name, @"Amex");
    XCTAssertEqualObjects([[AWXCardValidator sharedCardValidator] brandForCardNumber:@"348282246310005"].name, @"Amex");
}

- (void)testIsValidCardLength {
    XCTAssertTrue([[AWXCardValidator sharedCardValidator] isValidCardLength:@"4242424242424242"]);
    XCTAssertFalse([[AWXCardValidator sharedCardValidator] isValidCardLength:@"424242424242424"]);
    XCTAssertFalse([[AWXCardValidator sharedCardValidator] isValidCardLength:@"0000000000000000"]);
}

- (void)testBrandForCardName {
    XCTAssertTrue([[AWXCardValidator sharedCardValidator] brandForCardName:@"american express"].type == AWXBrandTypeAmex);
    XCTAssertTrue([[AWXCardValidator sharedCardValidator] brandForCardName:@"amex"].type == AWXBrandTypeAmex);
}

@end
