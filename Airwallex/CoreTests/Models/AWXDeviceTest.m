//
//  AWXDeviceTest.m
//  CoreTests
//
//  Created by Hector.Huang on 2022/12/8.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXDevice.h"
#import <XCTest/XCTest.h>

@interface AWXDeviceTest : XCTestCase

@end

@implementation AWXDeviceTest

- (void)testEncoding {
    AWXDevice *device = [AWXDevice new];
    device.deviceId = @"abcd";
    NSDictionary *encodedDevice = [device encodeToJSON];
    XCTAssertEqual(encodedDevice[@"device_id"], @"abcd");
    XCTAssertNotNil(encodedDevice[@"mobile"]);
}

@end
