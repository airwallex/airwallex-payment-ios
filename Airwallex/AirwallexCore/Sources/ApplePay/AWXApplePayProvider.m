//
//  AWXApplePayProvider.m
//  ApplePay
//
//  Created by Jin Wang on 23/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXApplePayProvider.h"
#import "AWXAnalyticsLogger.h"
#import "AWXConstants.h"
#import "AWXDevice.h"
#import "AWXPaymentIntent.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethod.h"
#import "AWXSession+Request.h"
#import "AWXSession.h"
#import "AWXUtils.h"
#import "NSObject+Logging.h"
#import "PKContact+Request.h"
#import "PKPaymentToken+Request.h"
#import <AirwallexRisk/AirwallexRisk-Swift.h>
#import <PassKit/PassKit.h>

@interface AWXApplePayProvider ()<PKPaymentAuthorizationControllerDelegate>

typedef enum {
    NotPresented,
    NotStarted,
    Pending,
    Complete
} PaymentState;

@property (nonatomic, strong, nullable) AWXConfirmPaymentIntentResponse *lastResponse;
@property (nonatomic, strong, nullable) NSError *lastError;
@property (nonatomic) BOOL isApplePayLaunchedDirectly;
@property (nonatomic) BOOL didDismissWhilePending;
@property (nonatomic) BOOL didHandlePresentationFail;
@property (nonatomic) PaymentState paymentState;

@end

@implementation AWXApplePayProvider

- (instancetype)initWithDelegate:(id<AWXProviderDelegate>)delegate session:(AWXSession *)session {
    AWXPaymentMethodType *paymentMethodType = [AWXPaymentMethodType new];
    paymentMethodType.name = AWXApplePayKey;
    return [self initWithDelegate:delegate session:session paymentMethodType:paymentMethodType];
}

- (instancetype)initWithDelegate:(id<AWXProviderDelegate>)delegate session:(AWXSession *)session paymentMethodType:(AWXPaymentMethodType *)paymentMethodType {
    if (paymentMethodType) {
        self = [super initWithDelegate:delegate session:session paymentMethodType:paymentMethodType];
    } else {
        self = [self initWithDelegate:delegate session:session];
    }
    return self;
}

#pragma mark - Launch Apple Pay flow
- (void)startPayment {
    NSString *errorMessage;
    if ([AWXApplePayProvider canHandleSession:self.session errorMessage:&errorMessage]) {
        _isApplePayLaunchedDirectly = true;
        [self handleFlow];
    } else {
        NSError *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: errorMessage ?: @""}];
        [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
        [self log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu  %@", self.delegate.class, AirwallexPaymentStatusFailure, error.localizedDescription];
    }
}

#pragma mark - AWXDefaultProvider parent methods

+ (BOOL)canHandleSession:(AWXSession *)session paymentMethod:(AWXPaymentMethodType *)paymentMethod {
    return [self canHandleSession:session errorMessage:nil];
}

- (void)handleFlow {
    self.paymentState = NotPresented;
    [self handleFlowForSession:self.session];
}

#pragma mark - PKPaymentAuthorizationControllerDelegate

- (void)paymentAuthorizationController:(PKPaymentAuthorizationController *)controller
                   didAuthorizePayment:(PKPayment *)payment
                               handler:(void (^)(PKPaymentAuthorizationResult *_Nonnull))completion {
    AWXPaymentMethod *method = [AWXPaymentMethod new];
    method.type = AWXApplePayKey;
    method.customerId = self.session.customerId;

    NSError *error;
    NSDictionary *billingPayload;

    if (payment.billingContact) {
        billingPayload = [payment.billingContact payloadForRequest];
    }

    NSDictionary *applePayParams = [payment.token payloadForRequestWithBilling:billingPayload orError:&error];

    if (!applePayParams) {
        self.lastError = error;

        NSArray *errors;
        if (error) {
            errors = @[error];
        }

        PKPaymentAuthorizationResult *result = [[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusFailure
                                                                                             errors:errors];
        completion(result);

        return;
    }

    [method appendAdditionalParams:applePayParams];

    self.paymentState = Pending;
    if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
        [self confirmWithPaymentMethod:method completion:completion];
    } else {
        [self createApplePaymentConsentAndConfirmIntentWithPaymentMethod:method completion:completion];
    }
}

- (void)paymentAuthorizationControllerDidFinish:(nonnull PKPaymentAuthorizationController *)controller {
    void (^dismissCompletionBlock)(void);
    switch (self.paymentState) {
    case NotPresented:
        [self handlePresentationFail];
        break;
    case NotStarted:
        if (self.isApplePayLaunchedDirectly) {
            dismissCompletionBlock = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusCancel error:nil];
                    [self log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu", self.delegate.class, AirwallexPaymentStatusCancel];
                });
            };
        }
        [self log:@"Apple pay hasn't started."];
        // The user most likely has cancelled the authorization.
        // Do nothing here to allow the user to select another payment method if it's not direct Apple Pay integration.
        [controller dismissWithCompletion:dismissCompletionBlock];
        break;
    case Pending:
        // If UI disappears during the interaction with our API, we pass the state to the upper level so in progress UI can be handled before we get the confirmed or failed intent
        [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusInProgress error:nil];
        [self log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu", self.delegate.class, AirwallexPaymentStatusInProgress];
        [self log:@"Apple pay is being processing."];
        self.didDismissWhilePending = YES;
        break;
    case Complete:
        dismissCompletionBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self log:@"Apple pay finished. LastResponse:%@, lastError:%@", self.lastResponse.status, self.lastError];
                [self completeWithResponse:self.lastResponse error:self.lastError];
            });
        };
        [controller dismissWithCompletion:dismissCompletionBlock];
        break;
    }
}

#pragma mark - Private methods

+ (BOOL)canHandleSession:(AWXSession *)session errorMessage:(NSString *_Nullable *)error {
    if (session.applePayOptions == nil) {
        if (error) {
            *error = @"Missing Apple Pay options in session.";
        }
        return NO;
    }
    BOOL canMakePayment = NO;

    if (@available(iOS 15.0, *)) {
        // From iOS 15.0 onwards, user can add new card directly in the apple pay flow
        canMakePayment = [PKPaymentAuthorizationController canMakePayments];
    } else {
        canMakePayment = [PKPaymentAuthorizationController canMakePaymentsUsingNetworks:AWXApplePaySupportedNetworks()
                                                                           capabilities:session.applePayOptions.merchantCapabilities];
    }

    if (error && !canMakePayment) {
        if (error) {
            *error = @"Payment not supported via Apple Pay.";
        }
    }

    if ([session isKindOfClass:[AWXRecurringSession class]]) {
        AWXRecurringSession *recurringSession = (AWXRecurringSession *)session;
        if ([recurringSession.transactionMode isEqual:AWXPaymentTransactionModeRecurring] && recurringSession.nextTriggerByType == AirwallexNextTriggerByCustomerType) {
            if (error) {
                *error = @"CIT not supported by Apple Pay";
            }
            return NO;
        }
    }
    if ([session isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *recurringSession = (AWXRecurringWithIntentSession *)session;
        if ([recurringSession.transactionMode isEqual:AWXPaymentTransactionModeRecurring] && recurringSession.nextTriggerByType == AirwallexNextTriggerByCustomerType) {
            if (error) {
                *error = @"CIT not supported by Apple Pay";
            }
            return NO;
        }
    }
    return canMakePayment;
}

- (void)handleFlowForSession:(AWXSession *)session {
    NSError *error;
    PKPaymentRequest *request = [session makePaymentRequestOrError:&error];

    if (!request) {
        [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
        [self log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu  %@", self.delegate.class, AirwallexPaymentStatusFailure, error.localizedDescription];
        return;
    }

    PKPaymentAuthorizationController *controller = [[PKPaymentAuthorizationController alloc] initWithPaymentRequest:request];

    if (!controller) {
        NSString *description = @"Failed to initialize Apple Pay Controller.";
        NSError *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: description}];
        [[AWXAnalyticsLogger shared] logError:error withEventName:@"apple_pay_sheet"];
        [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
        [self log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu  %@", self.delegate.class, AirwallexPaymentStatusFailure, error.localizedDescription];
        return;
    }

    controller.delegate = self;

    [AWXRisk logWithEvent:@"show_apple_pay" screen:@"page_apple_pay"];

    __weak __typeof(self) weakSelf = self;
    [controller presentWithCompletion:^(BOOL success) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!success) {
            [strongSelf handlePresentationFail];
            return;
        }

        strongSelf.paymentState = NotStarted;
        [[AWXAnalyticsLogger shared] logPageViewWithName:@"apple_pay_sheet"
                                          additionalInfo:@{
                                              @"supported_networks": session.applePayOptions.supportedNetworks ?: @[]
                                          }];
        [self log:@"Show apple pay"];
    }];
}

- (void)confirmWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                      completion:(void (^)(PKPaymentAuthorizationResult *_Nonnull))completion {
    __weak __typeof(self) weakSelf = self;
    [self confirmPaymentIntentWithPaymentMethod:paymentMethod
                                 paymentConsent:nil
                                     completion:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
                                         __strong __typeof(weakSelf) strongSelf = weakSelf;
                                         AWXConfirmPaymentIntentResponse *confirmResponse = (AWXConfirmPaymentIntentResponse *)response;
                                         [strongSelf completeWithResponse:confirmResponse error:error completion:completion];
                                     }];
}

- (void)createApplePaymentConsentAndConfirmIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                                                        completion:(void (^)(PKPaymentAuthorizationResult *_Nonnull))completion {
    __weak __typeof(self) weakSelf = self;
    [self createPaymentConsentAndConfirmIntentWithPaymentMethod:paymentMethod
                                                     completion:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
                                                         __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                         AWXConfirmPaymentIntentResponse *confirmResponse = (AWXConfirmPaymentIntentResponse *)response;
                                                         [strongSelf completeWithResponse:confirmResponse error:error completion:completion];
                                                     }];
}

- (void)completeWithResponse:(AWXConfirmPaymentIntentResponse *)response
                       error:(NSError *)error
                  completion:(void (^)(PKPaymentAuthorizationResult *_Nonnull))completion {
    self.lastResponse = response;
    self.lastError = error;
    self.paymentState = Complete;

    if (self.didDismissWhilePending) {
        [self completeWithResponse:response error:error];
    } else {
        PKPaymentAuthorizationStatus status;
        NSArray<NSError *> *errors;

        if (response && !error) {
            status = PKPaymentAuthorizationStatusSuccess;
        } else {
            status = PKPaymentAuthorizationStatusFailure;

            if (error) {
                errors = @[error];
            }
        }

        PKPaymentAuthorizationResult *result = [[PKPaymentAuthorizationResult alloc] initWithStatus:status errors:errors];
        completion(result);
    }
}

- (void)handlePresentationFail {
    if (!_didHandlePresentationFail) {
        self.didHandlePresentationFail = YES;
        NSError *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"Failed to present Apple Pay Controller."}];
        [[AWXAnalyticsLogger shared] logError:error withEventName:@"apple_pay_sheet"];
        [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
        [self log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu  %@", self.delegate.class, AirwallexPaymentStatusFailure, error.localizedDescription];
    }
}

@end
