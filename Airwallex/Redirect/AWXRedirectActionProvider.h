//
//  AWXRedirectActionProvider.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXDefaultActionProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXRedirectActionProvider` handles Redirect flow.
 */
@interface AWXRedirectActionProvider : AWXDefaultActionProvider

- (void)confirmPaymentIntentWithPaymentMethodName:(NSString *)paymentMethodName
                                   additionalInfo:(NSDictionary<NSString *, NSString *> *_Nullable)additionalInfo NS_SWIFT_NAME(confirmPaymentIntent(with:additionalInfo:));

- (void)confirmPaymentIntentWithPaymentMethodName:(NSString *)paymentMethodName
                                   additionalInfo:(NSDictionary<NSString *, NSString *> *_Nullable)additionalInfo
                                             flow:(AWXPaymentMethodFlow)flow NS_SWIFT_NAME(confirmPaymentIntent(with:additionalInfo:flow:));
@end

NS_ASSUME_NONNULL_END
