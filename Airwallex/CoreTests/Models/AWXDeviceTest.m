//
//  AWXDeviceTest.m
//  CoreTests
//
//  Created by Hector.Huang on 2022/12/8.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "CoreTests-Swift.h"
#import <OCMock/OCMock.h>
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
    AWXDevice *device = [[AWXDevice alloc] initWithDeviceId:@"abcd"];
    NSDictionary *encodedDevice = [device encodeToJSON];
    XCTAssertEqualObjects(encodedDevice[@"device_id"], @"abcd");
    XCTAssertNotNil(encodedDevice[@"mobile"]);
}

- (void)testDecodeFromJSON_ValidData {
    NSDictionary *json = @{
        @"device_id": @"12345",
        @"mobile": @{
            @"os_type": @"iOS",
            @"device_model": @"iPhone",
            @"os_version": @"14.4"
        }
    };

    AWXDevice *device = [AWXDevice decodeFromJSON:json];

    XCTAssertEqualObjects(device.deviceId, @"12345");
    XCTAssertEqualObjects(device.mobile.osType, @"iOS");
    XCTAssertEqualObjects(device.mobile.deviceModel, @"iPhone");
    XCTAssertEqualObjects(device.mobile.osVersion, @"14.4");
}

- (void)testDecodeFromJSON_InvalidData {
    NSDictionary *json = @{
        @"deviceIdentifier": @"12345"
    };

    AWXDevice *device = [AWXDevice decodeFromJSON:json];

    XCTAssertNil(device.deviceId);
    XCTAssertEqualObjects(device.mobile.osType, [[UIDevice currentDevice] systemName]);
    XCTAssertEqualObjects(device.mobile.deviceModel, [[UIDevice currentDevice] model]);
    XCTAssertEqualObjects(device.mobile.osVersion, [[UIDevice currentDevice] systemVersion]);
}

- (void)testDecodeFromJSON_EmptyData {
    NSDictionary *json = @{};

    AWXDevice *device = [AWXDevice decodeFromJSON:json];

    XCTAssertNil(device.deviceId);
    XCTAssertEqualObjects(device.mobile.osType, [[UIDevice currentDevice] systemName]);
    XCTAssertEqualObjects(device.mobile.deviceModel, [[UIDevice currentDevice] model]);
    XCTAssertEqualObjects(device.mobile.osVersion, [[UIDevice currentDevice] systemVersion]);
}

@end
