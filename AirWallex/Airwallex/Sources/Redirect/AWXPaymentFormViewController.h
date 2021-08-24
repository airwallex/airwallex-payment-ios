//
//  AWXPaymentFormViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/17.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class AWXPaymentFormViewController, AWXPaymentMethod;

@protocol AWXPaymentFormViewControllerDelegate <NSObject>

- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController didUpdatePaymentMethod:(AWXPaymentMethod *)paymentMethod;
- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController didConfirmPaymentMethod:(AWXPaymentMethod *)paymentMethod;

@end

@class AWXPaymentMethod, AWXFormMapping;
@interface AWXPaymentFormViewController : AWXViewController

@property (nonatomic, weak) id <AWXPaymentFormViewControllerDelegate> delegate;
@property (nonatomic, strong) AWXPaymentMethod *paymentMethod;
@property (nonatomic, strong) AWXFormMapping *formMapping;

@end

NS_ASSUME_NONNULL_END
