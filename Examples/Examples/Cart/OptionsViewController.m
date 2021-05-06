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

@property (weak, nonatomic) IBOutlet UITextField *paymentURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *apiKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *clientIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *currencyTextField;

@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *modeSwitch;
@property (weak, nonatomic) IBOutlet UIButton *checkoutBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextTriggerByBtn;
@property (weak, nonatomic) IBOutlet UITextField *customerIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *clearCustomerIdButton;

@property(nonatomic, strong) NSArray *checkoutModesList;
@property(nonatomic, strong) NSArray *nextTriggerByList;

@end

@implementation OptionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.regionLabel.text = @"WeChat Region: HK";

    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    self.versionLabel.text = [NSString stringWithFormat:@"App Version: v%@ (%@)", version, build];
    
    self.checkoutModesList = @[@"Payment",@"Recurring",@"Recurring with intent"];
    self.nextTriggerByList = @[@"Customer",@"Merchant"];
    
    [self resetTextFields];
}



- (void)resetTextFields
{
    self.modeSwitch.on = Airwallex.mode == AirwallexSDKLiveMode;
    
    [self.checkoutBtn setTitle:self.checkoutModesList[Airwallex.checkoutMode] forState:(UIControlStateNormal)];
    [self.nextTriggerByBtn setTitle:self.nextTriggerByList[Airwallex.nextTriggerByType] forState:(UIControlStateNormal)];
    
    self.paymentURLTextField.text = [APIClient sharedClient].paymentBaseURL.absoluteString;
    self.apiKeyTextField.text = [APIClient sharedClient].apiKey;
    self.clientIDTextField.text = [APIClient sharedClient].clientID;
    self.amountTextField.text = self.amount ? [NSString stringWithFormat:@"%.2f", self.amount.doubleValue] : defaultAmount;
    self.currencyTextField.text = self.currency ?: defaultCurrency;
    
    self.customerIdTextField.enabled = NO;
    NSString *customerId = [[NSUserDefaults standardUserDefaults] stringForKey:kCachedCustomerID];
    self.customerIdTextField.text = customerId;
    
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchPressed:(id)sender
{
    [Airwallex setMode:self.modeSwitch.isOn ? AirwallexSDKLiveMode : AirwallexSDKTestMode];
}
- (IBAction)checkoutModeTapped:(id)sender {
    [self showSelectViewWithArray:self.checkoutModesList completion:^(NSInteger selectIndex) {
        [Airwallex setCheckoutMode: selectIndex];
        [self.checkoutBtn setTitle:self.checkoutModesList[Airwallex.checkoutMode] forState:(UIControlStateNormal)];
    }];
}
- (IBAction)nextTriggerByTapped:(id)sender {
    [self showSelectViewWithArray:self.nextTriggerByList completion:^(NSInteger selectIndex) {
        [Airwallex setNextTriggerByType: selectIndex];
        [self.nextTriggerByBtn setTitle:self.nextTriggerByList[Airwallex.nextTriggerByType] forState:(UIControlStateNormal)];
    }];
}
- (IBAction)clearCustomerBtnTapped:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCustomerID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self resetTextFields];
}

-(void)showSelectViewWithArray:(NSArray *) arr completion:(void (^)(NSInteger selectIndex))completion{
    if (arr.count) {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
        for (int i = 0; i < arr.count; i++) {
            NSString *str = arr[i];
            UIAlertAction *ac = [UIAlertAction actionWithTitle: str style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                completion(i);
            }];
            [alertView addAction:ac];
        }
        UIAlertAction *cancelAc = [UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:nil];
        [alertView addAction:cancelAc];
        [self.navigationController presentViewController:alertView animated:YES completion:nil];
    }
}



- (IBAction)resetPressed:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCustomerID];
    [[NSUserDefaults standardUserDefaults] synchronize];

    APIClient *client = [APIClient sharedClient];
    client.paymentBaseURL = [NSURL URLWithString:paymentBaseURL];
    client.apiKey = [AirwallexExamplesKeys shared].apiKey;
    client.clientID = [AirwallexExamplesKeys shared].clientID;

    [Airwallex setMode:AirwallexSDKTestMode];
    [Airwallex setCheckoutMode:AirwallexCheckoutPaymentMode];
    [Airwallex setNextTriggerByType:AirwallexNextTriggerByCustomerType];
    [Airwallex setDefaultBaseURL:[NSURL URLWithString:paymentBaseURL]];

    [self.delegate optionsViewController:self didEditAmount:[NSDecimalNumber decimalNumberWithString:defaultAmount]];
    [self.delegate optionsViewController:self didEditCurrency:defaultCurrency];

    [self resetTextFields];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.paymentURLTextField) {
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
    }else if (textField == self.customerIdTextField) {
        if (textField.text.length == 0) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCustomerID];
            [[NSUserDefaults standardUserDefaults] synchronize];
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
    NSLog(@"Payment Base URL (Example): %@", [APIClient sharedClient].paymentBaseURL.absoluteString);
    NSLog(@"Payment Base URL (SDK): %@", [Airwallex defaultBaseURL].absoluteString);
    NSLog(@"API Key: %@", [APIClient sharedClient].apiKey);
    NSLog(@"Client ID: %@", [APIClient sharedClient].clientID);
    NSLog(@"Amount: %@", self.amountTextField.text);
    NSLog(@"Currency: %@", self.currencyTextField.text);
}

@end
