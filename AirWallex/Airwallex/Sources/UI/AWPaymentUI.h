//
//  AWPaymentUI.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/9.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AWPaymentListViewController, AWCardViewController, AWPaymentViewController, AWEditShippingViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 `AWPaymentUI` generates payment method list, new card, payment detail and shipping view controllers.
 */
@interface AWPaymentUI : NSObject

/**
 Convenience constructor for a payment method list.

 @return The newly created payment method list navigation view controller.
 */
+ (UINavigationController *)paymentMethodListNavigationController;

/**
 Convenience constructor for a new card.

 @return The newly created new card navigation view controller.
 */
+ (UINavigationController *)newCardNavigationController;

/**
 Convenience constructor for a payment detail.

 @return The newly created payment detail navigation view controller.
 */
+ (UINavigationController *)paymentDetailNavigationController;

/**
 Convenience constructor for a shipping.

 @return The newly created shipping view controller.
 */
+ (AWEditShippingViewController *)shippingViewController;

/**
 Convenience constructor for a shipping.

 @return The newly created shipping navigation view controller.
 */
+ (UINavigationController *)shippingNavigationController;

@end

NS_ASSUME_NONNULL_END
