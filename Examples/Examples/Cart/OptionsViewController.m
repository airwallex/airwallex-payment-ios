//
//  OptionsViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/3/20.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "OptionsViewController.h"
#import "AirwallexExamplesKeys.h"
#import "MockAPIClient.h"
#import "OptionButton.h"
#import "UIViewController+Utils.h"
#import <Airwallex/Core.h>

@interface OptionsViewController ()<UITextFieldDelegate>

@property (strong, nonatomic, nonnull) IBOutletCollection(UILabel) NSArray<UILabel *> *titleLabels;

@property (strong, nonatomic, nonnull) IBOutletCollection(UITextField) NSArray<UITextField *> *textFields;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *apiKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *clientIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *currencyTextField;
@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *returnURLTextField;

@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet OptionButton *modeButton;
@property (weak, nonatomic) IBOutlet OptionButton *checkoutBtn;
@property (weak, nonatomic) IBOutlet OptionButton *nextTriggerByBtn;
@property (weak, nonatomic) IBOutlet UISwitch *cvcSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *threeDSSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoCaptureSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *applePayOnlySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *cardOnlySwitch;
@property (weak, nonatomic) IBOutlet UITextField *customerIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *clearCustomerIdButton;

@property (nonatomic, strong) NSArray *checkoutModesList;
@property (nonatomic, strong) NSArray *nextTriggerByList;

@end

@implementation OptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];

    self.checkoutModesList = @[@"Payment", @"Recurring", @"Recurring with intent"];
    self.nextTriggerByList = @[@"Customer", @"Merchant"];

    [self resetTextFields];
}

- (void)setupViews {
    self.view.backgroundColor = [AWXTheme sharedTheme].primaryBackgroundColor;

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.hidden = YES;
    [self.view addSubview:self.activityIndicator];

    self.regionLabel.text = @"WeChat Region: HK";

    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    self.versionLabel.text = [NSString stringWithFormat:@"App Version: v%@ (%@)", version, build];

    for (UILabel *label in _titleLabels) {
        label.textColor = [AWXTheme sharedTheme].primaryTextColor;
        label.font = [UIFont subhead2Font];
    }

    for (UITextField *textField in _textFields) {
        textField.font = [UIFont bodyFont];
    }

    self.regionLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
    self.versionLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.activityIndicator.center = self.view.center;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
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

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    UIScrollView *scrollView = self.scrollView;
    if (scrollView) {
        UIEdgeInsets contentInsets = scrollView.contentInset;
        contentInsets.bottom = 0;
        scrollView.contentInset = UIEdgeInsetsZero;
        scrollView.scrollIndicatorInsets = scrollView.contentInset;
    }
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)modePressed:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [controller addAction:[UIAlertAction actionWithTitle:@"Demo"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *_Nonnull action) {
                                                     [Airwallex setMode:AirwallexSDKDemoMode];
                                                     [AirwallexExamplesKeys shared].environment = AirwallexSDKDemoMode;
                                                     [[MockAPIClient sharedClient] createAuthenticationTokenWithCompletionHandler:nil];

                                                     [self.modeButton setTitle:FormatAirwallexSDKMode(Airwallex.mode).capitalizedString forState:UIControlStateNormal];
                                                 }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Staging"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *_Nonnull action) {
                                                     [Airwallex setMode:AirwallexSDKStagingMode];
                                                     [AirwallexExamplesKeys shared].environment = AirwallexSDKStagingMode;
                                                     [[MockAPIClient sharedClient] createAuthenticationTokenWithCompletionHandler:nil];

                                                     [self.modeButton setTitle:FormatAirwallexSDKMode(Airwallex.mode).capitalizedString forState:UIControlStateNormal];
                                                 }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Production"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *_Nonnull action) {
                                                     [Airwallex setMode:AirwallexSDKProductionMode];
                                                     [AirwallexExamplesKeys shared].environment = AirwallexSDKProductionMode;
                                                     [[MockAPIClient sharedClient] createAuthenticationTokenWithCompletionHandler:nil];

                                                     [self.modeButton setTitle:FormatAirwallexSDKMode(Airwallex.mode).capitalizedString forState:UIControlStateNormal];
                                                 }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    UIPopoverPresentationController *popPresenter = [controller popoverPresentationController];
    popPresenter.sourceView = sender;

    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)checkoutModeTapped:(id)sender {
    [self showSelectViewWithArray:self.checkoutModesList
                           sender:sender
                       completion:^(NSInteger selectIndex) {
                           [AirwallexExamplesKeys shared].checkoutMode = selectIndex;
                           [self.checkoutBtn setTitle:self.checkoutModesList[selectIndex] forState:UIControlStateNormal];
                       }];
}

- (IBAction)nextTriggerByTapped:(id)sender {
    [self showSelectViewWithArray:self.nextTriggerByList
                           sender:sender
                       completion:^(NSInteger selectIndex) {
                           [AirwallexExamplesKeys shared].nextTriggerByType = selectIndex;
                           [self.nextTriggerByBtn setTitle:self.nextTriggerByList[selectIndex] forState:UIControlStateNormal];
                       }];
}

- (IBAction)cvcSwitchPressed:(id)sender {
    [AirwallexExamplesKeys shared].requireCVC = self.cvcSwitch.isOn;
}

- (IBAction)threeDSSwitchPressed:(id)sender {
    [AirwallexExamplesKeys shared].force3DS = self.threeDSSwitch.isOn;
}

- (IBAction)autoCaptureSwitchPressed:(id)sender {
    [AirwallexExamplesKeys shared].autoCapture = self.autoCaptureSwitch.isOn;
}

- (IBAction)applePayOnlySwitchPressed:(id)sender {
    [AirwallexExamplesKeys shared].applePayMethodOnly = self.applePayOnlySwitch.isOn;
}

- (IBAction)cardOnlySwitchPressed:(id)sender {
    [AirwallexExamplesKeys shared].cardMethodOnly = self.cardOnlySwitch.isOn;
}

- (IBAction)generateCustomer:(id)sender {
    [self.activityIndicator startAnimating];
    __weak __typeof(self) weakSelf = self;
    [[MockAPIClient sharedClient] createCustomerWithParameters:@{@"request_id": NSUUID.UUID.UUIDString,
                                                                 @"merchant_customer_id": NSUUID.UUID.UUIDString,
                                                                 @"first_name": @"Jason",
                                                                 @"last_name": @"Wang",
                                                                 @"email": @"john.doe@airwallex.com",
                                                                 @"phone_number": @"13800000000",
                                                                 @"additional_info": @{@"registered_via_social_media": @NO,
                                                                                       @"registration_date": @"2019-09-18",
                                                                                       @"first_successful_order_date": @"2019-09-18"},
                                                                 @"metadata": @{@"id": @1}}
                                             completionHandler:^(NSDictionary *_Nullable result, NSError *_Nullable error) {
                                                 __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                 [strongSelf.activityIndicator stopAnimating];
                                                 if (error) {
                                                     [strongSelf showAlert:error.localizedDescription withTitle:nil];
                                                     return;
                                                 }

                                                 NSString *customerId = result[@"id"];
                                                 strongSelf.customerIdTextField.text = customerId;
                                                 [AirwallexExamplesKeys shared].customerId = customerId;
                                             }];
}

- (IBAction)clearCustomerBtnTapped:(id)sender {
    [AirwallexExamplesKeys shared].customerId = nil;
    self.customerIdTextField.text = nil;
}

- (void)showSelectViewWithArray:(NSArray *)arr sender:(id)sender completion:(void (^)(NSInteger selectIndex))completion {
    if (arr.count) {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
        for (int i = 0; i < arr.count; i++) {
            NSString *str = arr[i];
            UIAlertAction *ac = [UIAlertAction actionWithTitle:str
                                                         style:(UIAlertActionStyleDefault)handler:^(UIAlertAction *_Nonnull action) {
                                                             completion(i);
                                                         }];
            [alertView addAction:ac];
        }
        UIAlertAction *cancelAc = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:(UIAlertActionStyleCancel)handler:nil];
        [alertView addAction:cancelAc];

        UIPopoverPresentationController *popPresenter = [alertView popoverPresentationController];
        popPresenter.sourceView = sender;

        [self.navigationController presentViewController:alertView animated:YES completion:nil];
    }
}

- (IBAction)resetPressed:(id)sender {
    [[AirwallexExamplesKeys shared] resetKeys];
    [self resetExamplesAPIClient];
    [self resetSDK];
    [self resetTextFields];
}

- (void)resetExamplesAPIClient {
    MockAPIClient *client = [MockAPIClient sharedClient];
    client.apiKey = [AirwallexExamplesKeys shared].apiKey;
    client.clientID = [AirwallexExamplesKeys shared].clientId;
    [[MockAPIClient sharedClient] createAuthenticationTokenWithCompletionHandler:nil];
}

- (void)resetSDK {
    [Airwallex setMode:[AirwallexExamplesKeys shared].environment];
}

- (void)resetTextFields {
    [self.modeButton setTitle:FormatAirwallexSDKMode([AirwallexExamplesKeys shared].environment).capitalizedString forState:UIControlStateNormal];

    NSInteger checkoutMode = [AirwallexExamplesKeys shared].checkoutMode;
    [self.checkoutBtn setTitle:self.checkoutModesList[checkoutMode] forState:UIControlStateNormal];

    NSInteger nextTriggerBy = [AirwallexExamplesKeys shared].nextTriggerByType;
    [self.nextTriggerByBtn setTitle:self.nextTriggerByList[nextTriggerBy] forState:UIControlStateNormal];

    BOOL requiresCVC = [AirwallexExamplesKeys shared].requireCVC;
    self.cvcSwitch.on = requiresCVC;

    BOOL force3DS = [AirwallexExamplesKeys shared].force3DS;
    self.threeDSSwitch.on = force3DS;

    BOOL autoCapture = [AirwallexExamplesKeys shared].autoCapture;
    self.autoCaptureSwitch.on = autoCapture;

    BOOL applePayMethodOnly = [AirwallexExamplesKeys shared].applePayMethodOnly;
    self.applePayOnlySwitch.on = applePayMethodOnly;

    BOOL cardMethodOnly = [AirwallexExamplesKeys shared].cardMethodOnly;
    self.cardOnlySwitch.on = cardMethodOnly;

    self.customerIdTextField.enabled = NO;
    NSString *customerId = [AirwallexExamplesKeys shared].customerId;
    self.customerIdTextField.text = customerId;

    self.apiKeyTextField.text = [AirwallexExamplesKeys shared].apiKey;
    self.clientIDTextField.text = [AirwallexExamplesKeys shared].clientId;
    self.amountTextField.text = [AirwallexExamplesKeys shared].amount;
    self.currencyTextField.text = [AirwallexExamplesKeys shared].currency;
    self.countryCodeTextField.text = [AirwallexExamplesKeys shared].countryCode;
    self.returnURLTextField.text = [AirwallexExamplesKeys shared].returnUrl;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.apiKeyTextField) {
        [MockAPIClient sharedClient].apiKey = textField.text;
        [AirwallexExamplesKeys shared].apiKey = textField.text;
        [AirwallexExamplesKeys shared].customerId = nil;
        [[MockAPIClient sharedClient] createAuthenticationTokenWithCompletionHandler:nil];
    } else if (textField == self.clientIDTextField) {
        [MockAPIClient sharedClient].clientID = textField.text;
        [AirwallexExamplesKeys shared].clientId = textField.text;
        [AirwallexExamplesKeys shared].customerId = nil;
        [[MockAPIClient sharedClient] createAuthenticationTokenWithCompletionHandler:nil];
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
            [self showAlert:NSLocalizedString(@"Invalid currency", nil) withTitle:nil];
        }
    } else if (textField == self.countryCodeTextField) {
        if ([textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
            [AirwallexExamplesKeys shared].countryCode = textField.text.uppercaseString;
        } else {
            [self showAlert:NSLocalizedString(@"Invalid country code", nil) withTitle:nil];
        }
    } else if (textField == self.returnURLTextField) {
        NSURL *url = [NSURL URLWithString:textField.text];
        if (url.scheme && url.host) {
            [AirwallexExamplesKeys shared].returnUrl = textField.text;
        } else {
            [self showAlert:NSLocalizedString(@"Invalid return url", nil) withTitle:nil];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc {
    NSLog(@"Payment Base URL (Example): %@", [MockAPIClient sharedClient].paymentBaseURL.absoluteString);
    NSLog(@"API Key (Example): %@", [MockAPIClient sharedClient].apiKey);
    NSLog(@"Client ID (Example): %@", [MockAPIClient sharedClient].clientID);
    NSLog(@"Amount (Example): %@", [AirwallexExamplesKeys shared].amount);
    NSLog(@"Currency (Example): %@", [AirwallexExamplesKeys shared].currency);
    NSLog(@"Country Code (Example): %@", [AirwallexExamplesKeys shared].countryCode);
    NSLog(@"Return URL (Example): %@", [AirwallexExamplesKeys shared].returnUrl);
    NSLog(@"Force 3DS (Example): %@", [AirwallexExamplesKeys shared].force3DS ? @"Yes" : @"No");

    NSLog(@"Payment Base URL (SDK): %@", [Airwallex defaultBaseURL].absoluteString);
    NSLog(@"SDK mode (SDK): %@", FormatAirwallexSDKMode(Airwallex.mode));

    NSLog(@"Customer ID (SDK): %@", [AirwallexExamplesKeys shared].customerId);
    NSLog(@"Checkout mode (SDK): %@", self.checkoutModesList[[AirwallexExamplesKeys shared].checkoutMode]);
    NSLog(@"Next trigger by type (SDK): %@", self.nextTriggerByList[[AirwallexExamplesKeys shared].nextTriggerByType]);
    NSLog(@"Requires CVC (SDK): %@", [AirwallexExamplesKeys shared].requireCVC ? @"Yes" : @"No");
    NSLog(@"Auto Capture (SDK): %@", [AirwallexExamplesKeys shared].autoCapture ? @"Enabled" : @"Disabled");
}

@end
