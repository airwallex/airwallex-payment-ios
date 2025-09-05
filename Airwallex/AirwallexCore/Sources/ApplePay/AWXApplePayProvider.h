//
//  AWXApplePayProvider.h
//  ApplePay
//
//  Created by Jin Wang on 23/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXApplePayProvider` is a provider to handle payment method with Apple Pay.
 */
__deprecated_msg("Will be removed in next major version release, use AirwallexPayment.ApplePayProvider instead")
    @interface AWXApplePayProvider : AWXDefaultProvider

/**
 Launch Apple Pay sheet to confirm the payment intent.
 */
- (void)startPayment;

@end

NS_ASSUME_NONNULL_END
