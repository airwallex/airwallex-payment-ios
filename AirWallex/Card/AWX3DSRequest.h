//
//  AWX3DSRequest.h
//  Card
//
//  Created by Victor Zhu on 2021/12/2.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWX3DSRequest` includes all of the parameters needed to connect with 3ds server.
 */
@interface AWX3DSCollectDeviceDataRequest : AWXRequest

@property (nonatomic, copy) NSString *jwt;

@property (nonatomic, copy) NSString *bin;

@end

NS_ASSUME_NONNULL_END
