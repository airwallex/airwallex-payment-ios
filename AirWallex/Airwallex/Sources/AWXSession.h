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

/**
 `AWXSession` is the base session.
 */
@interface AWXSession : NSObject

/**
 The country code.
 */
@property (nonatomic, strong) NSString *countryCode;

/**
 The billing address.
 */
@property (nonatomic, strong, nullable) AWXPlaceDetails *billing;

/**
 Return URL.
 */
@property (nonatomic, copy) NSString *returnURL;

/**
 Return transaction mode.
 */
- (NSString *)transactionMode;

@end

@interface AWXSession (Utils)

/**
 Update payment intent id.
 */
- (void)updateInitialPaymentIntentId:(NSString *)initialPaymentIntentId;

/**
 Return all of customer payment consents
 */
- (NSArray *)customerPaymentConsents;

/**
 Return all of customer payment methods
 */
- (NSArray *)customerPaymentMethods;

/**
 Return customer id
 */
- (nullable NSString *)customerId;

/**
 Return currency
 */
- (NSString *)currency;

/**
 The total amount
 */
- (NSDecimalNumber *)amount;

/**
 Return payment intent id
 */
- (nullable NSString *)paymentIntentId;

/**
 Return whether it requres CVC.
 */
- (BOOL)requiresCVC;

@end

/**
 `AWXOneOffSession` is the session used for one-off payment.
 */
@interface AWXOneOffSession : AWXSession

/**
 The payment intent to handle.
 */
@property (nonatomic, strong, nullable) AWXPaymentIntent *paymentIntent;

@end

/**
 `AWXRecurringSession` is the session used for recurring.
 */
@interface AWXRecurringSession : AWXSession

/**
 Payment amount. This is the order amount you would like to charge your customer.
 */
@property (nonatomic, copy) NSDecimalNumber *amount;

/**
 Currency.
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

/**
 `AWXRecurringWithIntentSession` is the session used for recurring with intent.
 */
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
