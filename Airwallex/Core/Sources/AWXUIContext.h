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

 @param controller The controller handling payment result.
 @param status The status of checkout result.
 @param error The error if checkout failed.
 */
- (void)paymentViewController:(UIViewController *)controller didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error;

@optional

/**
 This method is called when the user has completed the checkout.

 @param controller The controller handling payment result.
 @param Id The id of payment consent.
 */
- (void)paymentViewController:(UIViewController *)controller didCompleteWithPaymentConsentId:(NSString *)Id;

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
 Current session to handle.
 */
@property (nonatomic, strong) AWXSession *session;

/**
 Convenience constructor for a context.

 @return The shared context.
 */
+ (instancetype)sharedContext;

/**
 Present the payment flow from method list.
 */
- (void)presentPaymentFlowFrom:(UIViewController *)hostViewController __attribute__((deprecated("Use newMethod - (void)presentEntirePaymentFlowFrom:(UIViewController *)hostViewController instead")));

/**
 Present the payment flow from method list.
 */
- (void)presentEntirePaymentFlowFrom:(UIViewController *)hostViewController;

/**
 Push the payment flow from method list.
 */
- (void)pushPaymentFlowFrom:(UIViewController *)hostViewController __attribute__((deprecated("Use newMethod - (void)pushEntirePaymentFlowFrom:(UIViewController *)hostViewController instead")));

/**
 Push the payment flow from method list.
 */
- (void)pushEntirePaymentFlowFrom:(UIViewController *)hostViewController;

@end

NS_ASSUME_NONNULL_END
