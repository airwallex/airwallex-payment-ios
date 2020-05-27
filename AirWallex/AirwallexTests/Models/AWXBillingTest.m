//
//  AWXPlaceDetailsTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWXTestUtils.h"
#import "AWXPlaceDetails.h"

@interface AWXPlaceDetailsTest : XCTestCase

@end

@implementation AWXPlaceDetailsTest

- (void)testBilling
{
    AWXPlaceDetails *billing = [AWXPlaceDetails decodeFromJSON:[AWXTestUtils jsonNamed:@"Billing"]];
    XCTAssertNotNil(billing);
    XCTAssertNotNil(billing.firstName);
    XCTAssertNotNil(billing.lastName);
    XCTAssertNotNil(billing.email);
    XCTAssertNotNil(billing.phoneNumber);
    XCTAssertNotNil(billing.dateOfBirth);
    XCTAssertNotNil(billing.address);
}

@end
