//
//  AWXPlaceDetailsTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXTestUtils.h"
#import <XCTest/XCTest.h>
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWXPlaceDetailsTest : XCTestCase

@end

@implementation AWXPlaceDetailsTest

- (void)testBilling {
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
