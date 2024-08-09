//
//  PaymentMethodListView.h
//  Examples
//
//  Created by Tony He (CTR) on 2024/8/9.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import <Airwallex/Core.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PaymentMethodListView : UIView

- (void)reloadWith:(NSArray<AWXPaymentMethodType *> *)list;

@end

NS_ASSUME_NONNULL_END
