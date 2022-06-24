//
//  AWXDevice.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXCodable.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXDevice` includes the information of device.
 */
@interface AWXDevice : NSObject<AWXJSONEncodable>

/**
 Device id.
 */
@property (nonatomic, copy) NSString *deviceId;

@end

NS_ASSUME_NONNULL_END
