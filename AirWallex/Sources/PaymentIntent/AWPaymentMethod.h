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

@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) AWBilling *billing;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong, nullable) AWCard *card;
@property (nonatomic, strong, nullable) AWWechatPay *wechatpay;

@end

NS_ASSUME_NONNULL_END


//"id": "ins_ps8e0ZgQzd2QnCxVpzJrHD6KOVu",
//"request_id": "ee939540-3203-4a2c-9172-89a566485dd9",
//"customer_id": "cus_ps8e0ZgQzd2QnCxVpzJrHD6KOVu",
//"type": "card",
//"card": {
//  "exp_month": "12",
//  "exp_year": "2030",
//  "name": "John Doe",
//  "bin": "411111",
//  "last4": "1111",
//  "brand": "visa",
//  "country": "US",
//  "funding": "credit",
//  "fingerprint": "string",
//  "cvc_check": "pass",
//  "avs_check": "pass"
//},
//"wechatpay": {
//  "flow": "webqr"
//},
//"billing": {
//  "first_name": "John",
//  "last_name": "Doe",
//  "email": "john.doe@airwallex.com",
//  "phone_number": "13800000000",
//  "date_of_birth": "2011-10-23",
//  "address": {
//    "country_code": "CN",
//    "state": "Shanghai",
//    "city": "Shanghai",
//    "street": "Pudong District",
//    "postcode": "100000"
//  }
//},
//"metadata": "{\"id\": 1}",
//"created_at": "2019-09-18T03:11:00+0000",
//"updated_at": "2019-09-18T03:11:00+0000"
