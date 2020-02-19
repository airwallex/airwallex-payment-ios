//
//  EditBillingViewController.h
//  Examples
//
//  Created by Victor Zhu on 2020/2/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AWBilling, EditBillingViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol EditBillingViewControllerDelegate <NSObject>

- (void)didEndEditingBillingViewController:(EditBillingViewController *)controller;

@end

@interface EditBillingViewController : UIViewController

@property (nonatomic, weak) id <EditBillingViewControllerDelegate> delegate;
@property (nonatomic, strong, nullable) AWBilling *billing;
@property (nonatomic) BOOL sameAsShipping;

@end

NS_ASSUME_NONNULL_END
