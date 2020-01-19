//
//  EditShippingViewController.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AWBilling, EditShippingViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol EditShippingViewControllerDelegate <NSObject>

- (void)editShippingViewController:(EditShippingViewController *)controller didSelectBilling:(AWBilling *)billing;

@end

@interface EditShippingViewController : UIViewController

@property (nonatomic, weak) id <EditShippingViewControllerDelegate> delegate;
@property (nonatomic, strong) AWBilling *billing;

@end

NS_ASSUME_NONNULL_END
