//
//  AWXViewModel.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/11.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXViewModel.h"
#import "Airwallex.h"
#import "AWXSession.h"
#import "AWXAPIClient.h"
#import "AWXSecurityService.h"
#import "AWXThreeDSService.h"
#import "AWXDevice.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentConsentRequest.h"

@interface AWXViewModel () <AWXThreeDSServiceDelegate>

@property (nonatomic, copy, readwrite) AWXSession *session;
@property (nonatomic, strong) AWXThreeDSService *threeDSService;
@property (nonatomic, strong) AWXDevice *device;
@property (nonatomic, strong) AWXPaymentConsent *paymentConsent;
@property (nonatomic, strong) NSString *paymentIntentId;

@end

@implementation AWXViewModel

- (instancetype)initWithSession:(AWXSession *)session
                       delegate:(id <AWXViewModelDelegate>)delegate
{
    self = [super init];
    if (self) {
        _session = session;
        _delegate = delegate;
        _threeDSService =  [AWXThreeDSService new];
    }
    return self;
}

- (void)confirmPaymentIntentWithCard:(AWXCard *)card
                             billing:(AWXPlaceDetails *)billing
{
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = AWXCardKey;
    paymentMethod.billing = billing;
    paymentMethod.card = card;
    paymentMethod.customerId = self.session.customerId;
    
    [self.delegate viewModelDidStartRequest:self];
    if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
        [self confirmPaymentIntentWithPaymentMethod:paymentMethod paymentConsent:nil];
    } else {
        __weak __typeof(self)weakSelf = self;
        [self createPaymentMethod:paymentMethod completion:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.delegate viewModelDidEndRequest:self];
            if (response && !error) {
                AWXCreatePaymentMethodResponse *result = (AWXCreatePaymentMethodResponse *)response;
                [strongSelf.delegate viewModel:self didCreatePaymentMethod:result.paymentMethod error:error];
            } else {
                [strongSelf.delegate viewModel:self didCreatePaymentMethod:nil error:error];
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
    [self.delegate viewModelDidStartRequest:self];
    
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

- (void)completeWithResponse:(AWXConfirmPaymentIntentResponse *)response
                       error:(nullable NSError *)error
{
    [self.delegate viewModelDidEndRequest:self];
    if (response.nextAction) {
        [self.delegate viewModel:self shouldHandleNextAction:response.nextAction];
    } else {
        [self.delegate viewModel:self didCompleteWithError:error];
    }
}

- (void)handleThreeDSWithJwt:(NSString *)jwt
    presentingViewController:(UIViewController *)presentingViewController
{
    [self.delegate viewModelDidStartRequest:self];
    self.threeDSService.customerId = self.session.customerId;
    self.threeDSService.intentId = self.session.paymentIntentId ?: self.paymentIntentId;
    self.threeDSService.device = self.device;
    self.threeDSService.presentingViewController = presentingViewController;
    self.threeDSService.delegate = self;
    [self.threeDSService presentThreeDSFlowWithServerJwt:jwt];
}

- (void)confirmThreeDSWithUseDCC:(BOOL)useDCC
{
    [self.delegate viewModelDidStartRequest:self];
    AWXConfirmThreeDSRequest *request = [AWXConfirmThreeDSRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.intentId = self.session.paymentIntentId ?: self.paymentIntentId;
    request.type = AWXDCC;
    request.useDCC = useDCC;
    request.device = self.device;
    
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf completeWithResponse:response error:error];
    }];
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
                                   completion:(AWXRequestHandler)completion
{
    AWXCreatePaymentConsentRequest *request = [AWXCreatePaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.paymentMethod = paymentMethod;
    request.customerId = customerId;
    request.currency = currency;
    request.nextTriggerByType = nextTriggerByType;
    
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (response && !error) {
            AWXCreatePaymentConsentResponse *result = response;
            strongSelf.paymentConsent = result.consent;
            [strongSelf.delegate viewModel:strongSelf didCreatePaymentConsent:result.consent];
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
            [strongSelf.delegate viewModel:strongSelf didInitializePaymentIntentId:result.initialPaymentIntentId];
            completion(response, error);
        } else {
            completion(nil, error);
        }
    }];
}

#pragma mark - AWXThreeDSServiceDelegate

- (void)threeDSService:(AWXThreeDSService *)service didFinishWithResponse:(AWXConfirmPaymentIntentResponse *)response error:(NSError *)error
{
    [self completeWithResponse:response error:error];
}

@end
