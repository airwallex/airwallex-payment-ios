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
 The hostViewController will present or push the payment flow.
 */
@property (nonatomic, weak) UIViewController *hostViewController;

/**
 Cureent session to handle.
 */
@property (nonatomic, strong) AWXSession *session;

/**
 Convenience constructor for a context.

 @return The shared context.
 */
+ (instancetype)sharedContext;

/**
 Present the payment flow.
 */
- (void)presentPaymentFlowFrom:(UIViewController *)hostViewController;

/**
 Push the payment flow.
 */
- (void)pushPaymentFlowFrom:(UIViewController *)hostViewController;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
