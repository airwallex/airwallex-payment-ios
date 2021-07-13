//
//  OptionsViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/3/20.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "OptionsViewController.h"
#import <Airwallex/Airwallex.h>
#import "AirwallexExamplesKeys.h"
#import "APIClient.h"
#import "UIViewController+Utils.h"

@interface OptionsViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
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
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.hidden = YES;
    [self.view addSubview:self.activityIndicator];
    
    self.regionLabel.text = @"WeChat Region: HK";
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    self.versionLabel.text = [NSString stringWithFormat:@"App Version: v%@ (%@)", version, build];
    
    self.checkoutModesList = @[@"Payment", @"Recurring", @"Recurring with intent"];
    self.nextTriggerByList = @[@"Customer", @"Merchant"];
    
    [self resetTextFields];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.activityIndicator.center = self.view.center;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSValue *rectValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGFloat keyboardHeight = CGRectGetHeight(rectValue.CGRectValue);
    UIScrollView *scrollView = self.scrollView;
    if (scrollView) {
        UIEdgeInsets contentInsets = scrollView.contentInset;
        contentInsets.bottom = keyboardHeight;
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = scrollView.contentInset;
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    UIScrollView *scrollView = self.scrollView;
    if (scrollView) {
        UIEdgeInsets contentInsets = scrollView.contentInset;
        contentInsets.bottom = 0;
        scrollView.contentInset = UIEdgeInsetsZero;
        scrollView.scrollIndicatorInsets = scrollView.contentInset;
    }
}

- (void)resetTextFields
{
    self.modeSwitch.on = Airwallex.mode == AirwallexSDKLiveMode;
    
    self.customerIdTextField.enabled = NO;
    NSString *customerId = [[NSUserDefaults standardUserDefaults] stringForKey:kCachedCustomerID];
    self.customerIdTextField.text = customerId;
    
    NSInteger checkoutMode = [[NSUserDefaults standardUserDefaults] integerForKey:kCachedCheckoutMode];
    [self.checkoutBtn setTitle:self.checkoutModesList[checkoutMode] forState:UIControlStateNormal];
    
    NSInteger nextTriggerBy = [[NSUserDefaults standardUserDefaults] integerForKey:kCachedNextTriggerBy];
    [self.nextTriggerByBtn setTitle:self.nextTriggerByList[nextTriggerBy] forState:UIControlStateNormal];
    
    self.paymentURLTextField.text = [AirwallexExamplesKeys shared].baseUrl;
    self.apiKeyTextField.text = [AirwallexExamplesKeys shared].apiKey;
    self.clientIDTextField.text = [AirwallexExamplesKeys shared].clientId;
    self.amountTextField.text = [AirwallexExamplesKeys shared].amount;
    self.currencyTextField.text = [AirwallexExamplesKeys shared].currency;
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchPressed:(id)sender
{
    [Airwallex setMode:self.modeSwitch.isOn ? AirwallexSDKLiveMode : AirwallexSDKTestMode];
}

- (IBAction)checkoutModeTapped:(id)sender
{
    [self showSelectViewWithArray:self.checkoutModesList completion:^(NSInteger selectIndex) {
        [[NSUserDefaults standardUserDefaults] setInteger:selectIndex forKey:kCachedCheckoutMode];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.checkoutBtn setTitle:self.checkoutModesList[selectIndex] forState:UIControlStateNormal];
    }];
}

- (IBAction)nextTriggerByTapped:(id)sender
{
    [self showSelectViewWithArray:self.nextTriggerByList completion:^(NSInteger selectIndex) {
        [[NSUserDefaults standardUserDefaults] setInteger:selectIndex forKey:kCachedNextTriggerBy];
        [self.nextTriggerByBtn setTitle:self.nextTriggerByList[selectIndex] forState:UIControlStateNormal];
    }];
}

- (IBAction)generateCustomer:(id)sender
{
    [self.activityIndicator startAnimating];
    __weak __typeof(self)weakSelf = self;
    [[APIClient sharedClient] createCustomerWithParameters:@{@"request_id": NSUUID.UUID.UUIDString,
                                                             @"merchant_customer_id": NSUUID.UUID.UUIDString,
                                                             @"first_name": @"John",
                                                             @"last_name": @"Doe",
                                                             @"email": @"john.doe@airwallex.com",
                                                             @"phone_number": @"13800000000",
                                                             @"additional_info": @{@"registered_via_social_media": @NO,
                                                                                   @"registration_date": @"2019-09-18",
                                                                                   @"first_successful_order_date": @"2019-09-18"},
                                                             @"metadata": @{@"id": @1}}
                                         completionHandler:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.activityIndicator stopAnimating];
        if (error) {
            [strongSelf showAlert:error.localizedDescription];
            return;
        }
        
        NSString *customerId = result[@"id"];
        [[NSUserDefaults standardUserDefaults] setObject:customerId forKey:kCachedCustomerID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        strongSelf.customerIdTextField.text = customerId;
    }];
}

- (IBAction)clearCustomerBtnTapped:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCustomerID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.customerIdTextField.text = nil;
}

- (void)showSelectViewWithArray:(NSArray *) arr completion:(void (^)(NSInteger selectIndex))completion
{
    if (arr.count) {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
        for (int i = 0; i < arr.count; i++) {
            NSString *str = arr[i];
            UIAlertAction *ac = [UIAlertAction actionWithTitle: str style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                completion(i);
            }];
            [alertView addAction:ac];
        }
        UIAlertAction *cancelAc = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:(UIAlertActionStyleCancel) handler:nil];
        [alertView addAction:cancelAc];
        [self.navigationController presentViewController:alertView animated:YES completion:nil];
    }
}

- (IBAction)resetPressed:(id)sender
{
    [[AirwallexExamplesKeys shared] resetKeys];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCustomerID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCheckoutMode];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedNextTriggerBy];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self resetExamplesAPIClient];
    [self resetSDK];
    [self resetTextFields];
}

- (void)resetExamplesAPIClient
{
    APIClient *client = [APIClient sharedClient];
    client.paymentBaseURL = [NSURL URLWithString:[AirwallexExamplesKeys shared].baseUrl];
    client.apiKey = [AirwallexExamplesKeys shared].apiKey;
    client.clientID = [AirwallexExamplesKeys shared].clientId;
    
    [[APIClient sharedClient] createAuthenticationTokenWithCompletionHandler:nil];
}

- (void)resetSDK
{
    [Airwallex setMode:AirwallexSDKTestMode];
    [Airwallex setDefaultBaseURL:[NSURL URLWithString:[AirwallexExamplesKeys shared].baseUrl]];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.paymentURLTextField) {
        NSURL *url = [NSURL URLWithString:textField.text];
        if (url.scheme && url.host) {
            [APIClient sharedClient].paymentBaseURL = url;
            [Airwallex setDefaultBaseURL:url];
            [AirwallexExamplesKeys shared].baseUrl = url.absoluteString;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCustomerID];
            [[APIClient sharedClient] createAuthenticationTokenWithCompletionHandler:nil];
        } else {
            [self showAlert:NSLocalizedString(@"Not a valid payment url", nil)];
        }
    } else if (textField == self.apiKeyTextField) {
        [APIClient sharedClient].apiKey = textField.text;
        [AirwallexExamplesKeys shared].apiKey = textField.text;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCustomerID];
        [[APIClient sharedClient] createAuthenticationTokenWithCompletionHandler:nil];
    } else if (textField == self.clientIDTextField) {
        [APIClient sharedClient].clientID = textField.text;
        [AirwallexExamplesKeys shared].clientId = textField.text;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCustomerID];
        [[APIClient sharedClient] createAuthenticationTokenWithCompletionHandler:nil];
    } else if (textField == self.amountTextField) {
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:textField.text];
        if (amount == NSDecimalNumber.notANumber) {
            amount = NSDecimalNumber.zero;
        }
        [AirwallexExamplesKeys shared].amount = amount.stringValue;
    } else if (textField == self.currencyTextField) {
        if ([textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
            [AirwallexExamplesKeys shared].currency = textField.text.uppercaseString;
        } else {
            [self showAlert:NSLocalizedString(@"Please enter a valid currency", nil)];
        }
    } else if (textField == self.customerIdTextField) {
        if (textField.text.length == 0) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCustomerID];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc
{
    NSLog(@"Payment Base URL (Example): %@", [APIClient sharedClient].paymentBaseURL.absoluteString);
    NSLog(@"API Key (Example): %@", [APIClient sharedClient].apiKey);
    NSLog(@"Client ID (Example): %@", [APIClient sharedClient].clientID);
    NSLog(@"Amount (Example): %@", self.amountTextField.text);
    NSLog(@"Currency (Example): %@", self.currencyTextField.text);
    
    NSLog(@"Payment Base URL (SDK): %@", [Airwallex defaultBaseURL].absoluteString);
    NSLog(@"SDK mode (SDK): %@", [Airwallex mode] == AirwallexSDKTestMode ? @"Test" : @"Production");
    
    NSLog(@"Customer ID (SDK): %@", [[NSUserDefaults standardUserDefaults] stringForKey:kCachedCustomerID]);
    NSLog(@"Checkout mode (SDK): %@", self.checkoutModesList[[[NSUserDefaults standardUserDefaults] integerForKey:kCachedCheckoutMode]]);
    NSLog(@"Next trigger by type (SDK): %@", self.nextTriggerByList[[[NSUserDefaults standardUserDefaults] integerForKey:kCachedNextTriggerBy]]);
}

@end
