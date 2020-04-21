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

@interface AWDevice : NSObject <AWJSONEncodable>

@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *sdkVersionName;
@property (nonatomic, copy) NSString *platformType;
@property (nonatomic, copy) NSString *deviceModel;
@property (nonatomic, copy) NSString *deviceOs;

@end

NS_ASSUME_NONNULL_END
