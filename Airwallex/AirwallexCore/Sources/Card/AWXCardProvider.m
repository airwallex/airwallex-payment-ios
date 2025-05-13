//
//  AWXCardProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/19.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXCardProvider.h"
#import "AWXAPIClient.h"
#import "AWXCardCVCViewController.h"
#import "AWXDevice.h"
#import "AWXPaymentConsent.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodOptions.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXSession.h"
#import "AWXUtils.h"
#import "NSObject+Logging.h"

@implementation AWXCardProvider

+ (BOOL)canHandleSession:(AWXSession *)session paymentMethod:(AWXPaymentMethodType *)paymentMethod {
    return paymentMethod.cardSchemes.count != 0;
}

- (instancetype)initWithDelegate:(id<AWXProviderDelegate>)delegate session:(AWXSession *)session {
    return [self initWithDelegate:delegate session:session paymentMethodType:nil];
}

- (instancetype)initWithDelegate:(id<AWXProviderDelegate>)delegate session:(AWXSession *)session paymentMethodType:(AWXPaymentMethodType *)paymentMethodType {
    self = [super initWithDelegate:delegate session:session paymentMethodType:paymentMethodType];
    return self;
}

- (void)confirmPaymentIntentWithCard:(AWXCard *)card
                             billing:(AWXPlaceDetails *)billing
                            saveCard:(BOOL)saveCard {
    [self log:@"Start payment confirm. Type: Card. Intent Id:%@", self.session.paymentIntentId];

    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = AWXCardKey;
    paymentMethod.billing = billing;
    paymentMethod.card = card;
    paymentMethod.customerId = self.session.customerId;

    [self.delegate providerDidStartRequest:self];
    [self log:@"Delegate: %@, providerDidStartRequest:", self.delegate.class];

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
                               [strongSelf log:@"Delegate: %@, providerDidEndRequest:", self.delegate.class];
                               [strongSelf.delegate provider:strongSelf didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
                               [strongSelf log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu  %@", strongSelf.delegate.class, AirwallexPaymentStatusFailure, error.localizedDescription];
                           }
                       }];
    }
}

- (void)confirmPaymentIntentWithPaymentConsent:(AWXPaymentConsent *)paymentConsent {
    // Get the host view controller from the delegate
    UIViewController *hostViewController = nil;
    if ([self.delegate respondsToSelector:@selector(hostViewController)]) {
        hostViewController = [self.delegate hostViewController];
    }

    if (!hostViewController) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"hostViewController of AWXProviderDelegate is not provided"
                                     userInfo:nil];
    }

    // Check payment method type
    if ([paymentConsent.paymentMethod.card.numberType isEqualToString:@"PAN"]) {
        AWXCardCVCViewController *controller = [[AWXCardCVCViewController alloc] initWithNibName:nil bundle:nil];
        controller.session = self.session;
        controller.paymentConsent = paymentConsent;
        controller.delegate = self;

        UIImage *image = [UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle] compatibleWithTraitCollection:nil];
        if (image) {
            UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(close)];
            controller.navigationItem.leftBarButtonItem = leftBarButtonItem;
        }

        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        navigationController.modalInPresentation = YES;
        [hostViewController presentViewController:navigationController animated:YES completion:nil];
    } else {
        [self confirmPaymentIntentWithPaymentConsentId:paymentConsent.Id];
    }
}

- (void)close {
    UIViewController *hostVC = nil;
    if ([self.delegate respondsToSelector:@selector(hostViewController)]) {
        hostVC = [self.delegate hostViewController];
    }

    if (hostVC) {
        UINavigationController *navController = (UINavigationController *)hostVC.presentedViewController;

        if ([navController isKindOfClass:[UINavigationController class]]) {
            NSInteger index = [navController.viewControllers indexOfObjectPassingTest:^BOOL(__kindof UIViewController *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                return [obj isKindOfClass:[AWXCardCVCViewController class]];
            }];

            if (index != NSNotFound) {
                [navController dismissViewControllerAnimated:YES
                                                  completion:^{
                                                      if ([self.delegate respondsToSelector:@selector(provider:didCompleteWithStatus:error:)]) {
                                                          [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusCancel error:nil];
                                                      }
                                                  }];
            }
        }
    }
}

- (void)confirmPaymentIntentWithPaymentConsentId:(NSString *)paymentConsentId {
    [self.delegate providerDidStartRequest:self];
    [self log:@"Delegate: %@, providerDidStartRequest:", self.delegate.class];

    __weak __typeof(self) weakSelf = self;
    [self confirmPaymentIntentWithPaymentConsentId:paymentConsentId
                                        completion:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
                                            __strong __typeof(weakSelf) strongSelf = weakSelf;
                                            [strongSelf completeWithResponse:(AWXConfirmPaymentIntentResponse *)response error:error];
                                        }];
}

#pragma mark - Internal Actions

- (void)confirmPaymentIntentWithPaymentConsentId:(NSString *)paymentConsentId
                                      completion:(AWXRequestHandler)completion {
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    AWXPaymentConsent *consent = [AWXPaymentConsent new];
    consent.Id = paymentConsentId;
    request.intentId = self.session.paymentIntentId;
    request.customerId = self.session.customerId;
    request.device = [AWXDevice deviceWithRiskSessionId];
    request.paymentConsent = consent;
    request.returnURL = AWXThreeDSReturnURL;

    if ([self.session respondsToSelector:@selector(autoCapture)]) {
        AWXCardOptions *cardOptions = [AWXCardOptions new];
        cardOptions.autoCapture = [[self.session valueForKey:@"autoCapture"] boolValue];
        // assume payment consent can only be card payment type, so set 3ds return url anyway
        AWXThreeDs *threeDs = [AWXThreeDs new];
        threeDs.returnURL = AWXThreeDSReturnURL;
        cardOptions.threeDs = threeDs;

        AWXPaymentMethodOptions *options = [AWXPaymentMethodOptions new];
        options.cardOptions = cardOptions;
        request.options = options;
    }

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request withCompletionHandler:completion];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod {
    [self confirmPaymentIntentWithPaymentMethod:paymentMethod paymentConsent:nil];
}

- (void)createPaymentMethod:(AWXPaymentMethod *)paymentMethod
                 completion:(AWXRequestHandler)completion {
    AWXCreatePaymentMethodRequest *request = [AWXCreatePaymentMethodRequest new];
    request.paymentMethod = paymentMethod;

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request withCompletionHandler:completion];
}

// MARK: AWXPaymentResultDelegate

- (void)paymentViewController:(UIViewController *)controller didCompleteWithStatus:(AirwallexPaymentStatus)status error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES
                                   completion:^{
                                       if ([self.delegate respondsToSelector:@selector(provider:didCompleteWithStatus:error:)]) {
                                           [self.delegate provider:self didCompleteWithStatus:status error:error];
                                       }
                                   }];
}

- (void)paymentViewController:(UIViewController *)controller didCompleteWithPaymentConsentId:(NSString *)paymentConsentId {
    if ([self.delegate respondsToSelector:@selector(provider:didCompleteWithPaymentConsentId:)]) {
        [self.delegate provider:self didCompleteWithPaymentConsentId:paymentConsentId];
    }
}

@end
