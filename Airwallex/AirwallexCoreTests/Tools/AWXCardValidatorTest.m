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

- (void)testIsValidCardLength_unionPay {
    AWXBrandType brandType = AWXBrandTypeUnionPay;
    NSArray *validNumbers = @[
        @"6262626262626262",
        @"62626262626262620",
        @"626262626262626200",
        @"6262626262626262000"
    ];
    for (NSString *cardNumber in validNumbers) {
        AWXBrand *brand = [validator brandForCardNumber:cardNumber];
        XCTAssertEqual(brand.type, brandType);
        XCTAssertTrue([validator isValidCardLength:cardNumber]);
    }

    NSArray *invalidNumbers = @[
        @"626262626262626",
        @"62626262626262620001"
    ];
    for (NSString *cardNumber in invalidNumbers) {
        AWXBrand *brand = [validator brandForCardNumber:cardNumber];
        XCTAssertEqual(brand.type, brandType);
        XCTAssertFalse([validator isValidCardLength:cardNumber]);
    }
}

- (void)testIsValidCardLength_Amex {
    AWXBrandType brandType = AWXBrandTypeAmex;
    NSArray *validNumbers = @[
        @"340011112222333",
        @"370011112222333",
    ];
    for (NSString *cardNumber in validNumbers) {
        AWXBrand *brand = [validator brandForCardNumber:cardNumber];
        XCTAssertEqual(brand.type, brandType);
        XCTAssertTrue([validator isValidCardLength:cardNumber]);
    }

    NSArray *invalidNumbers = @[
        @"34001111222233",
        @"3400111122223333"
    ];
    for (NSString *cardNumber in invalidNumbers) {
        AWXBrand *brand = [validator brandForCardNumber:cardNumber];
        XCTAssertEqual(brand.type, brandType);
        XCTAssertFalse([validator isValidCardLength:cardNumber]);
    }
}

- (void)testIsValidCardLength_DinersClub {
    AWXBrandType brandType = AWXBrandTypeDinersClub;
    NSArray *validNumbers = @[
        @"30001111222233",
        @"3000111122223333",
        @"3000111122223333444",

        @"36001111222233",
        @"3600111122223333",
        @"3600111122223333444",

        @"38001111222233",
        @"3800111122223333",
        @"3800111122223333444",
    ];
    for (NSString *cardNumber in validNumbers) {
        AWXBrand *brand = [validator brandForCardNumber:cardNumber];
        XCTAssertEqual(brand.type, brandType);
        XCTAssertTrue([validator isValidCardLength:cardNumber]);
    }

    NSArray *invalidNumbers = @[
        @"3000111122223",
        @"300011112222333",
        @"30001111222233334",
        @"300011112222333344",
        @"30001111222233334444",

        @"3600111122223",
        @"360011112222333",
        @"36001111222233334",
        @"360011112222333344",
        @"36001111222233334444",

        @"3900111122223",
        @"390011112222333",
        @"39001111222233334",
        @"390011112222333344",
        @"39001111222233334444",
    ];
    for (NSString *cardNumber in invalidNumbers) {
        AWXBrand *brand = [validator brandForCardNumber:cardNumber];
        XCTAssertEqual(brand.type, brandType);
        XCTAssertFalse([validator isValidCardLength:cardNumber]);
    }
}

- (void)testIsValidCardLength_Discover {
    AWXBrandType brandType = AWXBrandTypeDiscover;
    NSArray *validNumbers = @[
        @"6011111122223333",
        @"6011111122223333444",

        @"6440111122223333",
        @"6440111122223333444"
    ];
    for (NSString *cardNumber in validNumbers) {
        AWXBrand *brand = [validator brandForCardNumber:cardNumber];
        XCTAssertEqual(brand.type, brandType);
        XCTAssertTrue([validator isValidCardLength:cardNumber]);
    }

    NSArray *invalidNumbers = @[
        @"601111112222333",
        @"60111111222233334",
        @"601111112222333344",
        @"60111111222233334444",

        @"644011112222333",
        @"64401111222233334",
        @"644011112222333344",
        @"64401111222233334444"
    ];
    for (NSString *cardNumber in invalidNumbers) {
        AWXBrand *brand = [validator brandForCardNumber:cardNumber];
        XCTAssertEqual(brand.type, brandType);
        XCTAssertFalse([validator isValidCardLength:cardNumber]);
    }
}

- (void)testIsValidCardLength_JCB {
    AWXBrandType brandType = AWXBrandTypeJCB;
    NSArray *validNumbers = @[
        @"3528111122223333",
    ];
    for (NSString *cardNumber in validNumbers) {
        AWXBrand *brand = [validator brandForCardNumber:cardNumber];
        XCTAssertEqual(brand.type, brandType);
        XCTAssertTrue([validator isValidCardLength:cardNumber]);
    }

    NSArray *invalidNumbers = @[
        @"352811112222333",
        @"35281111222233334",
    ];
    for (NSString *cardNumber in invalidNumbers) {
        AWXBrand *brand = [validator brandForCardNumber:cardNumber];
        XCTAssertEqual(brand.type, brandType);
        XCTAssertFalse([validator isValidCardLength:cardNumber]);
    }
}

- (void)testIsValidCardLength_Mastercard {
    AWXBrandType brandType = AWXBrandTypeMastercard;
    NSArray *validNumbers = @[
        @"5000111122223333",
        @"2200111122223333",
        @"6700111122223333"
    ];
    for (NSString *cardNumber in validNumbers) {
        AWXBrand *brand = [validator brandForCardNumber:cardNumber];
        XCTAssertEqual(brand.type, brandType);
        XCTAssertTrue([validator isValidCardLength:cardNumber]);
    }

    NSArray *invalidNumbers = @[
        @"500011112222333",
        @"50001111222233334",
        @"220011112222333",
        @"22001111222233334",
        @"670011112222333",
        @"67001111222233334",
    ];
    for (NSString *cardNumber in invalidNumbers) {
        AWXBrand *brand = [validator brandForCardNumber:cardNumber];
        XCTAssertEqual(brand.type, brandType);
        XCTAssertFalse([validator isValidCardLength:cardNumber]);
    }
}

- (void)testIsValidCardLength_Visa {
    AWXBrandType brandType = AWXBrandTypeVisa;
    NSArray *validNumbers = @[
        @"4000111122223333",
        @"4929711122223333",
        @"4136001122223",
        @"4445091122223",
        @"4445501122223",
        @"4506031122223",
        @"4506171122223",
        @"4506281122223",
        @"4506361122223",
        @"4506401122223",
        @"4506621122223",
        @"4631001122223",
        @"4761421122223",
        @"4761431122223",
        @"4929011122223",
        @"4929201122223",
        @"4929231122223",
        @"4929281122223",
        @"4929371122223",
        @"4929391122223",
        @"4929601122223",
    ];
    for (NSString *cardNumber in validNumbers) {
        AWXBrand *brand = [validator brandForCardNumber:cardNumber];
        XCTAssertEqual(brand.type, brandType);
        XCTAssertTrue([validator isValidCardLength:cardNumber]);
    }

    NSArray *invalidNumbers = @[
        @"400011112222333",
        @"49297111222233334",
        @"400011112222333",
        @"49297111222233334",
        @"4111111122223",

        @"413600112222",
        @"444509112222",
        @"444550112222",
        @"450603112222",
        @"450617112222",
        @"450628112222",
        @"450636112222",
        @"450640112222",
        @"450662112222",
        @"463100112222",
        @"476142112222",
        @"476143112222",
        @"492901112222",
        @"492920112222",
        @"492923112222",
        @"492928112222",
        @"492937112222",
        @"492939112222",
        @"492960112222",

        @"41360011222233",
        @"44450911222233",
        @"44455011222233",
        @"45060311222233",
        @"45061711222233",
        @"45062811222233",
        @"45063611222233",
        @"45064011222233",
        @"45066211222233",
        @"46310011222233",
        @"47614211222233",
        @"47614311222233",
        @"49290111222233",
        @"49292011222233",
        @"49292311222233",
        @"49292811222233",
        @"49293711222233",
        @"49293911222233",
        @"49296011222233",
    ];
    for (NSString *cardNumber in invalidNumbers) {
        AWXBrand *brand = [validator brandForCardNumber:cardNumber];
        XCTAssertEqual(brand.type, brandType);
        XCTAssertFalse([validator isValidCardLength:cardNumber]);
    }
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

- (void)testCvcLengthForBrand {
    XCTAssertEqual([AWXCardValidator cvcLengthForBrand:AWXBrandTypeAmex], 4);
    XCTAssertEqual([AWXCardValidator cvcLengthForBrand:AWXBrandTypeMastercard], 3);
    XCTAssertEqual([AWXCardValidator cvcLengthForBrand:AWXBrandTypeUnknown], 3);
}

- (void)testMostSpecificCardBrandForNumber {
    AWXBrand *brand = [AWXCardValidator.sharedCardValidator brandForCardNumber:@"499"];
    XCTAssertEqual(brand.type, AWXBrandTypeVisa);
    XCTAssertEqual(brand.length, 16);
    brand = [AWXCardValidator.sharedCardValidator brandForCardNumber:@"49"];
    XCTAssertEqual(brand.type, AWXBrandTypeVisa);
    XCTAssertEqual(brand.length, 13);
    brand = [AWXCardValidator.sharedCardValidator brandForCardNumber:@""];
    XCTAssertEqual(brand.type, AWXBrandTypeUnknown);
}

- (void)testPossibleBrandTypesForCardNumber {
    NSArray<NSNumber *> *candidates = [AWXCardValidator.sharedCardValidator possibleBrandTypesForCardNumber:@"6"];
    XCTAssertEqual(candidates.count, 3);
    candidates = [AWXCardValidator.sharedCardValidator possibleBrandTypesForCardNumber:@"60"];
    XCTAssertEqual(candidates.count, 1);
    XCTAssertEqual(candidates.firstObject.unsignedIntValue, AWXBrandTypeDiscover);
    candidates = [AWXCardValidator.sharedCardValidator possibleBrandTypesForCardNumber:@""];
    XCTAssertEqual(candidates.count, 7);
}

@end
