//
//  AWEditBillingViewController.h
//  Examples
//
//  Created by Victor Zhu on 2020/2/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AWBilling, AWEditBillingViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol AWEditBillingViewControllerDelegate <NSObject>

- (void)didEndEditingBillingViewController:(AWEditBillingViewController *)controller;

@end

@interface AWEditBillingViewController : UIViewController

@property (nonatomic, weak) id <AWEditBillingViewControllerDelegate> delegate;
@property (nonatomic, strong, nullable) AWBilling *billing;
@property (nonatomic) BOOL sameAsShipping;

@end

NS_ASSUME_NONNULL_END
