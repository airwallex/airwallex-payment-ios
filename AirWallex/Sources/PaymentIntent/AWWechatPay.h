//
//  AWWechatPay.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWJSONifiable.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWWechatPay : NSObject <AWJSONifiable>

@property (nonatomic, copy) NSString *flow;

@end

NS_ASSUME_NONNULL_END
