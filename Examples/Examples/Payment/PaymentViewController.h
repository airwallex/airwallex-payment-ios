//
//  PaymentViewController.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AWBilling;

@interface PaymentViewController : UIViewController

@property (strong, nonatomic) NSDecimalNumber *total;
@property (nonatomic) BOOL sameAsShipping;
@property (strong, nonatomic) AWBilling *shipping;

@end

NS_ASSUME_NONNULL_END
