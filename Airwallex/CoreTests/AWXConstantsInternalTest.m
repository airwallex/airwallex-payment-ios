//
//  AWXConstantsInternalTest.m
//  CoreTests
//
//  Created by Jin Wang on 5/4/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWXConstants+Internal.h"

@interface AWXConstantsInternalTest : XCTestCase

@end

@implementation AWXConstantsInternalTest

- (void)testUnsupportedPaymentMethodTypes {
    NSArray *expected = @[
        @"googlepay",
        @"ach_direct_debit",
        @"becs_direct_debit",
        @"sepa_direct_debit",
        @"bacs_direct_debit"
    ];
    
    XCTAssertEqualObjects(AWXUnsupportedPaymentMethodTypes(), expected);
}

@end
