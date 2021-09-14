//
//  AWXPaymentConsentResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXResponseProtocol.h"

@class  AWXPaymentConsent, AWXConfirmPaymentNextAction, AWXPaymentMethod;

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXCreatePaymentConsentResponse` includes the response of payment consent.
 */
@interface AWXCreatePaymentConsentResponse : NSObject <AWXResponseProtocol>

/**
 Payment consent object.
 */
@property (nonatomic, readonly) AWXPaymentConsent *consent;

@end

/**
 `AWXVerifyPaymentConsentResponse` includes the response of payment consent.
 */
@interface AWXVerifyPaymentConsentResponse : NSObject <AWXResponseProtocol>

/**
 Payment status.
 */
@property (nonatomic, readonly) NSString *status;

/**
 Payment intent id.
 */
@property (nonatomic, readonly) NSString *initialPaymentIntentId;

/**
 Next action.
 */
@property (nonatomic, readonly, nullable) AWXConfirmPaymentNextAction *nextAction;

@end

NS_ASSUME_NONNULL_END
