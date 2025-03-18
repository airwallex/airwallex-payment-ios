//
//  AWXUIContext.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/9.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXConstants.h"
#import "AWXSession.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AWXWeChatPaySDKResponse, AWXPaymentMethodListViewController, AWXCardViewController, AWXPaymentViewController, AWXShippingViewController, AWXPaymentIntent, AWXPlaceDetails;

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles checkout results.
 */
@protocol AWXPaymentResultDelegate<NSObject>

/**
 This method is called when the user has completed the checkout.

 @param controller The controller handling payment result. Might be nil if user pop/dismiss payment view controller.
 @param status The status of checkout result.
 @param error The error if checkout failed.
 */
- (void)paymentViewController:(UIViewController *_Nullable)controller didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error;

@optional

/**
 This method is called when the user has completed the checkout and payment consent id is produced.

 @param controller The controller handling payment result.
 @param paymentConsentId The id of payment consent.
 */
- (void)paymentViewController:(UIViewController *_Nullable)controller didCompleteWithPaymentConsentId:(NSString *)paymentConsentId;

@end

/**
 `AWXUIContext` generates payment method list, new card, payment detail and shipping view controllers.
 */
@interface AWXUIContext : NSObject

/**
 The delegate which handles checkout events.
 */
@property (nonatomic, weak) id<AWXPaymentResultDelegate> delegate;

/**
 Cureent session to handle.
 */
@property (nonatomic, strong) AWXSession *session;

/// one time dismiss action, will be set every time `launchPayment(from:style:)` called
/// and consumed in `PaymentSessionHandler` after payement success/failure/cancelled
@property (nonatomic, copy, nullable) void (^paymentUIDismissAction)(void (^_Nullable completion)(void));

/**
 Convenience constructor for a context.

 @return The shared context.
 */
+ (instancetype)sharedContext;

/**
 Present the entire payment flow from payment methods list.
 */
- (void)presentEntirePaymentFlowFrom:(UIViewController *)hostViewController __deprecated_msg("Use launchPayment(from:style:) in AWXUIContext+Extensions.swift within the Payment Module instead.");

- (void)presentPaymentFlowFrom:(UIViewController *)hostViewController __attribute__((deprecated("Use 'presentEntirePaymentFlowFrom' instead")));

/**
 Push the entire payment flow from payment methods list.
 */
- (void)pushEntirePaymentFlowFrom:(UIViewController *)hostViewController __deprecated_msg("Use launchPayment(from:style:) in AWXUIContext+Extensions.swift within the Payment Module instead.");

- (void)pushPaymentFlowFrom:(UIViewController *)hostViewController __attribute__((deprecated("Use 'pushEntirePaymentFlowFrom' instead")));

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
