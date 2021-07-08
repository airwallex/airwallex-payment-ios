//
//  AWXPaymentMethodListViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXViewController.h"

@class AWXPaymentMethodListViewController, AWXPaymentMethod, AWXPlaceDetails,AWXPaymentConsent;

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles selected payment method.
 */
@protocol AWXPaymentMethodListViewControllerDelegate <NSObject>

/**
 This method is called when a payment method has been selected.
 
 @param controller The payment method list view controller.
 @param paymentMethod The selected payment method.
 */
- (void)paymentMethodListViewController:(AWXPaymentMethodListViewController *)controller didSelectPaymentMethod:(AWXPaymentMethod *)paymentMethod;

@end

/**
 `AWXPaymentMethodListViewController` provides a list of payment method.
 */
@interface AWXPaymentMethodListViewController : AWXViewController

/**
 A delegate which handles selected payment method.
 */
@property (nonatomic, weak) id <AWXPaymentMethodListViewControllerDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
