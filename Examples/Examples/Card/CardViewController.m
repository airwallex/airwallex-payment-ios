//
//  CardViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/2/1.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "CardViewController.h"
#import <Airwallex/Airwallex.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "Widgets.h"

@interface CardViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet CardTextField *cardNoField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *nameField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *expiresField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *cvcField;

@end

@implementation CardViewController

- (IBAction)closePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)finishCreation:(AWPaymentMethod *)paymentMethod
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardViewController:didCreatePaymentMethod:)]) {
        [self.delegate cardViewController:self didCreatePaymentMethod:paymentMethod];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)savePressed:(id)sender
{
    AWCard *card = [AWCard new];
    card.name = self.nameField.text;
    card.number = [self.cardNoField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    card.expiryYear = [self.expiresField.text substringFromIndex:3];
    card.expiryMonth = [self.expiresField.text substringToIndex:2];
    card.cvc = self.cvcField.text;

    AWPaymentMethod *paymentMethod = [AWPaymentMethod new];
    paymentMethod.type = @"card";
    paymentMethod.card = card;

    AWCreatePaymentMethodRequest *request = [AWCreatePaymentMethodRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.paymentMethod = paymentMethod;

    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    AWAPIClient *client = [AWAPIClient new];
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        AWCreatePaymentMethodResponse *result = (AWCreatePaymentMethodResponse *)response;
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf finishCreation:result.paymentMethod];
        [SVProgressHUD dismiss];
    }];
}

@end
