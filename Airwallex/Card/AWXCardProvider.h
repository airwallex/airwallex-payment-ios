//
//  AWXCardProvider.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/19.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"
#import "AWXUIContext.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXCardProvider` is a provider to handle payment method with card.
 */
@interface AWXCardProvider : AWXDefaultProvider<AWXPaymentResultDelegate>

/**
 Confirm the payment intent with card and billing.

 @param card The card info.
 @param billing The billing info.
 */
- (void)confirmPaymentIntentWithCard:(AWXCard *)card
                             billing:(AWXPlaceDetails *_Nullable)billing
                            saveCard:(BOOL)saveCard;

/**
 Confirm the payment intent with payment consent ID.

 @param paymentConsentId ID of the PaymentConsent.
 */
- (void)confirmPaymentIntentWithPaymentConsentId:(NSString *)paymentConsentId;

/// Confirm the payment intent with payment consent
/// @param paymentConsent AWXPaymentConsent Object
- (void)confirmPaymentIntentWithPaymentConsent:(AWXPaymentConsent *)paymentConsent;

@end

NS_ASSUME_NONNULL_END
