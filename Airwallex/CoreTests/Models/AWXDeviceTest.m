//
//  AWXDeviceTest.m
//  CoreTests
//
//  Created by Hector.Huang on 2022/12/8.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWXDeviceTest : XCTestCase

@end

@implementation AWXDeviceTest

- (void)testEncoding {
    AWXDevice *device = [AWXDevice new];
    device.deviceId = @"abcd";
    NSDictionary *encodedDevice = [device encodeToJSON];
    XCTAssertEqualObjects(encodedDevice[@"device_id"], @"abcd");
    XCTAssertNotNil(encodedDevice[@"mobile"]);
}

@end
