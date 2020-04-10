//
//  AWCardValidatorTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWCardValidator.h"

@interface AWCardValidatorTest : XCTestCase

@end

@implementation AWCardValidatorTest

- (void)testCardValidator
{
    XCTAssertTrue([[AWCardValidator sharedCardValidator] brandForCardNumber:@"4242424242424242"].type == AWBrandTypeVisa);
    XCTAssertTrue([[AWCardValidator sharedCardValidator] brandForCardNumber:@"5555555555554444"].type == AWBrandTypeMastercard);
}

@end
