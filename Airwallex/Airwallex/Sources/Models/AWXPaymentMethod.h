//
//  AWXPaymentMethod.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"
#import "AWXPlaceDetails.h"
#import "AWXCard.h"
#import "AWXWeChatPay.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXPaymentMethod` includes the information of a payment method.
 */
@interface AWXPaymentMethod : NSObject <AWXJSONEncodable, AWXJSONDecodable>

/**
 Type of the payment method. One of card, wechatpay.
 */
@property (nonatomic, copy) NSString *type;

/**
 Unique identifier for the payment method.
 */
@property (nonatomic, copy, nullable) NSString *Id;

/**
 Billing object.
 */
@property (nonatomic, strong, nullable) AWXPlaceDetails *billing;

/**
 Card object.
 */
@property (nonatomic, strong, nullable) AWXCard *card;

/**
 Wechat pay object.
 */
@property (nonatomic, strong, nullable) AWXWeChatPay *weChatPay;

/**
 The customer this payment method belongs to.
 */
@property (nonatomic, strong, nullable) NSString *customerId;

@end

NS_ASSUME_NONNULL_END
