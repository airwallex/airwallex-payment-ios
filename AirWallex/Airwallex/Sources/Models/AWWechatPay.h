//
//  AWWechatPay.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWCodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWWechatPay` includes the information of wechat.
 */
@interface AWWechatPay : NSObject <AWJSONEncodable, AWJSONDecodable>

/**
 The specific WechatPay flow to use. For app, it should be 'inapp'.
 */
@property (nonatomic, copy) NSString *flow;

@end

NS_ASSUME_NONNULL_END
