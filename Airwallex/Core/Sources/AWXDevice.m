//
//  AWXDevice.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXDevice.h"
#import <UIKit/UIKit.h>
#import "AWXConstants.h"

@implementation AWXDevice

- (NSDictionary *)encodeToJSON
{
    UIDevice *device = [UIDevice currentDevice];
    return @{
        @"device_id": self.deviceId,
        @"sdk_version_name": AIRWALLEX_VERSION,
        @"platform_type": device.systemName,
        @"device_model": @"mobile",
        @"device_os": device.systemVersion
    };
}

@end
