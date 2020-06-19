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
#import "AirwallexExamplesKeys+Utils.h"
#import "APIClient.h"
#import "Constant.h"

@interface OptionsViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *authURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *paymentURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *apiKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *clientIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *currencyTextField;
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation OptionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.regionLabel.text = @"WeChat Region: HK";
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    self.versionLabel.text = [NSString stringWithFormat:@"App Version: v%@ (%@)", version, build];
    [self resetTextFields];
}

- (void)resetTextFields
{
    self.authURLTextField.text = [APIClient sharedClient].authBaseURL.absoluteString;
    self.paymentURLTextField.text = [APIClient sharedClient].paymentBaseURL.absoluteString;
    self.apiKeyTextField.text = [APIClient sharedClient].apiKey;
    self.clientIDTextField.text = [APIClient sharedClient].clientID;
    self.amountTextField.text = self.amount ? [NSString stringWithFormat:@"%.2f", self.amount.doubleValue] : defaultAmount;
    self.currencyTextField.text = self.currency ?: defaultCurrency;
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)resetPressed:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCustomerID];
    [[NSUserDefaults standardUserDefaults] synchronize];

    APIClient *client = [APIClient sharedClient];
    client.authBaseURL = [NSURL URLWithString:authenticationBaseURL];
    client.paymentBaseURL = [NSURL URLWithString:paymentBaseURL];
    client.apiKey = [AirwallexExamplesKeys shared].apiKey;
    client.clientID = [AirwallexExamplesKeys shared].clientID;

    [Airwallex setDefaultBaseURL:[NSURL URLWithString:paymentBaseURL]];

    [self.delegate optionsViewController:self didEditAmount:[NSDecimalNumber decimalNumberWithString:defaultAmount]];
    [self.delegate optionsViewController:self didEditCurrency:defaultCurrency];

    [self resetTextFields];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.authURLTextField) {
        NSURL *url = [NSURL URLWithString:textField.text];
        if (url.scheme && url.host) {
            [APIClient sharedClient].authBaseURL = url;
        } else {
            [SVProgressHUD showErrorWithStatus:@"Not a valid auth url"];
        }
    } else if (textField == self.paymentURLTextField) {
        NSURL *url = [NSURL URLWithString:textField.text];
        if (url.scheme && url.host) {
            [APIClient sharedClient].paymentBaseURL = url;
            [Airwallex setDefaultBaseURL:url];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Not a valid payment url"];
        }
    } else if (textField == self.apiKeyTextField) {
        [APIClient sharedClient].apiKey = textField.text;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCustomerID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (textField == self.clientIDTextField) {
        [APIClient sharedClient].clientID = textField.text;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCustomerID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (textField == self.amountTextField) {
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:textField.text];
        if (amount == NSDecimalNumber.notANumber) {
            amount = NSDecimalNumber.zero;
        }
        [self.delegate optionsViewController:self didEditAmount:amount];
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
    NSLog(@"Payment Base URL (SDK): %@", [Airwallex defaultBaseURL].absoluteString);
    NSLog(@"API Key: %@", [APIClient sharedClient].apiKey);
    NSLog(@"Client ID: %@", [APIClient sharedClient].clientID);
    NSLog(@"Amount: %@", self.amountTextField.text);
    NSLog(@"Currency: %@", self.currencyTextField.text);
}

@end
