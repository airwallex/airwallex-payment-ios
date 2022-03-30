//
//  AWXPaymentConsent.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"

NS_ASSUME_NONNULL_BEGIN

@class AWXPaymentMethod;

/**
 `AWXPaymentConsent` includes the info of payment consent.
 */
@interface AWXPaymentConsent : NSObject <AWXJSONDecodable>

/**
 Consent ID.
 */
@property (nonatomic, copy) NSString *Id;

/**
 Request ID.
 */
@property (nonatomic, copy) NSString *requestId;

/**
 Customer ID.
 */
@property (nonatomic, copy) NSString *customerId;

/**
 Consent status.
 */
@property (nonatomic, copy) NSString *status;

/**
 Payment method.
 */
@property (nonatomic, strong, nullable) AWXPaymentMethod *paymentMethod;

/**
 Next trigger By type.
 */
@property (nonatomic, copy) NSString *nextTriggeredBy;

/**
 Merchant trigger reason
 */
@property (nonatomic, copy) NSString *merchantTriggerReason;

/**
 Whether it requires CVC.
 */
@property (nonatomic) BOOL requiresCVC;

/**
 Created at date.
 */
@property (nonatomic, copy) NSString *createdAt;

/**
 Updated at date.
 */
@property (nonatomic, copy) NSString *updatedAt;

/**
 Client secret.
 */
@property (nonatomic, copy) NSString *clientSecret;

@end

NS_ASSUME_NONNULL_END


