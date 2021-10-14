//
//  AWXPPROProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/20.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXPPROProvider.h"
#import "AWXFormMapping.h"
#import "AWXForm.h"
#import "AWXPaymentFormViewController.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXSession.h"
#import "AWXAPIClient.h"

@interface AWXPPROProvider () <AWXPaymentFormViewControllerDelegate>

@property (nonatomic, strong) AWXFormMapping *banksMapping;
@property (nonatomic, strong) AWXFormMapping *fieldsMapping;

@end

@implementation AWXPPROProvider

- (void)getPaymentMethodType
{
    AWXGetPaymentMethodTypeRequest *request = [AWXGetPaymentMethodTypeRequest new];
    request.name = self.paymentMethod.type;
    request.transactionMode = self.session.transactionMode;
    request.lang = self.session.lang;
    
    [self.delegate providerDidStartRequest:self];
    __weak __typeof(self)weakSelf = self;
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (response && !error) {
            [strongSelf verifyPaymentMethodType:response];
        } else {
            [strongSelf.delegate providerDidEndRequest:strongSelf];
            [strongSelf.delegate provider:strongSelf didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
        }
    }];
}

- (void)verifyPaymentMethodType:(AWXGetPaymentMethodTypeResponse *)response
{
    AWXSchema *schema = [response.schemas filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"transactionMode == %@", self.session.transactionMode]].firstObject;
    if (!schema || schema.fields.count == 0) {
        [self.delegate providerDidEndRequest:self];
        [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid schema.", nil)}]];
        return;
    }
    
    NSArray *uiFields = [schema.fields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type != %@ && uiType != %@", @"banks", @"logo_list"]];
    
    AWXFormMapping *formMapping = [AWXFormMapping new];
    formMapping.title = NSLocalizedString(@"Bank transfer", @"Bank transfer");
    NSMutableArray *forms = [NSMutableArray array];
    for (AWXField *field in uiFields) {
        [forms addObject:[AWXForm formWithKey:field.name type:AWXFormTypeField title:field.displayName]];
    }
    [forms addObject:[AWXForm formWithKey:@"pay" type:AWXFormTypeButton title:@"Pay now"]];
    formMapping.forms = forms;
    self.fieldsMapping = formMapping;
    
    if (uiFields.count != schema.fields.count) {
        [self getAvailableBankList:response.name];
    } else {
        [self.delegate providerDidEndRequest:self];
        [self renderFields:NO];
    }
}

- (void)renderFields:(BOOL)forceToDismiss
{
    AWXPaymentFormViewController *controller = [[AWXPaymentFormViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.session = self.session;
    controller.paymentMethod = self.paymentMethod;
    controller.formMapping = self.fieldsMapping;
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.delegate provider:self shouldPresentViewController:controller forceToDismiss:forceToDismiss];
}

- (void)getAvailableBankList:(NSString *)paymentMethodType
{
    AWXGetAvailableBanksRequest *request = [AWXGetAvailableBanksRequest new];
    request.paymentMethodType = paymentMethodType;
    request.countryCode = self.session.countryCode;
    request.lang = self.session.lang;
    
    __weak __typeof(self)weakSelf = self;
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.delegate providerDidEndRequest:strongSelf];
        if (response && !error) {
            [strongSelf verifyAvailableBankList:response];
        } else {
            [strongSelf.delegate provider:strongSelf didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
        }
    }];
}

- (void)verifyAvailableBankList:(AWXGetAvailableBanksResponse *)response
{
    AWXFormMapping *formMapping = [AWXFormMapping new];
    formMapping.title = NSLocalizedString(@"Select your bank", @"Select your bank");
    NSMutableArray *forms = [NSMutableArray array];
    for (AWXBank *bank in response.items) {
        [forms addObject:[AWXForm formWithKey:bank.name type:AWXFormTypeOption title:bank.displayName]];
    }
    formMapping.forms = forms;
    self.banksMapping = formMapping;
    
    [self renderBanks];
}

- (void)renderBanks
{
    AWXPaymentFormViewController *controller = [[AWXPaymentFormViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.session = self.session;
    controller.paymentMethod = self.paymentMethod;
    controller.formMapping = self.banksMapping;
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.delegate provider:self shouldPresentViewController:controller forceToDismiss:NO];
}

- (void)handleFlow
{
    [self getPaymentMethodType];
}

#pragma mark - AWXPaymentFormViewControllerDelegate

- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController didUpdatePaymentMethod:(nonnull AWXPaymentMethod *)paymentMethod
{
    [self renderFields:YES];
}

- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController didConfirmPaymentMethod:(nonnull AWXPaymentMethod *)paymentMethod
{
    [self.delegate provider:self shouldPresentViewController:nil forceToDismiss:YES];
    [self confirmPaymentIntentWithPaymentMethod:paymentMethod
                                 paymentConsent:nil
                                         device:nil];
}

@end
