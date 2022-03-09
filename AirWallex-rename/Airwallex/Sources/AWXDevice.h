//
//  AWXDevice.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXDevice` includes the information of device.
 */
@interface AWXDevice : NSObject <AWXJSONEncodable>

/**
 Device id.
 */
@property (nonatomic, copy) NSString *deviceId;

@end

NS_ASSUME_NONNULL_END
