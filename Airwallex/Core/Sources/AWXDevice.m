//
//  AWXDevice.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXDevice.h"
#import "AWXConstants.h"
#import <AirwallexRisk/AirwallexRisk-Swift.h>
#import <UIKit/UIKit.h>

@implementation AWXDevice

+ (instancetype)deviceWithRiskSessionId {
    AWXDevice *device = [AWXDevice new];
    device.deviceId = [[AWXRisk sessionID] UUIDString];
    return device;
}

- (NSDictionary *)encodeToJSON {
    NSMutableDictionary *device = [NSMutableDictionary new];
    if (self.deviceId) {
        device[@"device_id"] = self.deviceId;
    }
    device[@"mobile"] = [self mobilePayload];
    return device;
}

- (NSDictionary *)mobilePayload {
    UIDevice *device = [UIDevice currentDevice];
    return @{
        @"os_type": device.systemName,
        @"device_model": device.model,
        @"os_version": device.systemVersion
    };
}

@end
