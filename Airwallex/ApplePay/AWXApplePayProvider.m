//
//  AWXApplePayProvider.m
//  ApplePay
//
//  Created by Jin Wang on 23/2/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXApplePayProvider.h"
#import "AWXSession.h"
#import "AWXPaymentIntent.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentMethod.h"
#import "AWXConstants.h"
#import "AWXPaymentIntentResponse.h"

@implementation AWXApplePayProvider

+ (BOOL)canHandleSession:(AWXSession *)session
{
    if ([session isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *oneOffSession = (AWXOneOffSession *)session;
        if (oneOffSession.applePayOptions == nil) {
            return NO;
        }
        return [PKPaymentAuthorizationController canMakePaymentsUsingNetworks:AWXApplePaySupportedNetworks() capabilities:oneOffSession.applePayOptions.merchantCapabilities];
    } else {
        return NO;
    }
    
}

- (void)handleFlow
{
    if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
        [self handleFlowForOneOffSession:(AWXOneOffSession *)self.session];
    } else {
        NSError *error = [NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unsupported session type.", nil)}];
        [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
    }
}

- (void)handleFlowForOneOffSession:(AWXOneOffSession *)session
{
    AWXApplePayOptions *options = self.session.applePayOptions;
    if (!options) {
        NSError *error = [NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Apple Pay options missing.", nil)}];
        [[self delegate] provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
        return;
    }
    
    PKPaymentRequest *request = [PKPaymentRequest new];
    request.paymentSummaryItems = [self paymenetSummaryItemsForIntent:session.paymentIntent];
    request.merchantIdentifier = options.merchantIdentifier;
    request.merchantCapabilities = options.merchantCapabilities;
    request.countryCode = session.countryCode;
    request.currencyCode = session.currency;
    request.supportedNetworks = AWXApplePaySupportedNetworks();
    request.shippingContact = options.shippingContact;
    request.shippingType = options.shippingType;
    request.shippingMethods = options.shippingMethods;
    request.billingContact = options.billingContact;
    request.requiredBillingContactFields = options.requiredBillingContactFields;
    request.supportedCountries = options.supportedCountries;
    
    PKPaymentAuthorizationController *controller = [[PKPaymentAuthorizationController alloc] initWithPaymentRequest:request];
    controller.delegate = self;
    [controller presentWithCompletion:^(BOOL success) {
        if (success) {
            NSLog(@"PKPaymentAuthorizationController present succesfully!");
        } else {
            NSError *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to present PKPaymentAuthorizationController.", nil)}];
            [self completeWithResponse:nil error: error];
        }
    }];
}

- (NSArray <PKPaymentSummaryItem *> *)paymenetSummaryItemsForIntent:(AWXPaymentIntent *)intent
{
    PKPaymentSummaryItem *item = [PKPaymentSummaryItem new];
    item.type = PKPaymentSummaryItemTypeFinal;
    item.amount = intent.amount;
    if (self.session.applePayOptions.totalPriceLabel) {
        item.label = self.session.applePayOptions.totalPriceLabel;
    } else {
        item.label = @"";
    }
    
    return @[item];
}

#pragma mark - PKPaymentAuthorizationControllerDelegate

- (void)paymentAuthorizationController:(PKPaymentAuthorizationController *)controller
       didRequestMerchantSessionUpdate:(void (^)(PKPaymentRequestMerchantSessionUpdate * _Nonnull))handler
API_AVAILABLE(ios(14.0))
{
    NSLog(@"didRequestMerchantSessionUpdate");
    
    [NSException raise:@"Unimplemented" format:@"didRequestMerchantSessionUpdate is not supported."];
}

- (void)paymentAuthorizationControllerWillAuthorizePayment:(PKPaymentAuthorizationController *)controller
{
    NSLog(@"willAuthorizePayment");
}

- (void)paymentAuthorizationController:(PKPaymentAuthorizationController *)controller
                didSelectPaymentMethod:(PKPaymentMethod *)paymentMethod
                               handler:(void (^)(PKPaymentRequestPaymentMethodUpdate * _Nonnull))completion
{
    NSLog(@"didSelectPaymentMethod");
    
    AWXPaymentIntent *paymentIntent = ((AWXOneOffSession *)self.session).paymentIntent;
    NSArray<PKPaymentSummaryItem *> *paymentSummaryItems = [self paymenetSummaryItemsForIntent:paymentIntent];
    PKPaymentRequestPaymentMethodUpdate *update = [[PKPaymentRequestPaymentMethodUpdate alloc] initWithPaymentSummaryItems:paymentSummaryItems];
    completion(update);
}

- (void)paymentAuthorizationController:(PKPaymentAuthorizationController *)controller
               didSelectShippingMethod:(PKShippingMethod *)shippingMethod
                               handler:(void (^)(PKPaymentRequestShippingMethodUpdate * _Nonnull))completion
{
    NSLog(@"didSelectShippingMethod");
    
    AWXPaymentIntent *paymentIntent = ((AWXOneOffSession *)self.session).paymentIntent;
    NSArray<PKPaymentSummaryItem *> *paymentSummaryItems = [self paymenetSummaryItemsForIntent:paymentIntent];
    PKPaymentRequestShippingMethodUpdate *update = [[PKPaymentRequestShippingMethodUpdate alloc] initWithPaymentSummaryItems:paymentSummaryItems];
    completion(update);
}

- (void)paymentAuthorizationController:(PKPaymentAuthorizationController *)controller
              didSelectShippingContact:(PKContact *)contact
                               handler:(void (^)(PKPaymentRequestShippingContactUpdate * _Nonnull))completion
{
    NSLog(@"didSelectShippingContact");
    
    AWXPaymentIntent *paymentIntent = ((AWXOneOffSession *)self.session).paymentIntent;
    NSArray<PKPaymentSummaryItem *> *paymentSummaryItems = [self paymenetSummaryItemsForIntent:paymentIntent];
    PKPaymentRequestShippingMethodUpdate *update = [[PKPaymentRequestShippingContactUpdate alloc] initWithPaymentSummaryItems:paymentSummaryItems];
    completion(update);
}

- (void)paymentAuthorizationController:(PKPaymentAuthorizationController *)controller
                   didAuthorizePayment:(PKPayment *)payment
                               handler:(void (^)(PKPaymentAuthorizationResult * _Nonnull))completion
{
    PKPaymentToken *token = payment.token;
    NSData *paymentData = token.paymentData;
    NSError *error = nil;
    
    NSDictionary *paymentJSON = [NSJSONSerialization JSONObjectWithData:paymentData options:NSJSONReadingAllowFragments error:&error];
    
    if (error) {
        [self completeWithResponse:nil error: error];
        return;
    }
    
    NSDictionary *header = paymentJSON[@"header"];
    AWXPaymentMethod *method = [AWXPaymentMethod new];
    method.type = AWXApplePayKey;
    method.customerId = self.session.customerId;
    method.billing = self.session.billing;
    
    NSDictionary *applePayParams = @{
        @"card_brand" : token.paymentMethod.network.lowercaseString,
        @"card_type" : [self mapPaymentMethodType:token.paymentMethod.type],
        @"data" : paymentJSON[@"data"],
        @"ephemeral_public_key" : header[@"ephemeralPublicKey"],
        @"public_key_hash" : header[@"publicKeyHash"],
        @"transaction_id" : header[@"transactionId"],
        @"signature" : paymentJSON[@"signature"],
        @"version" : paymentJSON[@"version"]
    };
    
    [method appendAdditionalParams:applePayParams];
    
    [self.delegate providerDidStartRequest:self];
    [self confirmPaymentIntentWithPaymentMethod:method
                                 paymentConsent:nil
                                         device:nil
                                     completion:^(AWXResponse * _Nullable response, NSError * _Nullable error) {
        AWXConfirmPaymentIntentResponse *confirmResponse = (AWXConfirmPaymentIntentResponse *)response;
        
        PKPaymentAuthorizationStatus status;
        NSArray<NSError *> *errors;
        
        if (confirmResponse && !error) {
            status = PKPaymentAuthorizationStatusSuccess;
            errors = [NSArray new];
        } else {
            status = PKPaymentAuthorizationStatusFailure;
            errors = @[error];
        }
        
        PKPaymentAuthorizationResult *result = [[PKPaymentAuthorizationResult alloc] initWithStatus:status errors:errors];
        completion(result);
        
        [self completeWithResponse:confirmResponse error:error];
    }];
}

- (void)paymentAuthorizationControllerDidFinish:(nonnull PKPaymentAuthorizationController *)controller
{
    NSLog(@"paymentAuthorizationControllerDidFinish");
    [controller dismissWithCompletion:^{
        NSLog(@"PKPaymentAuthorizationController dismissed!");
    }];
}

- (NSString *)mapPaymentMethodType:(PKPaymentMethodType)type
{
    switch (type) {
        case PKPaymentMethodTypeCredit:
            return @"credit";
        case PKPaymentMethodTypeDebit:
            return @"debit";
        case PKPaymentMethodTypeEMoney:
            return @"emoney";
        case PKPaymentMethodTypePrepaid:
            return @"prepaid";
        case PKPaymentMethodTypeStore:
            return @"store";
        case PKPaymentMethodTypeUnknown:
            return @"unknown";
    }
}

@end
