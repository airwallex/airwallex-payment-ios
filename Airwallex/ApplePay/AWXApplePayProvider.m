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
#import "PKContact+Request.h"
#import "PKPaymentToken+Request.h"
#import <PassKit/PassKit.h>

@interface AWXApplePayProvider ()<PKPaymentAuthorizationControllerDelegate>

@property (nonatomic, strong, nullable) AWXConfirmPaymentIntentResponse *lastResponse;
@property (nonatomic, strong, nullable) NSError *lastError;
@property (nonatomic) BOOL shouldInvokeCompleteWithResponse;
@property (nonatomic) BOOL isApplePayLaunchedDirectly;

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
    self.shouldInvokeCompleteWithResponse = YES;

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

    __weak __typeof(self) weakSelf = self;
    [self setDevice:^(AWXDevice *_Nonnull device) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf confirmWithPaymentMethod:method device:device completion:completion];
    }];
}

- (void)paymentAuthorizationControllerDidFinish:(nonnull PKPaymentAuthorizationController *)controller {
    __weak __typeof(self) weakSelf = self;
    [controller dismissWithCompletion:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.shouldInvokeCompleteWithResponse) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf completeWithResponse:strongSelf.lastResponse error:strongSelf.lastError];
            });
        } else {
            if (strongSelf.isApplePayLaunchedDirectly) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusCancel error:nil];
                });
            } else {
                // The user most likely has cancelled the authorization.
                // Do nothing here to allow the user to select another payment method.
            }
        }
    }];
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
        BOOL canMakePayment = false;

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
        NSString *description = NSLocalizedString(@"Failed to initialize PKPaymentAuthorizationController.", nil);
        NSError *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: description}];
        [[AWXAnalyticsLogger shared] logError:error withEventName:@"apple_pay_sheet"];
        [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
        return;
    }

    controller.delegate = self;

    __weak __typeof(self) weakSelf = self;
    [controller presentWithCompletion:^(BOOL success) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        if (!success) {
            NSError *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to present PKPaymentAuthorizationController.", nil)}];
            [[AWXAnalyticsLogger shared] logError:error withEventName:@"apple_pay_sheet"];
            [[strongSelf delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
            return;
        }

        [[AWXAnalyticsLogger shared] logPageViewWithName:@"apple_pay_sheet"];
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
                                         AWXConfirmPaymentIntentResponse *confirmResponse = (AWXConfirmPaymentIntentResponse *)response;

                                         __strong __typeof(weakSelf) strongSelf = weakSelf;
                                         strongSelf.lastResponse = confirmResponse;
                                         strongSelf.lastError = error;

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
                                     }];
}

@end
