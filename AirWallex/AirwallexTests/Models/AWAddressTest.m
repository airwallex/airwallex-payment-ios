//
//  AWAddressTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWTestUtils.h"
#import "AWAddress.h"

@interface AWAddressTest : XCTestCase

@end

@implementation AWAddressTest

- (void)testAddress
{
    AWAddress *address = [AWAddress decodeFromJSON:[AWTestUtils jsonNamed:@"Address"]];
    XCTAssertNotNil(address);
    XCTAssertNotNil(address.countryCode);
    XCTAssertNotNil(address.state);
    XCTAssertNotNil(address.city);
    XCTAssertNotNil(address.street);
    XCTAssertNotNil(address.postcode);
}

@end
