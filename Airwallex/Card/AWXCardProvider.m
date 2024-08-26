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
#import "AWXDevice.h"
#import "AWXPaymentConsent.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodOptions.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXSession.h"
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

- (void)handleFlow {
    AWXCardViewController *controller = [[AWXCardViewController alloc] initWithNibName:nil bundle:nil];
    controller.session = self.session;
    controller.viewModel = [[AWXCardViewModel alloc] initWithSession:self.session supportedCardSchemes:self.paymentMethodType.cardSchemes launchDirectly:self.showPaymentDirectly];
    [self.delegate provider:self shouldPresentViewController:controller forceToDismiss:NO withAnimation:YES];
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

- (void)confirmPaymentIntentWithPaymentConsentId:(NSString *)paymentConsentId {
    [self.delegate providerDidStartRequest:self];
    [self log:@"Delegate: %@, providerDidStartRequest:", self.delegate.class];

    __weak __typeof(self) weakSelf = self;
    [self confirmPaymentIntentWithPaymentConsentId:paymentConsentId
                                            device:[AWXDevice deviceWithRiskSessionId]
                                        completion:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
                                            __strong __typeof(weakSelf) strongSelf = weakSelf;
                                            [strongSelf completeWithResponse:(AWXConfirmPaymentIntentResponse *)response error:error];
                                        }];
}

#pragma mark - Internal Actions

- (void)confirmPaymentIntentWithPaymentConsentId:(NSString *)paymentConsentId
                                          device:(AWXDevice *)device
                                      completion:(AWXRequestHandler)completion {
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    AWXPaymentConsent *consent = [AWXPaymentConsent new];
    consent.Id = paymentConsentId;
    request.requestId = NSUUID.UUID.UUIDString;
    request.intentId = self.session.paymentIntentId;
    request.customerId = self.session.customerId;
    request.device = device;
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
    [client send:request handler:completion];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod {
    [self confirmPaymentIntentWithPaymentMethod:paymentMethod paymentConsent:nil device:[AWXDevice deviceWithRiskSessionId]];
}

- (void)createPaymentConsentAndConfirmIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod {
    [self createPaymentConsentAndConfirmIntentWithPaymentMethod:paymentMethod device:[AWXDevice deviceWithRiskSessionId]];
}

- (void)createPaymentMethod:(AWXPaymentMethod *)paymentMethod
                 completion:(AWXRequestHandler)completion {
    AWXCreatePaymentMethodRequest *request = [AWXCreatePaymentMethodRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.paymentMethod = paymentMethod;

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:completion];
}

@end
