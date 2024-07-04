//
//  AWXSession.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/11.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXApplePayOptions.h"
#import "AWXConstants.h"
#import "AWXPaymentIntent.h"
#import "AWXPlaceDetails.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXSession` is the base session.
 */
@interface AWXSession : NSObject

/**
 The country code.
 */
@property (nonatomic, copy) NSString *countryCode;

/**
 The lang.
 */
@property (nonatomic, copy, nullable) NSString *lang;

/**
 Whether or not billing information is required for payments. When set to `NO`, any billing information will be ignored.
 */
@property (nonatomic) BOOL isBillingInformationRequired;

/**
 The billing address.
 */
@property (nonatomic, strong, nullable) AWXPlaceDetails *billing;

/**
 Apple Pay options.
 */
@property (nonatomic, strong, nullable) AWXApplePayOptions *applePayOptions;

/**
Whether AWXPaymentMethodListViewController should show stored card.
 */
@property (nonatomic) BOOL hidePaymentConsents;

/**
Whether AWXPaymentMethodListViewController should show stored card.
 */
@property (nonatomic, strong, nullable) NSArray<NSString *> *paymentMethodTypes;

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

/**
 Only applicable when payment_method.type is card. If true the payment will be captured immediately after authorization succeeds.
 Default: YES
 */
@property (nonatomic) BOOL autoCapture;

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
 Only applicable when next_triggered_by is customer and the payment_method.type is card. If true, the customer must provide cvc for the subsequent payment with this PaymentConsent.
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
 Only applicable when next_triggered_by is customer and the payment_method.type is card. If true, the customer must provide cvc for the subsequent payment with this PaymentConsent.
 Default: NO
 */
@property (nonatomic) BOOL requiresCVC;

/**
 Only applicable when payment_method.type is card. If true the payment will be captured immediately after authorization succeeds.
 Default: YES
 */
@property (nonatomic) BOOL autoCapture;

/**
 Merchant trigger reason
 */
@property (nonatomic) AirwallexMerchantTriggerReason merchantTriggerReason;

@end

NS_ASSUME_NONNULL_END
