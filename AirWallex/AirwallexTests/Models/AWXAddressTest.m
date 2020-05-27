//
//  AWXAddressTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWXTestUtils.h"
#import "AWXAddress.h"

@interface AWXAddressTest : XCTestCase

@end

@implementation AWXAddressTest

- (void)testAddress
{
    AWXAddress *address = [AWXAddress decodeFromJSON:[AWXTestUtils jsonNamed:@"Address"]];
    XCTAssertNotNil(address);
    XCTAssertNotNil(address.countryCode);
    XCTAssertNotNil(address.state);
    XCTAssertNotNil(address.city);
    XCTAssertNotNil(address.street);
    XCTAssertNotNil(address.postcode);
}

@end
