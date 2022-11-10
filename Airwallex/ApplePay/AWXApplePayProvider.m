//
//  AWXApplePayProvider.m
//  ApplePay
//
//  Created by Jin Wang on 23/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXApplePayProvider.h"
#import "AWXConstants.h"
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

@end

@implementation AWXApplePayProvider

+ (BOOL)canHandleSession:(AWXSession *)session paymentMethod:(AWXPaymentMethodType *)paymentMethod {
    if ([session isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *oneOffSession = (AWXOneOffSession *)session;
        if (oneOffSession.applePayOptions == nil) {
            return NO;
        }
        return [PKPaymentAuthorizationController canMakePaymentsUsingNetworks:AWXApplePaySupportedNetworks()
                                                                 capabilities:oneOffSession.applePayOptions.merchantCapabilities];
    } else {
        return NO;
    }
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
            [[strongSelf delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
        }
    }];
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
    [self confirmPaymentIntentWithPaymentMethod:method
                                 paymentConsent:nil
                                         device:nil
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

- (void)paymentAuthorizationControllerDidFinish:(nonnull PKPaymentAuthorizationController *)controller {
    __weak __typeof(self) weakSelf = self;
    [controller dismissWithCompletion:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.shouldInvokeCompleteWithResponse) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf completeWithResponse:strongSelf.lastResponse error:strongSelf.lastError];
            });
        } else {
            // The user most likely has cancelled the authorization.
            // Do nothing here to allow the user to select another payment method.
        }
    }];
}

@end
