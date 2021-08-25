//
//  AWXSession.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/11.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXPlaceDetails.h"
#import "AWXPaymentIntent.h"
#import "AWXConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXSession : NSObject

/**
 The shipping address.
 */
@property (nonatomic, strong, nullable) AWXPlaceDetails *billing;

/**
 Return URL.
 */
@property (nonatomic, copy) NSString *returnURL;

///**
// Universal link.
// */
//@property (nonatomic, copy, nullable) NSString *uni;

- (NSString *)transactionMode;

@end

@interface AWXSession (Utils)

- (void)updateInitialPaymentIntentId:(NSString *)initialPaymentIntentId;
- (NSArray *)customerPaymentConsents;
- (NSArray *)customerPaymentMethods;
- (nullable NSString *)customerId;
- (NSString *)currency;
- (NSDecimalNumber *)amount;
- (nullable NSString *)paymentIntentId;
- (BOOL)requiresCVC;

@end

@interface AWXOneOffSession : AWXSession

/**
 The payment intent to handle.
 */
@property (nonatomic, strong, nullable) AWXPaymentIntent *paymentIntent;

@end

@interface AWXRecurringSession : AWXSession

/**
 Payment amount. This is the order amount you would like to charge your customer.
 */
@property (nonatomic, copy) NSDecimalNumber *amount;

/**
 Amount currency.
 */
@property (nonatomic, copy) NSString *currency;

/**
 The customer who is paying for this payment intent.
 */
@property (nonatomic, copy, nullable) NSString *customerId;

/**
 Next trigger by.
 */
@property (nonatomic) AirwallexNextTriggerByType nextTriggerByType;

/**
 Only applicable when next_triggered_by is customer and the payment_method.type is card.If true, the customer must provide cvc for the subsequent payment with this PaymentConsent.
 Default: NO
 */
@property (nonatomic) BOOL requiresCVC;

/**
 Merchant trigger reason
 */
@property (nonatomic) AirwallexMerchantTriggerReason merchantTriggerReason;

@end

@interface AWXRecurringWithIntentSession : AWXSession

/**
 The payment intent to handle.
 */
@property (nonatomic, strong, nullable) AWXPaymentIntent *paymentIntent;

/**
 Next trigger by.
 */
@property (nonatomic) AirwallexNextTriggerByType nextTriggerByType;

/**
 Only applicable when next_triggered_by is customer and the payment_method.type is card.If true, the customer must provide cvc for the subsequent payment with this PaymentConsent.
 Default: NO
 */
@property (nonatomic) BOOL requiresCVC;

/**
 Merchant trigger reason
 */
@property (nonatomic) AirwallexMerchantTriggerReason merchantTriggerReason;

@end


NS_ASSUME_NONNULL_END
