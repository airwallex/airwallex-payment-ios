//
//  AWXPaymentIntentRequestTest.m
//  CoreTests
//
//  Created by Hector.Huang on 2022/12/8.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXPaymentIntentRequest.h"
#import <XCTest/XCTest.h>
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWXPaymentIntentRequestTest : XCTestCase

@property (nonatomic, strong) AWXDevice *device;

@end

@implementation AWXPaymentIntentRequestTest

- (void)setUp {
    [super setUp];
    AWXDevice *device = [AWXDevice new];
    device.deviceId = @"abcd";
    self.device = device;
}

- (void)testConfirmRequestParameters {
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.device = _device;
    XCTAssertEqualObjects(request.parameters[@"device_data"], _device.encodeToJSON);
}

- (void)testContinueRequestParameter {
    AWXConfirmThreeDSRequest *request = [AWXConfirmThreeDSRequest new];
    request.device = _device;
    XCTAssertEqualObjects(request.parameters[@"device_data"], _device.encodeToJSON);
}

@end
