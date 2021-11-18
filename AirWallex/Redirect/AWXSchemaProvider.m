//
//  AWXSchemaProvider.m
//  Redirect
//
//  Created by Victor Zhu on 2021/10/28.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXSchemaProvider.h"
#import "AWXFormMapping.h"
#import "AWXForm.h"
#import "AWXPaymentFormViewController.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXSession.h"
#import "AWXAPIClient.h"

@interface AWXSchemaProvider () <AWXPaymentFormViewControllerDelegate>

@property (nonatomic, strong) AWXFormMapping *banksMapping;
@property (nonatomic, strong) AWXFormMapping *fieldsMapping;
@property (nonatomic, strong) AWXPaymentMethod *updatedPaymentMethod;

@end

@implementation AWXSchemaProvider

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
    
    NSArray *hiddenFields = [schema.fields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hidden == TRUE"]];
    [self updatePaymentMethodWithHiddenFields:hiddenFields];
    
    BOOL hasBankList = [schema.fields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@ && uiType == %@ && hidden == FALSE", @"banks", @"logo_list"]].count > 0;
    NSArray *uiFields = [schema.fields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(uiType == %@ || uiType == %@ || uiType == %@) && hidden == FALSE", @"text", @"email", @"phone"]];
    BOOL hasUIFields = uiFields.count > 0;
    if (hasUIFields) {
        self.fieldsMapping = [self getUIFields:response schema:schema];
    }
    
    if (hasBankList) {
        [self getAvailableBankList:response.name];
        return;
    }
    
    if (!hasUIFields) {
        [self confirmPaymentIntentWithPaymentMethod:self.updatedPaymentMethod
                                     paymentConsent:nil
                                             device:nil];
        return;
    }
    
    [self.delegate providerDidEndRequest:self];
    [self renderFields:NO];
}

- (AWXFormMapping *)getUIFields:(AWXGetPaymentMethodTypeResponse *)response schema:(AWXSchema *)schema
{
    // type: enum && ui_type: list not supported
    // type: boolean && ui_type: checkbox not supported
    NSArray *uiFields = [schema.fields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(uiType == %@ || uiType == %@ || uiType == %@) && hidden == FALSE", @"text", @"email", @"phone"]];
    AWXFormMapping *formMapping = [AWXFormMapping new];
    formMapping.title = response.displayName;
    NSMutableArray *forms = [NSMutableArray array];
    for (AWXField *field in uiFields) {
        [forms addObject:[AWXForm formWithKey:field.name type:AWXFormTypeText title:field.displayName textFieldType:GetTextFieldTypeByUIType(field.uiType)]];
    }
    [forms addObject:[AWXForm formWithKey:@"pay" type:AWXFormTypeButton title:@"Pay now"]];
    formMapping.forms = forms;
    return formMapping;
}

- (void)updatePaymentMethodWithHiddenFields:(NSArray<AWXField* > *)hiddenFields
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    AWXField *flowField = [hiddenFields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", @"flow"]].firstObject;
    if (flowField) {
        BOOL isInApp = [flowField.candidates filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"value == %@", @"inapp"]].count > 0;
        if (isInApp) {
            params[@"flow"] = @"inapp";
        } else {
            AWXCandidate *first = flowField.candidates.firstObject;
            if (first) {
                params[@"flow"] = first.value;
            }
        }
    }
    AWXField *osTypeField = [hiddenFields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", @"osType"]].firstObject;
    if (osTypeField) {
        params[@"osType"] = @"ios";
    }
    AWXField *countryCodeField = [hiddenFields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", @"country_code"]].firstObject;
    if (countryCodeField) {
        params[@"country_code"] = self.session.countryCode;
    }
    [self.updatedPaymentMethod appendAdditionalParams:params];
}

- (void)renderFields:(BOOL)forceToDismiss
{
    AWXPaymentFormViewController *controller = [[AWXPaymentFormViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.session = self.session;
    controller.paymentMethod = self.updatedPaymentMethod;
    controller.formMapping = self.fieldsMapping;
    controller.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self.delegate provider:self shouldPresentViewController:controller forceToDismiss:forceToDismiss withAnimation:NO];
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
        [forms addObject:[AWXForm formWithKey:bank.name type:AWXFormTypeListCell title:bank.displayName logo:bank.resources.logoURL]];
    }
    for (AWXBank *bank in response.items) {
        [forms addObject:[AWXForm formWithKey:bank.name type:AWXFormTypeListCell title:bank.displayName logo:bank.resources.logoURL]];
    }
    for (AWXBank *bank in response.items) {
        [forms addObject:[AWXForm formWithKey:bank.name type:AWXFormTypeListCell title:bank.displayName logo:bank.resources.logoURL]];
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
    controller.paymentMethod = self.updatedPaymentMethod;
    controller.formMapping = self.banksMapping;
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.delegate provider:self shouldPresentViewController:controller forceToDismiss:NO withAnimation:NO];
}

- (void)handleFlow
{
    self.updatedPaymentMethod = self.paymentMethod;
    [self getPaymentMethodType];
}

#pragma mark - AWXPaymentFormViewControllerDelegate

- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController didUpdatePaymentMethod:(nonnull AWXPaymentMethod *)paymentMethod
{
    self.updatedPaymentMethod = paymentMethod;
    [self renderFields:YES];
}

- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController didConfirmPaymentMethod:(nonnull AWXPaymentMethod *)paymentMethod
{
    self.updatedPaymentMethod = paymentMethod;
    [self confirmPaymentIntentWithPaymentMethod:paymentMethod
                                 paymentConsent:nil
                                         device:nil];
}

@end
