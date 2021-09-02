//
//  AWXDefaultProvider.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/22.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWXConstants.h"

@class AWXDefaultProvider, AWXConfirmPaymentNextAction, AWXSession, AWXDevice, AWXPaymentMethod, AWXPaymentConsent, AWXConfirmPaymentIntentResponse, AWXCard, AWXPlaceDetails;

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles checkout results.
 */
@protocol AWXProviderDelegate <NSObject>

/**
 This method is called when it is doing requesting.
 
 @param provider The provider handling payment.
 */
- (void)providerDidStartRequest:(AWXDefaultProvider *)provider;

/**
 This method is called when it is completing requesting.
 
 @param provider The provider handling payment.
 */
- (void)providerDidEndRequest:(AWXDefaultProvider *)provider;

/**
 This method is called when it is generated new payment intent.
 
 @param provider The provider handling payment.
 @param paymentIntentId The new payment intent id.
 */
- (void)provider:(AWXDefaultProvider *)provider didInitializePaymentIntentId:(NSString *)paymentIntentId;

/**
 This method is called when it is generated new payment intent.
 
 @param provider The provider handling payment.
 @param nextAction The next action.
 */
- (void)provider:(AWXDefaultProvider *)provider shouldHandleNextAction:(AWXConfirmPaymentNextAction *)nextAction;

/**
 This method is called when it is generated new payment intent.
 
 @param provider The provider handling payment.
 @param status The status of payment.
 @param error The error of payment.
 */
- (void)provider:(AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error;

@optional
/**
 This method is called when it is generated new payment intent.
 
 @param provider The provider handling payment.
 @param controller The view controller will be presented.
 @param forceToDismiss Whether the presenting view controller needs be dismissed forcibly.
 */
- (void)provider:(AWXDefaultProvider *)provider shouldPresentViewController:(nullable UIViewController *)controller forceToDismiss:(BOOL)forceToDismiss;

@end

/**
 A provider which handles payment business.
 */
@interface AWXDefaultProvider : NSObject

/**
 A delegate which handles payment result.
 */
@property (nonatomic, weak, readonly) id <AWXProviderDelegate> delegate;

/**
 A session which includes the detail of payment.
 */
@property (nonatomic, readonly) AWXSession *session;

/**
 The current device info.
 */
@property (nonatomic, readonly, nullable) AWXDevice *device;

/**
 A payment method.
 */
@property (nonatomic, readonly, nullable) AWXPaymentMethod *paymentMethod;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(id <AWXProviderDelegate>)delegate session:(AWXSession *)session;
- (instancetype)initWithDelegate:(id <AWXProviderDelegate>)delegate session:(AWXSession *)session paymentMethod:(nullable AWXPaymentMethod *)paymentMethod;

/**
 Start the payment flow.
 */
- (void)handleFlow;

/**
 Confirm the payment intent with card and billing.
 
 @param card The card info.
 @param billing The billing info.
 */
- (void)confirmPaymentIntentWithCard:(AWXCard *)card
                             billing:(AWXPlaceDetails *)billing;

/**
 Confirm the payment intent with payment method and consent.
 
 @param paymentMethod The payment method info.
 @param paymentConsent The payment consent info.
 */
- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                               paymentConsent:(nullable AWXPaymentConsent *)paymentConsent;

/**
 Complete the payment flow.
 
 @param response The payment response.
 @param error The error of payment flow.
 */
- (void)completeWithResponse:(nullable AWXConfirmPaymentIntentResponse *)response
                       error:(nullable NSError *)error;
@end

NS_ASSUME_NONNULL_END
