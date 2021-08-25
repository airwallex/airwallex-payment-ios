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

@protocol AWXProviderDelegate <NSObject>

- (void)providerDidStartRequest:(AWXDefaultProvider *)provider;

- (void)providerDidEndRequest:(AWXDefaultProvider *)provider;

- (void)provider:(AWXDefaultProvider *)provider didInitializePaymentIntentId:(NSString *)paymentIntentId;

- (void)provider:(AWXDefaultProvider *)provider shouldHandleNextAction:(AWXConfirmPaymentNextAction *)nextAction;

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error;

@optional
- (void)provider:(AWXDefaultProvider *)provider shouldPresentViewController:(nullable UIViewController *)controller forceToDismiss:(BOOL)forceToDismiss;

@end

@interface AWXDefaultProvider : NSObject

@property (nonatomic, weak, readonly) id <AWXProviderDelegate> delegate;
@property (nonatomic, readonly) AWXSession *session;
@property (nonatomic, readonly, nullable) AWXDevice *device;
@property (nonatomic, readonly, nullable) AWXPaymentMethod *paymentMethod;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(id <AWXProviderDelegate>)delegate session:(AWXSession *)session;
- (instancetype)initWithDelegate:(id <AWXProviderDelegate>)delegate session:(AWXSession *)session paymentMethod:(nullable AWXPaymentMethod *)paymentMethod;

- (void)handleFlow;

- (void)confirmPaymentIntentWithCard:(AWXCard *)card
                             billing:(AWXPlaceDetails *)billing;

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                               paymentConsent:(nullable AWXPaymentConsent *)paymentConsent;
- (void)completeWithResponse:(nullable AWXConfirmPaymentIntentResponse *)response
                       error:(nullable NSError *)error;
@end

NS_ASSUME_NONNULL_END
