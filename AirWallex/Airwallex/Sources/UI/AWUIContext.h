//
//  AWUIContext.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/9.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AWWeChatPaySDKResponse, AWPaymentMethodListViewController, AWCardViewController, AWPaymentViewController, AWShippingViewController, AWPaymentIntent, AWPlaceDetails;

typedef NS_ENUM(NSUInteger, AWPaymentStatus) {
    AWPaymentStatusSuccess,
    AWPaymentStatusError,
};

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles checkout results.
 */
@protocol AWPaymentResultDelegate <NSObject>

/**
 This method is called when the user has completed the checkout.

 @param controller The controller handling payment result.
 @param status The status of checkout result.
 @param error The error if checkout failed.
 */
- (void)paymentViewController:(UIViewController *)controller didFinishWithStatus:(AWPaymentStatus)status error:(nullable NSError *)error;

/**
 This method is called when wechat pay is needed.

 @param controller The controller handling payment result.
 @param response The wechat object.
 */
- (void)paymentViewController:(UIViewController *)controller nextActionWithWeChatPaySDK:(AWWeChatPaySDKResponse *)response;

@end

/**
 `AWUIContext` generates payment method list, new card, payment detail and shipping view controllers.
 */
@interface AWUIContext : NSObject

/**
 The delegate which handles checkout events.
 */
@property (nonatomic, weak) id <AWPaymentResultDelegate> delegate;

/**
 The hostViewController will present or push the payment flow.
 */
@property (nonatomic, weak) UIViewController *hostViewController;

/**
 The payment intent to handle.
 */
@property (nonatomic, strong) AWPaymentIntent *paymentIntent;

/**
 The shipping address.
 */
@property (nonatomic, strong, nullable) AWPlaceDetails *shipping;

/**
 Convenience constructor for a context.
 
 @return The shared context.
 */
+ (instancetype)sharedContext;

/**
 Present the payment flow.
 */
- (void)presentPaymentFlow;

/**
 Push the payment flow.
 */
- (void)pushPaymentFlow;

/**
 Convenience constructor for a payment method list.
 
 @return The newly created payment method list view controller.
 */
+ (AWPaymentMethodListViewController *)paymentMethodListViewController;

/**
 Convenience constructor for a new card.
 
 @return The newly created new card view controller.
 */
+ (AWCardViewController *)newCardViewController;

/**
 Convenience constructor for a payment detail.
 
 @return The newly created payment detail view controller.
 */
+ (AWPaymentViewController *)paymentDetailViewController;

/**
 Convenience constructor for a shipping.
 
 @return The newly created shipping view controller.
 */
+ (AWShippingViewController *)shippingViewController;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
