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

@interface AWXPPROProvider () <AWXPaymentFormViewControllerDelegate>

@end

@implementation AWXPPROProvider

- (void)handleFlow
{
    AWXFormMapping *formMapping = [AWXFormMapping new];
    //        if ([self.paymentMethod.type isEqualToString:AWXBankTransfer]) {
    formMapping.title = NSLocalizedString(@"Select your bank", @"Select your bank");
    formMapping.forms = @[
        [AWXForm formWithKey:@"bank_name" type:AWXFormTypeOption title:@"Affin Bank" placeholder:@"affin" logo:@"affin_bank"],
        [AWXForm formWithKey:@"bank_name" type:AWXFormTypeOption title:@"Alliance Bank" placeholder:@"alliance" logo:@"alliance_bank"],
        [AWXForm formWithKey:@"bank_name" type:AWXFormTypeOption title:@"AmBank" placeholder:@"ambank" logo:@"ambank"],
        [AWXForm formWithKey:@"bank_name" type:AWXFormTypeOption title:@"Bank Islam" placeholder:@"islam" logo:@"bank_islam"],
        [AWXForm formWithKey:@"bank_name" type:AWXFormTypeOption title:@"Bank Kerjasama Rakyat Malaysia" placeholder:@"rakyat" logo:@"bank_kerjasama_rakyat"],
        [AWXForm formWithKey:@"bank_name" type:AWXFormTypeOption title:@"Bank Muamalat" placeholder:@"muamalat" logo:@"bank_muamalat"],
        [AWXForm formWithKey:@"bank_name" type:AWXFormTypeOption title:@"Bank Simpanan Nasional" placeholder:@"bsn" logo:@"bank_simpanan_nasional"]
    ];
    //        } else {
    //            formMapping.title = FormatPaymentMethodTypeString(self.paymentMethod.type);
    //            formMapping.forms = @[
    //                [AWXForm formWithKey:@"shopper_name" type:AWXFormTypeField title:@"Name"],
    //                [AWXForm formWithKey:@"shopper_email" type:AWXFormTypeField title:@"Email"],
    //                [AWXForm formWithKey:@"shopper_phone" type:AWXFormTypeField title:@"Phone"],
    //                [AWXForm formWithKey:@"pay" type:AWXFormTypeButton title:@"Pay now"]
    //            ];
    //        }
    
    AWXPaymentFormViewController *controller = [[AWXPaymentFormViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.session = self.session;
    controller.paymentMethod = self.paymentMethod;
    controller.formMapping = formMapping;
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.delegate provider:self shouldPresentViewController:controller forceToDismiss:NO];
}

#pragma mark - AWXPaymentFormViewControllerDelegate

- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController didUpdatePaymentMethod:(nonnull AWXPaymentMethod *)paymentMethod
{
    AWXFormMapping *formMapping = [AWXFormMapping new];
    formMapping.title = NSLocalizedString(@"Bank transfer", @"Bank transfer");
    formMapping.forms = @[
        [AWXForm formWithKey:@"shopper_name" type:AWXFormTypeField title:@"Name"],
        [AWXForm formWithKey:@"shopper_email" type:AWXFormTypeField title:@"Email"],
        [AWXForm formWithKey:@"shopper_phone" type:AWXFormTypeField title:@"Phone"],
        [AWXForm formWithKey:@"pay" type:AWXFormTypeButton title:@"Pay now"]
    ];
    
    AWXPaymentFormViewController *controller = [[AWXPaymentFormViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.session = self.session;
    controller.paymentMethod = self.paymentMethod;
    controller.formMapping = formMapping;
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.delegate provider:self shouldPresentViewController:controller forceToDismiss:YES];
}

- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController didConfirmPaymentMethod:(nonnull AWXPaymentMethod *)paymentMethod
{
    [self.delegate provider:self shouldPresentViewController:nil forceToDismiss:YES];
    [self confirmPaymentIntentWithPaymentMethod:paymentMethod
                                 paymentConsent:nil];
}

@end
