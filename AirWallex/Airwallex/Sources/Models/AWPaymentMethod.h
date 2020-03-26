//
//  AWPaymentMethod.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWJSONifiable.h"
#import "AWParseable.h"
#import "AWBilling.h"
#import "AWCard.h"
#import "AWWechatPay.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWPaymentMethod` includes the information of a payment method.
 */
@interface AWPaymentMethod : NSObject <AWJSONifiable, AWParseable>

/**
 Payment type
 */
@property (nonatomic, copy) NSString *type;

/**
 Payment method ID.
 */
@property (nonatomic, copy, nullable) NSString *Id;

/**
 Billing object.
 */
@property (nonatomic, strong, nullable) AWBilling *billing;

/**
 Card object.
 */
@property (nonatomic, strong, nullable) AWCard *card;

/**
 Wechat pay object.
 */
@property (nonatomic, strong, nullable) AWWechatPay *wechatpay;

@end

NS_ASSUME_NONNULL_END
