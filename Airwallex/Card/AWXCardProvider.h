//
//  AWXCardProvider.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/19.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXCardProvider` is a provider to handle payment method with card.
 */
@interface AWXCardProvider : AWXDefaultProvider

@property (nonatomic, nullable) AWXPaymentMethodType *paymentMethodType;
/**
 Confirm the payment intent with card and billing.

 @param card The card info.
 @param billing The billing info.
 */
- (void)confirmPaymentIntentWithCard:(AWXCard *)card
                             billing:(AWXPlaceDetails *_Nullable)billing
                            saveCard:(BOOL)saveCard;

@end

NS_ASSUME_NONNULL_END
