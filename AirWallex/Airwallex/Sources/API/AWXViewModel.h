//
//  AWXViewModel.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/11.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AWXViewModel, AWXSession, AWXCard, AWXPlaceDetails, AWXPaymentMethod, AWXPaymentConsent, AWXConfirmPaymentNextAction;

NS_ASSUME_NONNULL_BEGIN

@protocol AWXViewModelDelegate <NSObject>

- (void)viewModelDidStartRequest:(AWXViewModel *)viewModel;
- (void)viewModelDidEndRequest:(AWXViewModel *)viewModel;
- (void)viewModel:(AWXViewModel *)viewModel didCompleteWithError:(NSError *)error;
- (void)viewModel:(AWXViewModel *)viewModel didCreatePaymentConsent:(AWXPaymentConsent *)paymentConsent;
- (void)viewModel:(AWXViewModel *)viewModel didInitializePaymentIntentId:(NSString *)paymentIntentId;
- (void)viewModel:(AWXViewModel *)viewModel shouldHandleNextAction:(AWXConfirmPaymentNextAction *)nextAction;

@optional
- (void)viewModel:(AWXViewModel *)viewModel didCreatePaymentMethod:(nullable AWXPaymentMethod *)paymentMethod error:(NSError *)error;

@end

@interface AWXViewModel : NSObject

@property (nonatomic, readonly) AWXSession *session;
@property (nonatomic, weak) id <AWXViewModelDelegate> delegate;

- (instancetype)initWithSession:(AWXSession *)session
                       delegate:(id <AWXViewModelDelegate>)delegate;

- (void)confirmPaymentIntentWithCard:(AWXCard *)card
                             billing:(AWXPlaceDetails *)billing;
- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                               paymentConsent:(nullable AWXPaymentConsent *)paymentConsent;
- (void)handleThreeDSWithJwt:(NSString *)jwt
    presentingViewController:(UIViewController *)presentingViewController;
- (void)confirmThreeDSWithUseDCC:(BOOL)useDCC;

@end

NS_ASSUME_NONNULL_END
