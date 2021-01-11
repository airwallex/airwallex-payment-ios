//
//  AWXWeChatPay.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXWeChatPay` includes the information of wechat.
 */
NS_CLASS_DEPRECATED_IOS(2_0, 14_0, "Use AWXNonCard instead.")
@interface AWXWeChatPay : NSObject <AWXJSONEncodable, AWXJSONDecodable>

/**
 The specific WeChatPay flow to use. For app, it should be 'inapp'.
 */
@property (nonatomic, copy) NSString *flow;

@end

NS_ASSUME_NONNULL_END
