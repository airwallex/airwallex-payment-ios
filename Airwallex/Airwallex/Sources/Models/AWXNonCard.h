//
//  AWXNonCard.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/1/8.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXNonCard` includes the information of non-card.
 */
@interface AWXNonCard : NSObject <AWXJSONEncodable, AWXJSONDecodable>

/**
 The specific WeChatPay flow to use. For app, it should be 'inapp'.
 */
@property (nonatomic, copy) NSString *flow;

/**
   OS type.
 */
@property (nonatomic, copy) NSString *osType;

@end

NS_ASSUME_NONNULL_END
