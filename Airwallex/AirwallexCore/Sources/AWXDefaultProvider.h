//
//  AWXDefaultProvider.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/22.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "AWXConstants.h"
#import "AWXSession.h"
#import <UIKit/UIKit.h>

@class AWXDefaultProvider, AWXConfirmPaymentIntentResponse;

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles checkout results.
 */
@protocol AWXProviderDelegate<NSObject>

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
 This method is called when payment is completed.

 @param provider The provider handling payment.
 @param status The status of payment.
 @param error The error of payment.
 */
- (void)provider:(AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error;

@optional
/**
 The view controller that any additional UI (e.g. 3DS view, error alert view) will be presented on.
 */
- (UIViewController *)hostViewController;

/**
 This method is called when the next action is required.

 @param provider The provider handling payment.
 @param nextAction The next action.
 */
- (void)provider:(AWXDefaultProvider *)provider shouldHandleNextAction:(AWXConfirmPaymentNextAction *)nextAction;

/**
 This method is called when new controller is required.

 @param provider The provider handling payment.
 @param controller The view controller will be presented.
 @param forceToDismiss Whether the presenting view controller needs be dismissed forcibly.
 */
- (void)provider:(AWXDefaultProvider *)provider shouldPresentViewController:(UIViewController *_Nullable)controller forceToDismiss:(BOOL)forceToDismiss withAnimation:(BOOL)withAnimation;

/**
 This method is called when new controller is required. (as child view controller)

 @param provider The provider handling payment.
 @param controller The view controller will be presented.
 */
- (void)provider:(AWXDefaultProvider *)provider shouldInsertViewController:(UIViewController *)controller;

/**
 This method is called when payment is completed and payment consent id is produced.

 @param provider The provider handling payment.
 @param paymentConsentId The id of payment consent.
 */
- (void)provider:(AWXDefaultProvider *)provider didCompleteWithPaymentConsentId:(NSString *)paymentConsentId;

@end

/**
 A provider which handles payment business.
 */
@interface AWXDefaultProvider : NSObject

/**
 A delegate which handles payment result.
 */
@property (nonatomic, weak, readonly) id<AWXProviderDelegate> delegate;

/**
 A session which includes the detail of payment.
 */
@property (nonatomic, readonly) AWXSession *session;

/**
 Original payment method response
 */
@property (nonatomic, readonly, nullable) AWXPaymentMethodType *paymentMethodType;

/**
 A payment method.
 */
@property (nonatomic, readonly, nullable) AWXPaymentMethod *paymentMethod;

/// Payment consent used/generated in payment flow
@property (nonatomic, strong, nullable) AWXPaymentConsent *paymentConsent;
/**
 whether should show this payment directly.
 */
@property (nonatomic) BOOL showPaymentDirectly __deprecated_msg("not used anymore");

/**
 Indicating whether the provider can handle a particular session. Default implementation returns YES. Subclasses can override to
 do additional checks.
 */
+ (BOOL)canHandleSession:(AWXSession *)session paymentMethod:(AWXPaymentMethodType *)paymentMethod;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(id<AWXProviderDelegate>)delegate session:(AWXSession *)session;
- (instancetype)initWithDelegate:(id<AWXProviderDelegate>)delegate session:(AWXSession *)session paymentMethodType:(AWXPaymentMethodType *_Nullable)paymentMethodType;

/**
 Start the payment flow.
 */
- (void)handleFlow;

/**
 Create a new payment consent and confirm the payment intent with payment method.

 @param paymentMethod The payment method info.
 */
- (void)createPaymentConsentAndConfirmIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod;

/**
 Create a new payment consent and confirm the payment intent with payment method as well as a custom completion block.

 @param paymentMethod The payment method info.
 @param completion The completion block to be called with the response and error.
 */
- (void)createPaymentConsentAndConfirmIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                                                   completion:(AWXRequestHandler)completion;

/**
 Confirm the payment intent with payment method and consent.

 @param paymentMethod The payment method info.
 @param paymentConsent The payment consent info.
 */
- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                               paymentConsent:(nullable AWXPaymentConsent *)paymentConsent;

/**
 Confirm the payment intent with payment method and consent.

 @param paymentMethod The payment method info.
 @param paymentConsent The payment consent info.
 @param flow The payment method flow.
 */
- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                               paymentConsent:(nullable AWXPaymentConsent *)paymentConsent
                                         flow:(AWXPaymentMethodFlow)flow;

/**
 Confirm the payment intent with payment method and consent as well as a custom completion block.

 @param paymentMethod The payment method info.
 @param paymentConsent The payment consent info.
 @param completion The completion block to be called with the response and error.
 */
- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                               paymentConsent:(nullable AWXPaymentConsent *)paymentConsent
                                   completion:(AWXRequestHandler)completion;

/**
 Complete the payment flow.

 @param response The payment response.
 @param error The error of payment flow.
 */
- (void)completeWithResponse:(nullable AWXConfirmPaymentIntentResponse *)response
                       error:(nullable NSError *)error;
@end

NS_ASSUME_NONNULL_END
