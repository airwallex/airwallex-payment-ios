//
//  AWXDeviceTest.m
//  CoreTests
//
//  Created by Hector.Huang on 2022/12/8.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXDevice.h"
#import <AirwallexRisk/AirwallexRisk-Swift.h>
#import <OCMock/OCMock.h>
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

- (void)testDeviceWithRiskSessionId {
    id mockSessionId = OCMClassMock([NSUUID class]);
    id mockRisk = OCMClassMock([AWXRisk class]);
    OCMStub([mockSessionId UUIDString]).andReturn(@"abc");
    OCMStub([mockRisk sessionID]).andReturn(mockSessionId);
    XCTAssertEqual([[AWXDevice deviceWithRiskSessionId] deviceId], @"abc");
}

@end
