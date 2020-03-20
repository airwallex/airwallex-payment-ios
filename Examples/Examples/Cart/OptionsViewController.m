//
//  OptionsViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/3/20.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "OptionsViewController.h"
#import <Airwallex/Airwallex.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "APIClient.h"
#import "Constant.h"

@interface OptionsViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *authURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *paymentURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *apiKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *clientIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *totalAmountTextField;
@property (weak, nonatomic) IBOutlet UITextField *currencyTextField;

@end

@implementation OptionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self resetTextFields];
}

- (void)resetTextFields
{
    self.authURLTextField.text = [APIClient sharedClient].authBaseURL.absoluteString;
    self.paymentURLTextField.text = [APIClient sharedClient].paymentBaseURL.absoluteString;
    self.apiKeyTextField.text = [APIClient sharedClient].apiKey;
    self.clientIDTextField.text = [APIClient sharedClient].clientID;
    self.totalAmountTextField.text = [NSString stringWithFormat:@"%0.2f", [AWPaymentConfiguration sharedConfiguration].totalAmount.doubleValue];
    self.currencyTextField.text = [AWPaymentConfiguration sharedConfiguration].currency;
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)resetPressed:(id)sender
{
    APIClient *client = [APIClient sharedClient];
    client.authBaseURL = [NSURL URLWithString:authenticationBaseURL];
    client.paymentBaseURL = [NSURL URLWithString:paymentBaseURL];
    client.apiKey = apiKey;
    client.clientID = clientID;

    AWPaymentConfiguration *configuration = [AWPaymentConfiguration sharedConfiguration];
    configuration.baseURL = [NSURL URLWithString:paymentBaseURL];
    configuration.totalAmount = [NSDecimalNumber decimalNumberWithString:defaultTotalAmount];
    configuration.currency = defaultCurrency;

    [self resetTextFields];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.authURLTextField) {
        NSURL *url = [NSURL URLWithString:textField.text];
        if (url) {
            [APIClient sharedClient].authBaseURL = url;
        } else {
            [SVProgressHUD showErrorWithStatus:@"Not a valid auth url"];
        }
    } else if (textField == self.paymentURLTextField) {
        NSURL *url = [NSURL URLWithString:textField.text];
        if (url) {
            [APIClient sharedClient].paymentBaseURL = url;
            [AWPaymentConfiguration sharedConfiguration].baseURL = url;
        } else {
            [SVProgressHUD showErrorWithStatus:@"Not a valid payment url"];
        }
    } else if (textField == self.apiKeyTextField) {
        [APIClient sharedClient].apiKey = textField.text;
    } else if (textField == self.clientIDTextField) {
        [APIClient sharedClient].clientID = textField.text;
    } else if (textField == self.totalAmountTextField) {
        NSDecimalNumber *totalAmount = [NSDecimalNumber decimalNumberWithString:textField.text];
        if (totalAmount == NSDecimalNumber.notANumber) {
            totalAmount = NSDecimalNumber.zero;
        }
        [self.delegate optionsViewController:self didEditTotalAmount:totalAmount];
    } else if (textField == self.currencyTextField) {
        if ([textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
            [self.delegate optionsViewController:self didEditCurrency:textField.text.uppercaseString];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Please enter a valid currency"];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc
{
    NSLog(@"Auth Base URL: %@", [APIClient sharedClient].authBaseURL.absoluteString);
    NSLog(@"Payment Base URL (Example): %@", [APIClient sharedClient].paymentBaseURL.absoluteString);
    NSLog(@"Payment Base URL (SDK): %@", [AWPaymentConfiguration sharedConfiguration].baseURL);
    NSLog(@"API Key: %@", [APIClient sharedClient].apiKey);
    NSLog(@"Client ID: %@", [APIClient sharedClient].clientID);
    NSLog(@"Total amount: %@", self.totalAmountTextField.text);
    NSLog(@"Currency: %@", self.currencyTextField.text);
}

@end
