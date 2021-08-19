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

@interface AWXPaymentConsent : NSObject <AWXJSONDecodable>

@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *requestId;
@property (nonatomic, copy) NSString *customerId;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong, nullable) AWXPaymentMethod *paymentMethod;
@property (nonatomic, copy) NSString *nextTriggeredBy;
@property (nonatomic, copy) NSString *merchantTriggerReason;
@property (nonatomic) BOOL requiresCvc;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *updatedAt;
@property (nonatomic, copy) NSString *clientSecret;

@end

NS_ASSUME_NONNULL_END


