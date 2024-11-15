//
//  AWXDefaultProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/22.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"
#import "AWXAnalyticsLogger.h"
#import "AWXDevice.h"
#import "AWXNextActionHandler.h"
#import "AWXPaymentConsent.h"
#import "AWXPaymentConsentRequest.h"
#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethodOptions.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXSession.h"
#import "NSObject+Logging.h"

@interface AWXDefaultProvider ()

@property (nonatomic, weak, readwrite) id<AWXProviderDelegate> delegate;
@property (nonatomic, strong, readwrite) AWXSession *session;
@property (nonatomic, strong, readwrite, nullable) AWXPaymentMethod *paymentMethod;
@property (nonatomic, strong) AWXPaymentConsent *paymentConsent;
@property (nonatomic, strong) NSString *paymentIntentId;
@property (nonatomic, strong) AWXNextActionHandler *nextActionHandler;

@end

@implementation AWXDefaultProvider

+ (BOOL)canHandleSession:(AWXSession *)session paymentMethod:(AWXPaymentMethodType *)paymentMethod {
    return YES;
}

- (instancetype)initWithDelegate:(id<AWXProviderDelegate>)delegate session:(AWXSession *)session {
    return [self initWithDelegate:delegate session:session paymentMethodType:nil];
}

- (instancetype)initWithDelegate:(id<AWXProviderDelegate>)delegate session:(AWXSession *)session paymentMethodType:(AWXPaymentMethodType *)paymentMethodType {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _session = session;
        if (paymentMethodType) {
            _paymentMethodType = paymentMethodType;
            AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
            paymentMethod.type = paymentMethodType.name;
            _paymentMethod = paymentMethod;
        }
    }
    return self;
}

- (void)handleFlow {
    [self confirmPaymentIntentWithPaymentMethod:_paymentMethod paymentConsent:nil device:nil];
}

- (void)createPaymentConsentAndConfirmIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                                                       device:(nullable AWXDevice *)device {
    [self.delegate providerDidStartRequest:self];
    [self log:@"Delegate: %@, providerDidStartRequest:", self.delegate.class];

    __weak __typeof(self) weakSelf = self;
    [self createPaymentConsentAndConfirmIntentWithPaymentMethod:[self paymentMethodWithMetaData:paymentMethod flow:AWXPaymentMethodFlowApp]
                                                         device:device
                                                     completion:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
                                                         __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                         [strongSelf completeWithResponse:(AWXConfirmPaymentIntentResponse *)response error:error];
                                                     }];
}

- (void)createPaymentConsentAndConfirmIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                                                       device:(nullable AWXDevice *)device
                                                   completion:(AWXRequestHandler)completion {
    if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
        __weak __typeof(self) weakSelf = self;
        [self log:@"One off payment flow."];
        [self createPaymentConsentWithPaymentMethod:paymentMethod
                                         customerId:self.session.customerId
                                           currency:self.session.currency
                                  nextTriggerByType:AirwallexNextTriggerByCustomerType
                                        requiresCVC:true
                              merchantTriggerReason:AirwallexMerchantTriggerReasonUndefined
                                         completion:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
                                             __strong __typeof(weakSelf) strongSelf = weakSelf;
                                             NSString *returnURL;
                                             if (strongSelf.paymentConsent && [paymentMethod.type isEqualToString:AWXCardKey]) {
                                                 returnURL = AWXThreeDSReturnURL;
                                             }
                                             AWXOneOffSession *session = (AWXOneOffSession *)strongSelf.session;
                                             [strongSelf confirmPaymentIntentWithId:session.paymentIntent.Id
                                                                         customerId:session.paymentIntent.customerId
                                                                      paymentMethod:paymentMethod
                                                                     paymentConsent:strongSelf.paymentConsent
                                                                             device:device
                                                                          returnURL:returnURL
                                                                        autoCapture:session.autoCapture
                                                                         completion:completion];
                                         }];
    } else if ([self.session isKindOfClass:[AWXRecurringSession class]]) {
        [self log:@"Recurring payment flow."];
        AWXRecurringSession *session = (AWXRecurringSession *)self.session;
        __weak __typeof(self) weakSelf = self;
        [self createPaymentConsentWithPaymentMethod:paymentMethod
                                         customerId:session.customerId
                                           currency:session.currency
                                  nextTriggerByType:session.nextTriggerByType
                                        requiresCVC:session.requiresCVC
                              merchantTriggerReason:session.merchantTriggerReason
                                         completion:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
                                             __strong __typeof(weakSelf) strongSelf = weakSelf;
                                             if (response && !error) {
                                                 NSString *returnURL = session.returnURL;
                                                 if (strongSelf.paymentConsent && [paymentMethod.type isEqualToString:AWXCardKey]) {
                                                     returnURL = AWXThreeDSReturnURL;
                                                 }
                                                 AWXRecurringSession *session = (AWXRecurringSession *)strongSelf.session;
                                                 [strongSelf verifyPaymentConsentWithPaymentMethod:paymentMethod
                                                                                    paymentConsent:strongSelf.paymentConsent
                                                                                          currency:session.currency
                                                                                            amount:session.amount
                                                                                         returnURL:returnURL
                                                                                        completion:completion];
                                             } else {
                                                 completion(nil, error);
                                             }
                                         }];
    } else if ([self.session isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        [self log:@"Recurring with Intent payment flow."];
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self.session;
        __weak __typeof(self) weakSelf = self;
        [self createPaymentConsentWithPaymentMethod:paymentMethod
                                         customerId:session.paymentIntent.customerId
                                           currency:session.paymentIntent.currency
                                  nextTriggerByType:session.nextTriggerByType
                                        requiresCVC:session.requiresCVC
                              merchantTriggerReason:session.merchantTriggerReason
                                         completion:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
                                             __strong __typeof(weakSelf) strongSelf = weakSelf;
                                             AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self.session;
                                             if ([paymentMethod.type isEqualToString:AWXCardKey] || [paymentMethod.type isEqualToString:AWXApplePayKey]) {
                                                 [strongSelf confirmPaymentIntentWithId:session.paymentIntent.Id
                                                                             customerId:session.paymentIntent.customerId
                                                                          paymentMethod:paymentMethod
                                                                         paymentConsent:strongSelf.paymentConsent
                                                                                 device:device
                                                                              returnURL:AWXThreeDSReturnURL
                                                                            autoCapture:session.autoCapture
                                                                             completion:completion];
                                             } else {
                                                 NSString *returnURL = session.returnURL;
                                                 if (strongSelf.paymentConsent && [paymentMethod.type isEqualToString:AWXCardKey]) {
                                                     returnURL = AWXThreeDSReturnURL;
                                                 }
                                                 [strongSelf verifyPaymentConsentWithPaymentMethod:paymentMethod
                                                                                    paymentConsent:strongSelf.paymentConsent
                                                                                          currency:session.paymentIntent.currency
                                                                                            amount:session.paymentIntent.amount
                                                                                         returnURL:returnURL
                                                                                        completion:completion];
                                             }
                                         }];
    }
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                               paymentConsent:(nullable AWXPaymentConsent *)paymentConsent
                                       device:(nullable AWXDevice *)device {
    [self confirmPaymentIntentWithPaymentMethod:paymentMethod paymentConsent:paymentConsent device:device flow:AWXPaymentMethodFlowApp];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                               paymentConsent:(nullable AWXPaymentConsent *)paymentConsent
                                       device:(nullable AWXDevice *)device
                                         flow:(AWXPaymentMethodFlow)flow {
    __weak __typeof(self) weakSelf = self;
    [self confirmPaymentIntentWithPaymentMethodInternal:paymentMethod
                                         paymentConsent:paymentConsent
                                                 device:device
                                                   flow:flow
                                             completion:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
                                                 __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                 [strongSelf completeWithResponse:(AWXConfirmPaymentIntentResponse *)response error:error];
                                             }];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                               paymentConsent:(nullable AWXPaymentConsent *)paymentConsent
                                       device:(nullable AWXDevice *)device
                                   completion:(AWXRequestHandler)completion {
    [self confirmPaymentIntentWithPaymentMethodInternal:paymentMethod
                                         paymentConsent:paymentConsent
                                                 device:device
                                                   flow:AWXPaymentMethodFlowApp
                                             completion:completion];
}

- (void)completeWithResponse:(nullable AWXConfirmPaymentIntentResponse *)response
                       error:(nullable NSError *)error {
    [self.delegate providerDidEndRequest:self];
    [self log:@"Delegate: %@, providerDidEndRequest:", self.delegate.class];

    if (response && !error) {
        if (response.nextAction) {
            if ([self.delegate respondsToSelector:@selector(provider:shouldHandleNextAction:)]) {
                [self.delegate provider:self shouldHandleNextAction:response.nextAction];
                [self log:@"Delegate: %@, provider:shouldHandleNextAction:  type:%@, stage: %@", self.delegate.class, response.nextAction.type, response.nextAction.stage];
            } else {
                AWXNextActionHandler *handler = [[AWXNextActionHandler alloc] initWithDelegate:self.delegate session:self.session];
                [handler handleNextAction:response.nextAction];
                self.nextActionHandler = handler;
            }
        } else {
            if (self.paymentConsent.Id && [self.delegate respondsToSelector:@selector(provider:didCompleteWithPaymentConsentId:)]) {
                [self log:@"Delegate: %@, provider:didCompleteWithPaymentConsentId: ID length: %lu", self.delegate.class, self.paymentConsent.Id.length];
                [self.delegate provider:self didCompleteWithPaymentConsentId:self.paymentConsent.Id];
            }
            [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusSuccess error:nil];
            [self log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu", self.delegate.class, AirwallexPaymentStatusSuccess];

            if (_paymentMethod.type.length > 0) {
                [[AWXAnalyticsLogger shared] logActionWithName:@"payment_success" additionalInfo:@{@"paymentMethod": _paymentMethod.type}];
            } else {
                [[AWXAnalyticsLogger shared] logActionWithName:@"payment_success"];
            }
        }
    } else {
        [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
        [self log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu  %@", self.delegate.class, AirwallexPaymentStatusFailure, error.localizedDescription];
    }
}

#pragma mark - Internal Actions

- (void)confirmPaymentIntentWithPaymentMethodInternal:(AWXPaymentMethod *)paymentMethod
                                       paymentConsent:(nullable AWXPaymentConsent *)paymentConsent
                                               device:(nullable AWXDevice *)device
                                                 flow:(AWXPaymentMethodFlow)flow
                                           completion:(AWXRequestHandler)completion {
    self.paymentConsent = paymentConsent;

    [self.delegate providerDidStartRequest:self];
    [self log:@"Delegate: %@, providerDidStartRequest:", self.delegate.class];

    [self confirmPaymentIntentWithPaymentMethodInternal:[self paymentMethodWithMetaData:paymentMethod flow:flow]
                                         paymentConsent:paymentConsent
                                                 device:device
                                             completion:completion];
}

- (void)confirmPaymentIntentWithPaymentMethodInternal:(AWXPaymentMethod *)paymentMethod
                                       paymentConsent:(AWXPaymentConsent *)paymentConsent
                                               device:(AWXDevice *)device
                                           completion:(AWXRequestHandler)completion {
    if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
        NSString *returnURL = nil;
        if (paymentConsent && [paymentMethod.type isEqualToString:AWXCardKey]) {
            returnURL = AWXThreeDSReturnURL;
        }
        AWXOneOffSession *session = (AWXOneOffSession *)self.session;
        [self confirmPaymentIntentWithId:session.paymentIntent.Id
                              customerId:session.paymentIntent.customerId
                           paymentMethod:paymentMethod
                          paymentConsent:paymentConsent
                                  device:device
                               returnURL:returnURL
                             autoCapture:session.autoCapture
                              completion:completion];
    } else {
        [self createPaymentConsentAndConfirmIntentWithPaymentMethod:paymentMethod device:device completion:completion];
    }
}

- (void)confirmPaymentIntentWithId:(NSString *)paymentIntentId
                        customerId:(nullable NSString *)customerId
                     paymentMethod:(AWXPaymentMethod *)paymentMethod
                    paymentConsent:(nullable AWXPaymentConsent *)paymentConsent
                            device:(AWXDevice *)device
                         returnURL:(NSString *)returnURL
                       autoCapture:(BOOL)autoCapture
                        completion:(AWXRequestHandler)completion {
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.intentId = paymentIntentId;
    request.customerId = customerId;
    request.paymentMethod = paymentMethod;
    request.paymentConsent = paymentConsent;
    request.device = device;
    request.returnURL = returnURL;

    if ([@[AWXCardKey, AWXApplePayKey] containsObject:paymentMethod.type]) {
        AWXCardOptions *cardOptions = [AWXCardOptions new];
        cardOptions.autoCapture = autoCapture;
        if ([paymentMethod.type isEqualToString:AWXCardKey]) {
            AWXThreeDs *threeDs = [AWXThreeDs new];
            threeDs.returnURL = AWXThreeDSReturnURL;
            cardOptions.threeDs = threeDs;
        }

        AWXPaymentMethodOptions *options = [AWXPaymentMethodOptions new];
        options.cardOptions = cardOptions;
        request.options = options;
    }

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:completion];
}

- (void)createPaymentConsentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                                   customerId:(nullable NSString *)customerId
                                     currency:(NSString *)currency
                            nextTriggerByType:(AirwallexNextTriggerByType)nextTriggerByType
                                  requiresCVC:(BOOL)requiresCVC
                        merchantTriggerReason:(AirwallexMerchantTriggerReason)merchantTriggerReason
                                   completion:(AWXRequestHandler)completion {
    AWXCreatePaymentConsentRequest *request = [AWXCreatePaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.paymentMethod = paymentMethod;
    request.customerId = customerId;
    request.currency = currency;
    request.nextTriggerByType = nextTriggerByType;
    request.requiresCVC = requiresCVC;
    request.merchantTriggerReason = merchantTriggerReason;

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    __weak __typeof(self) weakSelf = self;
    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             __strong __typeof(weakSelf) strongSelf = weakSelf;
             if (response && !error) {
                 AWXCreatePaymentConsentResponse *result = (AWXCreatePaymentConsentResponse *)response;
                 strongSelf.paymentConsent = result.consent;
                 completion(response, error);
             } else {
                 completion(nil, error);
             }
         }];
}

- (void)verifyPaymentConsentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                               paymentConsent:(AWXPaymentConsent *)paymentConsent
                                     currency:(NSString *)currency
                                       amount:(NSDecimalNumber *)amount
                                    returnURL:(NSString *)returnURL
                                   completion:(AWXRequestHandler)completion {
    AWXVerifyPaymentConsentRequest *request = [AWXVerifyPaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.options = paymentMethod;
    request.consent = paymentConsent;
    request.currency = currency;
    request.amount = amount;
    request.returnURL = returnURL;

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    __weak __typeof(self) weakSelf = self;
    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             __strong __typeof(weakSelf) strongSelf = weakSelf;
             if (response && !error) {
                 AWXVerifyPaymentConsentResponse *result = (AWXVerifyPaymentConsentResponse *)response;
                 strongSelf.paymentIntentId = result.initialPaymentIntentId;
                 [strongSelf.delegate provider:strongSelf didInitializePaymentIntentId:result.initialPaymentIntentId];
                 [strongSelf log:@"Delegate: %@, provider:didInitializePaymentIntentId: %@", self.delegate.class, result.initialPaymentIntentId];

                 completion(response, error);
             } else {
                 completion(nil, error);
             }
         }];
}

- (AWXPaymentMethod *)paymentMethodWithMetaData:(AWXPaymentMethod *)paymentMethod flow:(AWXPaymentMethodFlow)flow {
    if (![paymentMethod.type isEqualToString:AWXCardKey]) {
        NSDictionary *metaData = @{@"flow": flow, @"os_type": @"ios"};
        if (paymentMethod.additionalParams) {
            NSMutableDictionary *params = paymentMethod.additionalParams.mutableCopy;
            [params addEntriesFromDictionary:metaData];
            paymentMethod.additionalParams = params;
        } else {
            paymentMethod.additionalParams = metaData;
        }
    }
    return paymentMethod;
}

@end
