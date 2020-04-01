//
//  AWPlaceDetailsTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWTestUtils.h"
#import "AWPlaceDetails.h"

@interface AWPlaceDetailsTest : XCTestCase

@end

@implementation AWPlaceDetailsTest

- (void)testBilling
{
    AWPlaceDetails *billing = [AWPlaceDetails parseFromJsonDictionary:[AWTestUtils jsonNamed:@"Billing"]];
    XCTAssertNotNil(billing);
    XCTAssertNotNil(billing.firstName);
    XCTAssertNotNil(billing.lastName);
    XCTAssertNotNil(billing.email);
    XCTAssertNotNil(billing.phoneNumber);
    XCTAssertNotNil(billing.dateOfBirth);
    XCTAssertNotNil(billing.address);
}

@end
