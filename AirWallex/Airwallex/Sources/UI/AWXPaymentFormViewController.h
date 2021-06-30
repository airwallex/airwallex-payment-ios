//
//  AWXPaymentFormViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/17.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class AWXPaymentFormViewController;
@protocol AWXPaymentFormViewControllerDelegate <NSObject>

- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController didConfirmPayment:(NSDictionary *)params;
- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController didSelectOption:(NSString *)option;

@end

@class AWXPaymentMethod, AWXFormMapping;
@interface AWXPaymentFormViewController : AWXViewController

@property (nonatomic, weak) id <AWXPaymentFormViewControllerDelegate> delegate;
@property (nonatomic, strong) AWXPaymentMethod *paymentMethod;
@property (nonatomic, strong) AWXFormMapping *formMapping;

@end

NS_ASSUME_NONNULL_END
