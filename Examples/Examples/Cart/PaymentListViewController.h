//
//  PaymentListViewController.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AWPaymentMethod;

NS_ASSUME_NONNULL_BEGIN

@interface PaymentListViewController : UIViewController

@property (nonatomic, strong) AWPaymentMethod *paymentMethod;

@end

NS_ASSUME_NONNULL_END
