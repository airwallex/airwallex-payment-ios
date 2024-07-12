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
#import "AWXDefaultProvider+Security.h"
#import "AWXOneOffSession+Request.h"
#import "AWXPaymentIntent.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethod.h"
#import "AWXSession.h"
#import "AirRisk/AirRisk-Swift.h"
#import "NSObject+logging.h"
#import "PKContact+Request.h"
#import "PKPaymentToken+Request.h"
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

#pragma mark - Launch Apple Pay flow
- (void)startPayment {
    NSString *errorMessage;
    if ([AWXApplePayProvider canHandleSession:self.session errorMessage:&errorMessage]) {
        _isApplePayLaunchedDirectly = true;
        [self handleFlow];
    } else {
        NSError *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
    }
}

#pragma mark - AWXDefaultProvider parent methods

+ (BOOL)canHandleSession:(AWXSession *)session paymentMethod:(AWXPaymentMethodType *)paymentMethod {
    return [self canHandleSession:session errorMessage:nil];
}

- (void)handleFlow {
    if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
        self.paymentState = NotPresented;
        [self handleFlowForOneOffSession:(AWXOneOffSession *)self.session];
    } else {
        NSError *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unsupported session type.", nil)}];
        [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
    }
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
    __weak __typeof(self) weakSelf = self;
    [self setDevice:^(AWXDevice *_Nonnull device) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf confirmWithPaymentMethod:method device:device completion:completion];
    }];
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
                });
            };
        }
        [self log:@"Apple pay failed."];
        // The user most likely has cancelled the authorization.
        // Do nothing here to allow the user to select another payment method if it's not direct Apple Pay integration.
        [controller dismissWithCompletion:dismissCompletionBlock];
        break;
    case Pending:
        // If UI disappears during the interaction with our API, we pass the state to the upper level so in progress UI can be handled before we get the confirmed or failed intent
        [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusInProgress error:nil];
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
    if ([session isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *oneOffSession = (AWXOneOffSession *)session;
        if (oneOffSession.applePayOptions == nil) {
            if (error) {
                *error = NSLocalizedString(@"Missing Apple Pay options in session.", nil);
            }
            return NO;
        }
        BOOL canMakePayment = NO;

        if (@available(iOS 15.0, *)) {
            // From iOS 15.0 onwards, user can add new card directly in the apple pay flow
            canMakePayment = [PKPaymentAuthorizationController canMakePayments];
        } else {
            canMakePayment = [PKPaymentAuthorizationController canMakePaymentsUsingNetworks:AWXApplePaySupportedNetworks()
                                                                               capabilities:oneOffSession.applePayOptions.merchantCapabilities];
        }

        if (error && !canMakePayment) {
            *error = NSLocalizedString(@"Payment not supported via Apple Pay.", nil);
        }
        return canMakePayment;
    } else {
        if (error) {
            *error = NSLocalizedString(@"Unsupported session type.", nil);
        }
        return NO;
    }
}

- (void)handleFlowForOneOffSession:(AWXOneOffSession *)session {
    NSError *error;
    PKPaymentRequest *request = [session makePaymentRequestOrError:&error];

    if (!request) {
        [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
        return;
    }

    PKPaymentAuthorizationController *controller = [[PKPaymentAuthorizationController alloc] initWithPaymentRequest:request];

    if (!controller) {
        NSString *description = NSLocalizedString(@"Failed to initialize Apple Pay Controller.", nil);
        NSError *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: description}];
        [[AWXAnalyticsLogger shared] logError:error withEventName:@"apple_pay_sheet"];
        [self log:@"%@", description];
        [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
        return;
    }

    controller.delegate = self;

    [AirwallexRisk logWithEvent:@"show_apple_pay" screen:@"page_apple_pay"];

    __weak __typeof(self) weakSelf = self;
    [controller presentWithCompletion:^(BOOL success) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!success) {
            [strongSelf handlePresentationFail];
            return;
        }

        strongSelf.paymentState = NotStarted;
        [[AWXAnalyticsLogger shared] logPageViewWithName:@"apple_pay_sheet"];
        [self log:@"Show apple pay"];
    }];
}

- (void)confirmWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
                          device:(AWXDevice *)device
                      completion:(void (^)(PKPaymentAuthorizationResult *_Nonnull))completion {
    __weak __typeof(self) weakSelf = self;
    [self confirmPaymentIntentWithPaymentMethod:paymentMethod
                                 paymentConsent:nil
                                         device:device
                                     completion:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
                                         __strong __typeof(weakSelf) strongSelf = weakSelf;
                                         AWXConfirmPaymentIntentResponse *confirmResponse = (AWXConfirmPaymentIntentResponse *)response;
                                         strongSelf.lastResponse = confirmResponse;
                                         strongSelf.lastError = error;
                                         strongSelf.paymentState = Complete;

                                         if (strongSelf.didDismissWhilePending) {
                                             [strongSelf completeWithResponse:confirmResponse error:error];
                                         } else {
                                             PKPaymentAuthorizationStatus status;
                                             NSArray<NSError *> *errors;

                                             if (confirmResponse && !error) {
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
                                     }];
}

- (void)handlePresentationFail {
    if (!_didHandlePresentationFail) {
        self.didHandlePresentationFail = YES;
        NSError *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to present Apple Pay Controller.", nil)}];
        [[AWXAnalyticsLogger shared] logError:error withEventName:@"apple_pay_sheet"];
        [self log:@"Failed to present Apple Pay Controller."];
        [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
    }
}

@end
