//
//  AWXWeChatPaySDKResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXWeChatPaySDKResponse` includes the parameters for WeChatSDK.
 */
@interface AWXWeChatPaySDKResponse: NSObject <AWXJSONDecodable>

/**
 WeChat pay app id.
 */
@property (nonatomic, readonly, nullable) NSString *appId;

/**
 Timestamp
 */
@property (nonatomic, readonly) NSString *timeStamp;

/**
 Nonce string
 */
@property (nonatomic, readonly) NSString *nonceStr;

/**
 Prepay id
 */
@property (nonatomic, readonly) NSString *prepayId;

/**
 Partner id
 */
@property (nonatomic, readonly) NSString *partnerId;

/**
 Package
 */
@property (nonatomic, readonly) NSString *package;

/**
 Sign
 */
@property (nonatomic, readonly) NSString *sign;

@end

NS_ASSUME_NONNULL_END
