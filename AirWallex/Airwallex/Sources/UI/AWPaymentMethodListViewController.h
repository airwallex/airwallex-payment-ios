//
//  AWPaymentMethodListViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWViewController.h"

@class AWPaymentMethodListViewController, AWPaymentMethod, AWPlaceDetails;

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles selected payment method.
 */
@protocol AWPaymentMethodListViewControllerDelegate <NSObject>

/**
 This method is called when a payment method has been selected.
 
 @param controller The payment method list view controller.
 @param paymentMethod The selected payment method.
 */
- (void)paymentMethodListViewController:(AWPaymentMethodListViewController *)controller didSelectPaymentMethod:(AWPaymentMethod *)paymentMethod;

@end

/**
 `AWPaymentMethodListViewController` provides a list of payment method.
 */
@interface AWPaymentMethodListViewController : AWViewController

/**
 A delegate which handles selected payment method.
 */
@property (nonatomic, weak) id <AWPaymentMethodListViewControllerDelegate> delegate;

/**
 Selected payment method.
 */
@property (nonatomic, strong, nullable) AWPaymentMethod *paymentMethod;

/**
 A  shipping address.
 */
@property (nonatomic, strong, nullable) AWPlaceDetails *shipping;

/**
 A customer id.
 */
@property (nonatomic, strong, nullable) NSString *customerId;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
