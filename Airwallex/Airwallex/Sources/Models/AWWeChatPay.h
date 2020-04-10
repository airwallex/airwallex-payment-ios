//
//  AWWeChatPay.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWCodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWWeChatPay` includes the information of wechat.
 */
@interface AWWeChatPay : NSObject <AWJSONEncodable, AWJSONDecodable>

/**
 The specific WeChatPay flow to use. For app, it should be 'inapp'.
 */
@property (nonatomic, copy) NSString *flow;

@end

NS_ASSUME_NONNULL_END
