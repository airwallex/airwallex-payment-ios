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

/**
 A delegate which handles selected billing.
 */
@protocol AWEditShippingViewControllerDelegate <NSObject>

/**
 This method is called when a billing has been saved.
 
 @param controller The shipping view controller.
 @param billing The selected billing.
 */
- (void)editShippingViewController:(AWEditShippingViewController *)controller didSelectBilling:(AWBilling *)billing;

@end

/**
 `AWEditShippingViewController` provides a form to edit shipping address.
 */
@interface AWEditShippingViewController : AWViewController

/**
 A delegate which handles saved billing.
 */
@property (nonatomic, weak) id <AWEditShippingViewControllerDelegate> delegate;

/**
 Saved shippping.
 */
@property (nonatomic, strong) AWBilling *shipping;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
