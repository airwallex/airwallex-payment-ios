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
 The billing address.
 */
@property (nonatomic, strong, nullable) AWXPlaceDetails *billing;

/**
 Specifies the required billing contact fields. Defaults to `AWXRequiredBillingContactFieldName`.
 */
@property (nonatomic, assign) AWXRequiredBillingContactFields requiredBillingContactFields;

/**
 Apple Pay options.
 */
@property (nonatomic, strong, nullable) AWXApplePayOptions *applePayOptions;

/**
 An array of payment method type names to limit the payment methods displayed on the list screen. Only available ones from your Airwallex account will be applied, any other ones will be ignored. Also the order of payment method list will follow the order of this array. API reference: https://www.airwallex.com/docs/api#/Payment_Acceptance/Config/_api_v1_pa_config_payment_method_types/get JSON Object field: items.name
 */
@property (nonatomic, strong, nullable) NSArray<NSString *> *paymentMethods;

/**
 Return URL.
 */
@property (nonatomic, copy) NSString *returnURL;

/**
 Whether show stored card.
 */
@property (nonatomic) BOOL hidePaymentConsents;

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
- (NSArray *)customerPaymentConsents __deprecated;

/**
 Return all of customer payment methods
 */
- (NSArray *)customerPaymentMethods __deprecated;

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
- (BOOL)requiresCVC __deprecated_msg("requiresCVC will be determined by consent returned by server (numberType), passing requiresCVC as a parameter is no longer needed");

- (nullable NSString *)validateData;

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

/// Indicates whether card saving is enabled by default. Defaults to YES.
@property (nonatomic, assign) BOOL autoSaveCardForFuturePayments;

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
@property (nonatomic) BOOL requiresCVC __deprecated_msg("requiresCVC will be determined by consent returned by server (numberType), passing requiresCVC as a parameter is no longer needed");

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
@property (nonatomic) BOOL requiresCVC __deprecated_msg("requiresCVC will be determined by consent returned by server (numberType), passing requiresCVC as a parameter is no longer needed");

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
