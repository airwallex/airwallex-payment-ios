//
//  AWXCardProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/19.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXCardProvider.h"
#import "AWXCardViewController.h"
#import "AWXSecurityService.h"
#import "AWXDevice.h"
#import "AWXPaymentMethod.h"
#import "AWXSession.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXAPIClient.h"

@implementation AWXCardProvider

- (void)handleFlow
{
    AWXCardViewController *controller = [[AWXCardViewController alloc] initWithNibName:nil bundle:nil];
    controller.sameAsShipping = YES;
    controller.session = self.session;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.delegate provider:self shouldPresentViewController:nav forceToDismiss:NO withAnimation:YES];
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
        [self confirmPaymentIntentWithPaymentMethod:paymentMethod];
    } else {
        __weak __typeof(self)weakSelf = self;
        [self createPaymentMethod:paymentMethod completion:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (response && !error) {
                AWXCreatePaymentMethodResponse *result = (AWXCreatePaymentMethodResponse *)response;
                AWXPaymentMethod *paymentMethod = result.paymentMethod;
                paymentMethod.card.cvc = card.cvc;
                [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod];
            } else {
                [strongSelf.delegate providerDidEndRequest:strongSelf];
                [strongSelf.delegate provider:strongSelf didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
            }
        }];
    }
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
{
    __weak __typeof(self)weakSelf = self;
    [[AWXSecurityService sharedService] doProfile:self.session.paymentIntentId completion:^(NSString * _Nullable sessionId) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        AWXDevice *device = [AWXDevice new];
        device.deviceId = sessionId;
        
        [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod paymentConsent:nil device:device];
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

@end
