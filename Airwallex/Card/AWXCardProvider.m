//
//  AWXCardProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/19.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXCardProvider.h"
#import "AWXAPIClient.h"
#import "AWXDefaultProvider+Security.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXSession.h"
#import "NSObject+Logging.h"
#import <AirwallexRisk/AirwallexRisk-Swift.h>
#ifdef AirwallexSDK
#import <Card/Card-Swift.h>
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@implementation AWXCardProvider

+ (BOOL)canHandleSession:(AWXSession *)session paymentMethod:(AWXPaymentMethodType *)paymentMethod {
    return paymentMethod.cardSchemes.count != 0;
}

- (void)handleFlow {
    AWXCardViewController *controller = [[AWXCardViewController alloc] initWithIsFlowFromPushing:self.isFlowFromPushing];
    NSMutableArray<AWXCardScheme *> *supportedCardSchemes;
    if (self.paymentMethodType) {
        supportedCardSchemes = [NSMutableArray arrayWithArray:self.paymentMethodType.cardSchemes];
    }
    if (self.cardSchemes) {
        supportedCardSchemes = [NSMutableArray array];
        for (AWXCardBrand type in self.cardSchemes) {
            [supportedCardSchemes addObject:[self getSchemeFrom:type]];
        }
    }
    controller.viewModel = [[AWXCardViewModel alloc] initWithSession:self.session supportedCardSchemes:supportedCardSchemes];
    controller.viewModel.provider = self;
    controller.viewModel.isShowCardFlowDirectly = self.showPaymentDirectly;
    [self.delegate provider:self shouldPresentViewController:controller forceToDismiss:NO withAnimation:YES];
}

- (AWXCardScheme *)getSchemeFrom:(AWXCardBrand)type {
    AWXCardScheme *scheme = [AWXCardScheme new];
    if ([AWXAllCardBrand() containsObject:type]) {
        scheme.name = type;
    } else {
        scheme.name = AWXCardBrandUnknown;
    }

    return scheme;
}

- (void)confirmPaymentIntentWithCard:(AWXCard *)card
                             billing:(AWXPlaceDetails *_Nullable)billing
                            saveCard:(BOOL)saveCard {
    [self log:@"Start payment confirm. Type: Card. Intent Id:%@", self.session.paymentIntentId];

    AWXPaymentMethod *paymentMethod = [[AWXPaymentMethod alloc] initWithType:AWXCardKey id:nil billing:billing card:card additionalParams:nil customerId:self.session.customerId];

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
    [self setDevice:^(AWXDevice *_Nonnull device) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf confirmPaymentIntentWithPaymentConsentId:paymentConsentId
                                                      device:device
                                                  completion:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
                                                      __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                      [strongSelf completeWithResponse:(AWXConfirmPaymentIntentResponse *)response error:error];
                                                  }];
    }];
}

#pragma mark - Internal Actions

- (void)confirmPaymentIntentWithPaymentConsentId:(NSString *)paymentConsentId
                                          device:(AWXDevice *)device
                                      completion:(AWXRequestHandler)completion {
    AWXConfirmPaymentIntentConfiguration *configuration = [AWXConfirmPaymentIntentConfiguration new];
    AWXPaymentConsent *consent = [[AWXPaymentConsent alloc] initWithId:paymentConsentId requestId:nil customerId:nil status:nil paymentMethod:nil nextTriggeredBy:nil merchantTriggerReason:nil createdAt:nil updatedAt:nil clientSecret:nil];
    configuration.intentId = self.session.paymentIntentId;
    configuration.customerId = self.session.customerId;
    configuration.paymentConsent = consent;
    configuration.device = device;
    configuration.returnURL = AWXThreeDSReturnURL;

    if ([self.session respondsToSelector:@selector(autoCapture)]) {
        // assume payment consent can only be card payment type, so set 3ds return url anyway
        AWXThreeDs *threeDs = [[AWXThreeDs alloc] initWithPaRes:nil returnURL:AWXThreeDSReturnURL attemptId:nil deviceDataCollectionRes:nil dsTransactionId:nil];
        AWXCardOptions *cardOptions = [[AWXCardOptions alloc] initWithAutoCapture:[[self.session valueForKey:@"autoCapture"] boolValue] threeDs:threeDs];

        AWXPaymentMethodOptions *options = [[AWXPaymentMethodOptions alloc] initWithCardOptions:cardOptions];
        configuration.options = options;
    }

    [AWXAPIClientSwift confirmPaymentIntentWithConfiguration:configuration completion:completion];
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

- (void)createPaymentMethod:(AWXPaymentMethod *)paymentMethod
                 completion:(AWXRequestHandler)completion {
    AWXCreatePaymentMethodRequest *request = [AWXCreatePaymentMethodRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.paymentMethod = paymentMethod;

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:completion];
}

- (void)pushPayment:(AWXPaymentConsent *)paymentConsent {
    AWXPaymentViewController *controller = [[AWXPaymentViewController alloc] initWithShownDirectly:YES isFlowFromPushing:YES];
    controller.delegate = [AWXUIContext sharedContext].delegate;
    controller.session = self.session;
    controller.paymentConsent = paymentConsent;
    [self.delegate provider:self shouldPresentViewController:controller forceToDismiss:NO withAnimation:YES];
}

- (void)setDevice:(void (^)(AWXDevice *_Nonnull))completion {
    [self setDeviceWithSessionId:[[AWXRisk sessionID] UUIDString] completion:completion];
}

@end
