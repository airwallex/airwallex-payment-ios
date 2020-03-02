//
//  AWPaymentListViewController.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWViewController.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const AWWechatpay = @"wechatpay";

@class AWPaymentMethod, AWPaymentListViewController;

@protocol AWPaymentListViewControllerDelegate <NSObject>

- (void)paymentListViewController:(AWPaymentListViewController *)controller didSelectMethod:(AWPaymentMethod *)paymentMethod;

@end

@interface AWPaymentListViewController : AWViewController

@property (nonatomic, weak) id <AWPaymentListViewControllerDelegate> delegate;
@property (nonatomic, strong, nullable) AWPaymentMethod *paymentMethod;

@end

NS_ASSUME_NONNULL_END
