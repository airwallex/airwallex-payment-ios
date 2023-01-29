//
//  AWXCardProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/19.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXCardProvider.h"
#import "AWXAPIClient.h"
#import "AWXCardViewController.h"
#import "AWXCardViewModel.h"
#import "AWXDefaultProvider+Security.h"
#import "AWXDevice.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXSession.h"

@implementation AWXCardProvider

+ (BOOL)canHandleSession:(AWXSession *)session paymentMethod:(AWXPaymentMethodType *)paymentMethod {
    return paymentMethod.cardSchemes.count != 0;
}

- (void)handleFlow {
    AWXCardViewController *controller = [[AWXCardViewController alloc] initWithNibName:nil bundle:nil];
    controller.session = self.session;
    controller.viewModel = [[AWXCardViewModel alloc] initWithSession:self.session supportedCardSchemes:self.paymentMethodType.cardSchemes];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.delegate provider:self shouldPresentViewController:nav forceToDismiss:NO withAnimation:YES];
}

- (void)confirmPaymentIntentWithCard:(AWXCard *)card
                             billing:(AWXPlaceDetails *)billing
                            saveCard:(BOOL)saveCard {
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = AWXCardKey;
    paymentMethod.billing = billing;
    paymentMethod.card = card;
    paymentMethod.customerId = self.session.customerId;

    [self.delegate providerDidStartRequest:self];
    if ([self.session isKindOfClass:[AWXOneOffSession class]] && !saveCard) {
        [self confirmPaymentIntentWithPaymentMethod:paymentMethod];
    } else {
        __weak __typeof(self) weakSelf = self;
        [self createPaymentMethod:paymentMethod
                       completion:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
                           __strong __typeof(weakSelf) strongSelf = weakSelf;
                           if (response && !error) {
                               AWXCreatePaymentMethodResponse *result = (AWXCreatePaymentMethodResponse *)response;
                               AWXPaymentMethod *paymentMethod = result.paymentMethod;
                               paymentMethod.card.cvc = card.cvc;
                               [strongSelf createPaymentConsentAndConfirmIntentWithPaymentMethod:paymentMethod];
                           } else {
                               [strongSelf.delegate providerDidEndRequest:strongSelf];
                               [strongSelf.delegate provider:strongSelf didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
                           }
                       }];
    }
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod {
    __weak __typeof(self) weakSelf = self;
    [self setDevice:^(AWXDevice *_Nonnull device) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod paymentConsent:nil device:device];
    }];
}

- (void)createPaymentConsentAndConfirmIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod {
    __weak __typeof(self) weakSelf = self;
    [self setDevice:^(AWXDevice *_Nonnull device) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf createPaymentConsentAndConfirmIntentWithPaymentMethod:paymentMethod device:device];
    }];
}

#pragma mark - Internal Actions

- (void)createPaymentMethod:(AWXPaymentMethod *)paymentMethod
                 completion:(AWXRequestHandler)completion {
    AWXCreatePaymentMethodRequest *request = [AWXCreatePaymentMethodRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.paymentMethod = paymentMethod;

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:completion];
}

@end
