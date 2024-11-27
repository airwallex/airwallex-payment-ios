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
                                   additionalInfo:(NSDictionary<NSString *, NSString *> *_Nullable)additionalInfo;

- (void)confirmPaymentIntentWithPaymentMethodName:(NSString *)paymentMethodName
                                   additionalInfo:(NSDictionary<NSString *, NSString *> *_Nullable)additionalInfo
                                             flow:(AWXPaymentMethodFlow)flow;
@end

NS_ASSUME_NONNULL_END
