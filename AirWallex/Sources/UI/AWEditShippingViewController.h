//
//  AWEditShippingViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWViewController.h"

@class AWBilling, AWEditShippingViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol AWEditShippingViewControllerDelegate <NSObject>

- (void)editShippingViewController:(AWEditShippingViewController *)controller didSelectBilling:(AWBilling *)billing;

@end

@interface AWEditShippingViewController : AWViewController

@property (nonatomic, weak) id <AWEditShippingViewControllerDelegate> delegate;
@property (nonatomic, strong) AWBilling *billing;

@end

NS_ASSUME_NONNULL_END
