//
//  AWXPaymentConsent.h
//  Airwallex
//
//  Created by 秋风木叶下 on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"

NS_ASSUME_NONNULL_BEGIN

@class AWXPaymentMethod;

@interface AWXPaymentConsent : NSObject <AWXJSONDecodable>

@property (nonatomic, readonly) NSString *Id;
@property (nonatomic, readonly) NSString *requestId;
@property (nonatomic, readonly) NSString *customerId;
@property (nonatomic, readonly) NSString *status;
@property (nonatomic, readonly) AWXPaymentMethod *paymentMethod;

@property (nonatomic, readonly) NSString *nextTriggeredBy;
@property (nonatomic, readonly) NSString *merchantTriggerReason;
@property (nonatomic, readonly) NSString *initialPaymentIntentId;

@property (nonatomic, readonly) BOOL requiresCvc;

@property (nonatomic, readonly) NSString *createdAt;
@property (nonatomic, readonly) NSString *updatedAt;
@property (nonatomic, readonly) NSString *clientSecret;

@end

NS_ASSUME_NONNULL_END


