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

@interface AWPaymentMethod : NSObject <AWJSONifiable, AWParseable>

@property (nonatomic, strong, nullable) NSString *Id;
@property (nonatomic, strong) AWBilling *billing;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong, nullable) AWCard *card;
@property (nonatomic, strong, nullable) AWWechatPay *wechatpay;

@end

NS_ASSUME_NONNULL_END
