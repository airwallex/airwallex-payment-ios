//
//  AWCardViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/1.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWCardViewController.h"
#import "AWEditShippingViewController.h"
#import "AWWidgets.h"
#import "AWBilling.h"
#import "AWUtils.h"
#import "AWCard.h"
#import "AWPaymentMethod.h"
#import "AWPaymentMethodRequest.h"
#import "AWPaymentConfiguration.h"
#import "AWAPIClient.h"
#import "AWPaymentMethodResponse.h"

@interface AWCardViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet AWCardTextField *cardNoField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *nameField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *expiresField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *cvcField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeBarButtonItem;
@property (strong, nonatomic) IBOutlet AWHUD *HUD;

@end

@implementation AWCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameField.fieldType = AWTextFieldTypeNameOnCard;
    self.cardNoField.fieldType = AWTextFieldTypeCardNumber;
    self.expiresField.fieldType = AWTextFieldTypeExpires;
    self.cvcField.fieldType = AWTextFieldTypeCVC;

    self.closeBarButtonItem.image = [[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
    // Fake billing data
    AWBilling *billing = [AWBilling new];
    billing.firstName = @"Charlie";
    billing.lastName = @"Lang";
    billing.email = @"jim631@sina.com";
    billing.phoneNumber = @"";
    AWAddress *address = [AWAddress new];
    address.countryCode = @"AI";
    address.state = @"Victoria";
    address.city = @"Melbourne";
    address.street = @"7\\/15 William St";
    address.postcode = @"";
    billing.address = address;

    AWCard *card = [AWCard new];
    card.name = self.nameField.text;
    card.number = [self.cardNoField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    card.expiryYear = [self.expiresField.text substringFromIndex:3];
    card.expiryMonth = [self.expiresField.text substringToIndex:2];
    card.cvc = self.cvcField.text;

    AWPaymentMethod *paymentMethod = [AWPaymentMethod new];
    paymentMethod.type = @"card";
    paymentMethod.card = card;
    paymentMethod.billing = billing;

    AWCreatePaymentMethodRequest *request = [AWCreatePaymentMethodRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = [AWPaymentConfiguration sharedConfiguration].customerId;
    request.paymentMethod = paymentMethod;

    [self.HUD show];
    __weak typeof(self) weakSelf = self;
    AWAPIClient *client = [AWAPIClient new];
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        if (error) {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:controller animated:YES completion:nil];
            return;
        }

        AWCreatePaymentMethodResponse *result = (AWCreatePaymentMethodResponse *)response;
        [[AWPaymentConfiguration sharedConfiguration] cache:result.paymentMethod.Id value:card.cvc];
        
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf finishCreation:result.paymentMethod];
        [self.HUD dismiss];
    }];
}

@end
