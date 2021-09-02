//
//  AWXDefaultProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/22.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"
#import "AWXSession.h"
#import "AWXAPIClient.h"
#import "AWXSecurityService.h"
#import "AWXDevice.h"
#import "AWXPaymentMethodOptions.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentConsentRequest.h"
#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethodResponse.h"

@interface AWXDefaultProvider ()

@property (nonatomic, weak, readwrite) id <AWXProviderDelegate> delegate;
@property (nonatomic, strong, readwrite) AWXSession *session;
@property (nonatomic, strong, readwrite, nullable) AWXDevice *device;
@property (nonatomic, strong, readwrite, nullable) AWXPaymentMethod *paymentMethod;
@property (nonatomic, strong) AWXPaymentConsent *paymentConsent;
@property (nonatomic, strong) NSString *paymentIntentId;

@end

@implementation AWXDefaultProvider

- (instancetype)initWithDelegate:(id <AWXProviderDelegate>)delegate session:(AWXSession *)session
{
    return [self initWithDelegate:delegate session:session paymentMethod:nil];
}

- (instancetype)initWithDelegate:(id <AWXProviderDelegate>)delegate session:(AWXSession *)session paymentMethod:(nullable AWXPaymentMethod *)paymentMethod
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _session = session;
        _paymentMethod = paymentMethod;
    }
    return self;
}

- (void)handleFlow
{
    [self confirmPaymentIntentWithPaymentMethod:_paymentMethod paymentConsent:nil];
}

- (void)confirmPaymentIntentWithCard:(AWXCard *)card
                             billing:(AWXPlaceDetails *)billing
{
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = AWXCardKey;
    paymentMethod.billing = billing;
    paymentMethod.card = card;
    paymentMethod.customerId = self.session.customerId;
    
    [self.delegate providerDidStartRequest:self];
    if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
        [self confirmPaymentIntentWithPaymentMethod:paymentMethod paymentConsent:nil];
    } else {
        __weak __typeof(self)weakSelf = self;
        [self createPaymentMethod:paymentMethod completion:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (response && !error) {
                AWXCreatePaymentMethodResponse *result = (AWXCreatePaymentMethodResponse *)response;
                AWXPaymentMethod *paymentMethod = result.paymentMethod;
                paymentMethod.card.cvc = card.cvc;
                [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod paymentConsent:nil];
            } else {
                [strongSelf.delegate provider:strongSelf didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
            }
        }];
    }
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                               paymentConsent:(nullable AWXPaymentConsent *)paymentConsent
{
    self.paymentConsent = paymentConsent;
    
    if (![paymentMethod.type isEqualToString:AWXCardKey]) {
        NSDictionary *metaData = @{@"flow": @"inapp", @"os_type": @"ios"};
        if (paymentMethod.additionalParams) {
            NSMutableDictionary *params = paymentMethod.additionalParams.mutableCopy;
            [params addEntriesFromDictionary:metaData];
            paymentMethod.additionalParams = params;
        } else {
            paymentMethod.additionalParams = metaData;
        }
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.delegate providerDidStartRequest:self];
    
    if (self.device) {
        [self confirmPaymentIntentWithPaymentMethod:paymentMethod
                                     paymentConsent:paymentConsent
                                             device:self.device
                                         completion:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf completeWithResponse:response error:error];
        }];
    } else {
        [[AWXSecurityService sharedService] doProfile:self.session.paymentIntentId completion:^(NSString * _Nullable sessionId) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            AWXDevice *device = [AWXDevice new];
            device.deviceId = sessionId;
            strongSelf.device = device;
            
            [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod
                                               paymentConsent:paymentConsent
                                                       device:device
                                                   completion:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
                [strongSelf completeWithResponse:response error:error];
            }];
        }];
    }
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                               paymentConsent:(AWXPaymentConsent *)paymentConsent
                                       device:(AWXDevice *)device
                                   completion:(AWXRequestHandler)completion
{
    if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self.session;
        [self confirmPaymentIntentWithId:session.paymentIntent.Id
                              customerId:session.paymentIntent.customerId
                           paymentMethod:paymentMethod
                          paymentConsent:paymentConsent
                                  device:device
                              completion:completion];
    } else if ([self.session isKindOfClass:[AWXRecurringSession class]]) {
        AWXRecurringSession *session = (AWXRecurringSession *)self.session;
        __weak __typeof(self)weakSelf = self;
        [self createPaymentConsentWithPaymentMethod:paymentMethod
                                         customerId:session.customerId
                                           currency:session.currency
                                  nextTriggerByType:session.nextTriggerByType
                                        requiresCVC:session.requiresCVC
                              merchantTriggerReason:session.merchantTriggerReason
                                         completion:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (response && !error) {
                [strongSelf verifyPaymentConsentWithPaymentMethod:paymentMethod
                                                   paymentConsent:strongSelf.paymentConsent
                                                         currency:session.currency
                                                           amount:session.amount
                                                        returnURL:session.returnURL
                                                       completion:completion];
            } else {
                completion(nil, error);
            }
        }];
    } else if ([self.session isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self.session;
        __weak __typeof(self)weakSelf = self;
        [self createPaymentConsentWithPaymentMethod:paymentMethod
                                         customerId:session.paymentIntent.customerId
                                           currency:session.paymentIntent.currency
                                  nextTriggerByType:session.nextTriggerByType
                                        requiresCVC:session.requiresCVC
                              merchantTriggerReason:session.merchantTriggerReason
                                         completion:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([paymentMethod.type isEqualToString:AWXCardKey]) {
                [strongSelf confirmPaymentIntentWithId:session.paymentIntent.Id
                                            customerId:session.paymentIntent.customerId
                                         paymentMethod:paymentMethod
                                        paymentConsent:strongSelf.paymentConsent
                                                device:device
                                            completion:completion];
            } else {
                [strongSelf verifyPaymentConsentWithPaymentMethod:paymentMethod
                                                   paymentConsent:strongSelf.paymentConsent
                                                         currency:session.paymentIntent.currency
                                                           amount:session.paymentIntent.amount
                                                        returnURL:session.returnURL
                                                       completion:completion];
            }
        }];
    }
}

- (void)completeWithResponse:(nullable AWXConfirmPaymentIntentResponse *)response
                       error:(nullable NSError *)error
{
    [self.delegate providerDidEndRequest:self];
    if (response && response.nextAction) {
        [self.delegate provider:self shouldHandleNextAction:response.nextAction];
    } else {
        [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
    }
}

#pragma mark - Internal Actions

- (void)createPaymentMethod:(AWXPaymentMethod *)paymentMethod
                 completion:(AWXRequestHandler)completion
{
    AWXCreatePaymentMethodRequest *request = [AWXCreatePaymentMethodRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.paymentMethod = paymentMethod;
    
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:completion];
}

- (void)confirmPaymentIntentWithId:(NSString *)paymentIntentId
                        customerId:(nullable NSString *)customerId
                     paymentMethod:(AWXPaymentMethod *)paymentMethod
                    paymentConsent:(nullable AWXPaymentConsent *)paymentConsent
                            device:(AWXDevice *)device
                        completion:(AWXRequestHandler)completion
{
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.intentId = paymentIntentId;
    request.customerId = customerId;
    request.paymentMethod = paymentMethod;
    request.paymentConsent = paymentConsent;
    request.device = device;
    
    if ([paymentMethod.type isEqualToString:AWXCardKey]) {
        AWXCardOptions *cardOptions = [AWXCardOptions new];
        cardOptions.autoCapture = YES;
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

- (void)createPaymentConsentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                                   customerId:(nullable NSString *)customerId
                                     currency:(NSString *)currency
                            nextTriggerByType:(AirwallexNextTriggerByType)nextTriggerByType
                                  requiresCVC:(BOOL)requiresCVC
                        merchantTriggerReason:(AirwallexMerchantTriggerReason)merchantTriggerReason
                                   completion:(AWXRequestHandler)completion
{
    AWXCreatePaymentConsentRequest *request = [AWXCreatePaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.paymentMethod = paymentMethod;
    request.customerId = customerId;
    request.currency = currency;
    request.nextTriggerByType = nextTriggerByType;
    request.requiresCVC = requiresCVC;
    request.merchantTriggerReason = merchantTriggerReason;
    
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (response && !error) {
            AWXCreatePaymentConsentResponse *result = response;
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
                                   completion:(AWXRequestHandler)completion
{
    AWXVerifyPaymentConsentRequest *request = [AWXVerifyPaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.options = paymentMethod;
    request.consent = paymentConsent;
    request.currency = currency;
    request.amount = amount;
    request.returnURL = returnURL;
    
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (response && !error) {
            AWXVerifyPaymentConsentResponse *result = (AWXVerifyPaymentConsentResponse *)response;
            strongSelf.paymentIntentId = result.initialPaymentIntentId;
            [strongSelf.delegate provider:strongSelf didInitializePaymentIntentId:result.initialPaymentIntentId];
            completion(response, error);
        } else {
            completion(nil, error);
        }
    }];
}

@end
