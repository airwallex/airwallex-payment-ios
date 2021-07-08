//
//  AWXUIContext.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/9.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AWXWeChatPaySDKResponse, AWXPaymentMethodListViewController, AWXCardViewController, AWXPaymentViewController, AWXShippingViewController, AWXPaymentIntent, AWXPlaceDetails;

typedef NS_ENUM(NSUInteger, AWXPaymentStatus) {
    AWXPaymentStatusSuccess,
    AWXPaymentStatusError,
};

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles checkout results.
 */
@protocol AWXPaymentResultDelegate <NSObject>

/**
 This method is called when the user has completed the checkout.

 @param controller The controller handling payment result.
 @param status The status of checkout result.
 @param error The error if checkout failed.
 */
- (void)paymentViewController:(UIViewController *)controller didFinishWithStatus:(AWXPaymentStatus)status error:(nullable NSError *)error;

/**
 This method is called when wechat pay is needed.

 @param controller The controller handling payment result.
 @param response The wechat object.
 */
- (void)paymentViewController:(UIViewController *)controller nextActionWithWeChatPaySDK:(AWXWeChatPaySDKResponse *)response;

/**
 This method is called when alipay is needed.

 @param controller The controller handling payment result.
 @param url The url to launch alipay.
 */
- (void)paymentViewController:(UIViewController *)controller nextActionWithAlipayURL:(NSURL *)url;

@end

/**
 `AWXUIContext` generates payment method list, new card, payment detail and shipping view controllers.
 */
@interface AWXUIContext : NSObject

/**
 The delegate which handles checkout events.
 */
@property (nonatomic, weak) id <AWXPaymentResultDelegate> delegate;

/**
 The hostViewController will present or push the payment flow.
 */
@property (nonatomic, weak) UIViewController *hostViewController;

/**
 The payment intent to handle.
 */
@property (nonatomic, strong, nullable) AWXPaymentIntent *paymentIntent;

/**
 The shipping address.
 */
@property (nonatomic, strong, nullable) AWXPlaceDetails *shipping;

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
+ (AWXPaymentMethodListViewController *)paymentMethodListViewController;

/**
 Convenience constructor for a new card.
 
 @return The newly created new card view controller.
 */
+ (AWXCardViewController *)newCardViewController;

/**
 Convenience constructor for a payment detail.
 
 @return The newly created payment detail view controller.
 */
+ (AWXPaymentViewController *)paymentDetailViewController;

/**
 Convenience constructor for a shipping.
 
 @return The newly created shipping view controller.
 */
+ (AWXShippingViewController *)shippingViewController;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@end


@interface AWXRecurringUIContext: AWXUIContext

@end

NS_ASSUME_NONNULL_END
