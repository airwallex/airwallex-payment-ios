//
//  AWXAddressTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAddress.h"
#import "AWXTestUtils.h"
#import <XCTest/XCTest.h>

@interface AWXAddressTest : XCTestCase

@end

@implementation AWXAddressTest

- (void)testAddress {
    NSData *data = [AWXTestUtils dataFromJsonFile:@"Address"];
    AWXAddress *address = [AWXAddress decodeFromJSONData:data];

    XCTAssertNotNil(address);
    XCTAssertNotNil(address.countryCode);
    XCTAssertNotNil(address.state);
    XCTAssertNotNil(address.city);
    XCTAssertNotNil(address.street);
    XCTAssertNotNil(address.postcode);
}

@end
