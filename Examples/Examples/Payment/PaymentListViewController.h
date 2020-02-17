//
//  PaymentListViewController.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const AWWechatpay = @"wechatpay";

@class AWPaymentMethod, PaymentListViewController;

@protocol PaymentListViewControllerDelegate <NSObject>

- (void)paymentListViewController:(PaymentListViewController *)controller didSelectMethod:(AWPaymentMethod *)paymentMethod;

@end

@interface PaymentListViewController : UIViewController

@property (nonatomic, weak) id <PaymentListViewControllerDelegate> delegate;
@property (nonatomic, strong, nullable) AWPaymentMethod *paymentMethod;

@end

NS_ASSUME_NONNULL_END
