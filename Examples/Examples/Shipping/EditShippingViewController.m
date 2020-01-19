//
//  EditShippingViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "EditShippingViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "AWBilling+Utils.h"
#import "Widgets.h"

@interface EditShippingViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *lastNameField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *firstNameField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *stateField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *cityField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *streetField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *zipcodeField;

@end

@implementation EditShippingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.saveBarButtonItem.enabled = self.billing.isValid;
}

- (IBAction)savePressed:(id)sender
{
    AWBilling *billing = [AWBilling new];
    billing.lastName = self.lastNameField.text;
    billing.firstName = self.firstNameField.text;
    billing.phoneNumber = self.phoneNumberField.text;
    AWAddress *address = [AWAddress new];
    address.state = self.stateField.text;
    address.city = self.cityField.text;
    address.street = self.streetField.text;
    address.postcode = self.zipcodeField.text;
    billing.address = address;
    NSString *error = [billing validate];
    if (error) {
        [SVProgressHUD showErrorWithStatus:error];
        return;
    }

    self.billing = billing;
    if (self.delegate && [self.delegate respondsToSelector:@selector(editShippingViewController:didSelectBilling:)]) {
        [self.delegate editShippingViewController:self didSelectBilling:billing];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
