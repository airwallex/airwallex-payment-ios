//
//  AWXCardValidatorTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWXCardValidator.h"

@interface AWXCardValidatorTest : XCTestCase

@end

@implementation AWXCardValidatorTest

- (void)testCardValidator
{
    XCTAssertTrue([[AWXCardValidator sharedCardValidator] brandForCardNumber:@"4242424242424242"].type == AWXBrandTypeVisa);
    XCTAssertTrue([[AWXCardValidator sharedCardValidator] brandForCardNumber:@"5555555555554444"].type == AWXBrandTypeMastercard);
}

@end
