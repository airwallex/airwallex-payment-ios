//
//  AWXApplePayProvider.h
//  ApplePay
//
//  Created by Jin Wang on 23/2/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <PassKit/PassKit.h>
#import "AWXDefaultProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXApplePayProvider` is a provider to handle payment method with Apple Pay.
 */
@interface AWXApplePayProvider : AWXDefaultProvider <PKPaymentAuthorizationControllerDelegate>

@end

NS_ASSUME_NONNULL_END
