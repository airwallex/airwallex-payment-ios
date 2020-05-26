//
//  AWDevice.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWCodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWDevice` includes the information of device.
 */
@interface AWDevice : NSObject <AWJSONEncodable>

/**
 Device id.
 */
@property (nonatomic, copy) NSString *deviceId;

@end

NS_ASSUME_NONNULL_END
