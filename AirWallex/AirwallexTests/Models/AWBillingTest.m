//
//  AWBillingTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWTestUtils.h"
#import "AWBilling.h"

@interface AWBillingTest : XCTestCase

@end

@implementation AWBillingTest

- (void)testBilling
{
    AWBilling *billing = [AWBilling parseFromJsonDictionary:[AWTestUtils jsonNamed:@"Billing"]];
    XCTAssertNotNil(billing);
    XCTAssertNotNil(billing.firstName);
    XCTAssertNotNil(billing.lastName);
    XCTAssertNotNil(billing.email);
    XCTAssertNotNil(billing.phoneNumber);
    XCTAssertNotNil(billing.dateOfBirth);
    XCTAssertNotNil(billing.address);
}

@end
