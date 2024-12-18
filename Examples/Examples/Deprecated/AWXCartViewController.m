//
//  CartViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXCartViewController.h"
#import "AirwallexExamplesKeys.h"
#import "MockAPIClient.h"
#import "ProductCell.h"
#import "ShippingCell.h"
#import "TotalCell.h"
#import "UIViewController+Utils.h"
#import <Airwallex/AWXUIContext+Card.h>
#import <Airwallex/Airwallex-Swift.h>
#import <Airwallex/ApplePay.h>
#import <Airwallex/Core.h>
#import <SafariServices/SFSafariViewController.h>

@interface AWXCartViewController ()<UITableViewDelegate, UITableViewDataSource, AWXShippingViewControllerDelegate, AWXPaymentResultDelegate, AWXProviderDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) AWXPlaceDetails *shipping;
@property (strong, nonatomic) AWXPaymentIntent *paymentIntent;
@property (strong, nonatomic) AWXApplePayProvider *applePayProvider;

@end

@implementation AWXCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self setupCartData];
    [self setupSDK];
    [self setupExamplesAPIClient];
}

- (void)setupViews {
    self.view.backgroundColor = [AWXTheme sharedTheme].primaryBackgroundColor;
    self.titleLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.hidden = YES;
    [self.view addSubview:self.activityIndicator];
}

- (void)setupCartData {
    Product *product0 = [[Product alloc] initWithName:@"AirPods Pro"
                                               detail:@"Free engraving x 1"
                                                price:[NSDecimalNumber decimalNumberWithString:@"399"]];
    Product *product1 = [[Product alloc] initWithName:@"HomePod"
                                               detail:@"White x 1"
                                                price:[NSDecimalNumber decimalNumberWithString:@"469"]];
    self.products = [@[product0, product1] mutableCopy];

    NSDictionary *shipping = @{
        @"first_name": @"Jason",
        @"last_name": @"Wang",
        @"phone_number": @"13800000000",
        @"address": @{
            @"country_code": @"CN",
            @"state": @"Shanghai",
            @"city": @"Shanghai",
            @"street": @"Pudong District",
            @"postcode": @"100000"
        }
    };
    self.shipping = [AWXPlaceDetails decodeFromJSON:shipping];
}

- (void)setupExamplesAPIClient {
    MockAPIClient *client = [MockAPIClient sharedClient];
    client.apiKey = [AirwallexExamplesKeys shared].apiKey;
    client.clientID = [AirwallexExamplesKeys shared].clientId;
}

- (void)setupSDK {
    // Step 1: Use a preset mode (Note: test mode as default)
    //    [Airwallex setMode:AirwallexSDKTestMode];
    // Or set base URL directly
    AirwallexSDKMode mode = [AirwallexExamplesKeys shared].environment;
    [Airwallex setMode:mode];

    // You can disable sending Analytics data or printing local logs
    //    [Airwallex disableAnalytics];

    // you can enable local log file
    //    [Airwallex enableLocalLogFile];

    // Theme customization
    //    UIColor *tintColor = [UIColor systemPinkColor];
    //    [AWXTheme sharedTheme].tintColor = tintColor;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.activityIndicator.center = self.view.center;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData {
    NSString *amount = [AirwallexExamplesKeys shared].amount;
    NSString *currency = [AirwallexExamplesKeys shared].currency;
    NSString *countryCode = [AirwallexExamplesKeys shared].countryCode;
    NSString *returnUrl = [AirwallexExamplesKeys shared].returnUrl;

    self.checkoutButton.enabled = self.shipping != nil && amount.doubleValue > 0 && currency.length > 0 && countryCode.length > 0 && returnUrl.length > 0;

    NSString *checkoutTitle = @"Checkout";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kCachedApplePayMethodOnly]) {
        checkoutTitle = @"Pay";
    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:kCachedCardMethodOnly]) {
        checkoutTitle = @"Pay by card";
    }
    [self.checkoutButton setTitle:checkoutTitle forState:UIControlStateNormal];
    [self.tableView reloadData];
}

- (void)startAnimating {
    [self.activityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
}

- (void)stopAnimating {
    [self.activityIndicator stopAnimating];
    self.view.userInteractionEnabled = YES;
}

#pragma mark - Menu

- (IBAction)menuPressed:(UIBarButtonItem *)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [controller addAction:[UIAlertAction actionWithTitle:@"WeChat Demo"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *_Nonnull action) {
                                                     [self performSegueWithIdentifier:@"showWeChatDemo" sender:nil];
                                                 }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"H5 Demo"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *_Nonnull action) {
                                                     [self performSegueWithIdentifier:@"showH5Demo" sender:nil];
                                                 }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Settings"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *_Nonnull action) {
                                                     [self performSegueWithIdentifier:@"showSettings" sender:nil];
                                                 }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    UIPopoverPresentationController *popPresenter = [controller popoverPresentationController];
    popPresenter.barButtonItem = sender;

    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Check Out

- (IBAction)checkoutPressed:(id)sender {
    if (self.products.count == 0) {
        [self showAlert:NSLocalizedString(@"No products in your cart", nil) withTitle:nil];
        return;
    }

    [self startAnimating];
    [[MockAPIClient sharedClient] createAuthenticationTokenWithCompletionHandler:^(NSError *_Nullable error) {
        if (error) {
            [self showAlert:error.localizedDescription withTitle:NSLocalizedString(@"Fail to request token.", nil)];
            [self stopAnimating];
        } else {
            NSString *customerId = [[NSUserDefaults standardUserDefaults] stringForKey:kCachedCustomerID];
            [self createPaymentIntentWithCustomerId:customerId];
        }
    }];
}

#pragma mark - Create Payment Intent

- (void)createPaymentIntentWithCustomerId:(nullable NSString *)customerId {
    __weak __typeof(self) weakSelf = self;
    dispatch_group_t group = dispatch_group_create();
    __block NSError *_error;
    __block AWXPaymentIntent *_paymentIntent;
    __block NSString *_customerSecret;

    NSMutableDictionary *parameters = [@{@"amount": [AirwallexExamplesKeys shared].amount,
                                         @"currency": [AirwallexExamplesKeys shared].currency,
                                         @"merchant_order_id": NSUUID.UUID.UUIDString,
                                         @"request_id": NSUUID.UUID.UUIDString,
                                         @"metadata": @{@"id": @1},
                                         @"return_url": [AirwallexExamplesKeys shared].returnUrl,
                                         @"order": @{
                                             @"products": @[@{
                                                                @"type": @"Free engraving",
                                                                @"code": @"123",
                                                                @"name": @"AirPods Pro",
                                                                @"sku": @"piece",
                                                                @"quantity": @1,
                                                                @"unit_price": @399.0,
                                                                @"desc": @"Buy AirPods Pro, per month with trade-in",
                                                                @"url": @"www.aircross.com"
                                                            },
                                                            @{
                                                                @"type": @"White",
                                                                @"code": @"123",
                                                                @"name": @"HomePod",
                                                                @"sku": @"piece",
                                                                @"quantity": @1,
                                                                @"unit_price": @469.0,
                                                                @"desc": @"Buy HomePod, per month with trade-in",
                                                                @"url": @"www.aircross.com"
                                                            }],
                                             @"shipping": @{
                                                 @"first_name": @"Jason",
                                                 @"last_name": @"Wang",
                                                 @"phone_number": @"13800000000",
                                                 @"address": @{
                                                     @"country_code": @"CN",
                                                     @"state": @"Shanghai",
                                                     @"city": @"Shanghai",
                                                     @"street": @"Pudong District",
                                                     @"postcode": @"100000"
                                                 }
                                             },
                                             @"type": @"physical_goods"
                                         }} mutableCopy];
    if (customerId) {
        parameters[@"customer_id"] = customerId;
    }
    if ([AirwallexExamplesKeys shared].force3DS) {
        parameters[@"payment_method_options"] = @{@"card": @{@"three_ds_action": @"FORCE_3DS"}};
    }

    AirwallexCheckoutMode checkoutMode = [[NSUserDefaults standardUserDefaults] integerForKey:kCachedCheckoutMode];
    if (checkoutMode != AirwallexCheckoutRecurringMode) {
        dispatch_group_enter(group);
        [[MockAPIClient sharedClient] createPaymentIntentWithParameters:parameters
                                                      completionHandler:^(AWXPaymentIntent *_Nullable paymentIntent, NSError *_Nullable error) {
                                                          if (error) {
                                                              _error = error;
                                                              dispatch_group_leave(group);
                                                              return;
                                                          }

                                                          _paymentIntent = paymentIntent;
                                                          dispatch_group_leave(group);
                                                      }];
    }

    if (customerId && checkoutMode == AirwallexCheckoutRecurringMode) {
        dispatch_group_enter(group);
        [[MockAPIClient sharedClient] generateClientSecretWithCustomerId:customerId
                                                       completionHandler:^(NSDictionary *_Nullable result, NSError *_Nullable error) {
                                                           if (error) {
                                                               _error = error;
                                                               dispatch_group_leave(group);
                                                               return;
                                                           }

                                                           _customerSecret = result[@"client_secret"];
                                                           dispatch_group_leave(group);
                                                       }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf stopAnimating];

        if (_error) {
            [strongSelf showAlert:_error.localizedDescription withTitle:nil];
            return;
        }

        // Step 2: Setup client secret from payment intent or setup client secret generated with customer id
        if (_paymentIntent) {
            [AWXAPIClientConfiguration sharedConfiguration].clientSecret = _paymentIntent.clientSecret;
        } else if (_customerSecret) {
            [AWXAPIClientConfiguration sharedConfiguration].clientSecret = _customerSecret;
        }

        if ([[NSUserDefaults standardUserDefaults] boolForKey:kCachedApplePayMethodOnly]) {
            [strongSelf initiateApplePaymentFlowWithPaymentIntent:_paymentIntent];
        } else {
            [strongSelf showPaymentFlowWithPaymentIntent:_paymentIntent];
        }
    });
}

#pragma mark - Create session

- (AWXSession *)createSession:(nullable AWXPaymentIntent *)paymentIntent {
    AirwallexCheckoutMode checkoutMode = [[NSUserDefaults standardUserDefaults] integerForKey:kCachedCheckoutMode];
    switch (checkoutMode) {
    case AirwallexCheckoutOneOffMode: {
        AWXOneOffSession *session = [AWXOneOffSession new];

        AWXApplePayOptions *options = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:[self applePayMerchantId]];

        options.additionalPaymentSummaryItems = @[
            [PKPaymentSummaryItem summaryItemWithLabel:@"goods"
                                                amount:[NSDecimalNumber decimalNumberWithString:@"2"]],
            [PKPaymentSummaryItem summaryItemWithLabel:@"tax"
                                                amount:[NSDecimalNumber decimalNumberWithString:@"1"]]
        ];
        options.requiredBillingContactFields = [NSSet setWithObjects:PKContactFieldPostalAddress, nil];
        options.totalPriceLabel = @"COMPANY, INC.";

        session.applePayOptions = options;

        session.countryCode = [AirwallexExamplesKeys shared].countryCode;
        session.billing = self.shipping;
        session.returnURL = [AirwallexExamplesKeys shared].returnUrl;
        session.paymentIntent = paymentIntent;
        session.autoCapture = [[NSUserDefaults standardUserDefaults] boolForKey:kCachedAutoCapture];

        //        // you can configure the payment method list manually.(But only available ones will be displayed)
        //        session.paymentMethods = @[@"card"];
        //        session.hidePaymentConsents = YES;

        return session;
    }
    case AirwallexCheckoutRecurringMode: {
        AWXRecurringSession *session = [AWXRecurringSession new];
        session.countryCode = [AirwallexExamplesKeys shared].countryCode;
        session.billing = self.shipping;
        session.returnURL = [AirwallexExamplesKeys shared].returnUrl;
        session.currency = [AirwallexExamplesKeys shared].currency;
        session.amount = [NSDecimalNumber decimalNumberWithString:[AirwallexExamplesKeys shared].amount];
        session.customerId = [[NSUserDefaults standardUserDefaults] stringForKey:kCachedCustomerID];
        session.nextTriggerByType = [[NSUserDefaults standardUserDefaults] integerForKey:kCachedNextTriggerBy];
        session.requiresCVC = [[NSUserDefaults standardUserDefaults] boolForKey:kCachedRequiresCVC];
        session.merchantTriggerReason = AirwallexMerchantTriggerReasonUnscheduled;

        //        // you can configure the payment method list manually.(But only available ones will be displayed)
        //        session.paymentMethods = @[@"card"];

        return session;
    }
    case AirwallexCheckoutRecurringWithIntentMode: {
        AWXRecurringWithIntentSession *session = [AWXRecurringWithIntentSession new];
        session.countryCode = [AirwallexExamplesKeys shared].countryCode;
        session.billing = self.shipping;
        session.returnURL = [AirwallexExamplesKeys shared].returnUrl;
        session.paymentIntent = paymentIntent;
        session.nextTriggerByType = [[NSUserDefaults standardUserDefaults] integerForKey:kCachedNextTriggerBy];
        session.requiresCVC = [[NSUserDefaults standardUserDefaults] boolForKey:kCachedRequiresCVC];
        session.autoCapture = [[NSUserDefaults standardUserDefaults] boolForKey:kCachedAutoCapture];
        session.merchantTriggerReason = AirwallexMerchantTriggerReasonScheduled;

        //        // you can configure the payment method list manually.(But only available ones will be displayed)
        //        session.paymentMethods = @[@"card"];

        return session;
    }
    }
}

- (NSString *)applePayMerchantId {
    switch ([AirwallexExamplesKeys shared].environment) {
    case AirwallexSDKStagingMode:
        return nil;
    case AirwallexSDKDemoMode:
        return @"merchant.demo.com.airwallex.paymentacceptance";
    case AirwallexSDKProductionMode:
        return @"merchant.com.airwallex.paymentacceptance";
    }
}

#pragma mark - Show Payment Method List

- (void)showPaymentFlowWithPaymentIntent:(nullable AWXPaymentIntent *)paymentIntent {
    self.paymentIntent = paymentIntent;
    // Step 3: Create session
    AWXSession *session = [self createSession:paymentIntent];

    // Step 4: Present payment flow
    AWXUIContext *context = [AWXUIContext sharedContext];
    context.delegate = self;
    context.session = session;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kCachedCardMethodOnly]) {
        [context presentCardPaymentFlowFrom:self];
    } else {
        [context presentEntirePaymentFlowFrom:self];
    }
}

#pragma mark - Initiate Apple Pay Flow
- (void)initiateApplePaymentFlowWithPaymentIntent:(nullable AWXPaymentIntent *)paymentIntent {
    self.paymentIntent = paymentIntent;
    // Step 3: Create session
    AWXSession *session = [self createSession:paymentIntent];

    // Step 4: Present payment flow
    AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:self session:session];
    [provider startPayment];
    _applePayProvider = provider;
}

#pragma mark - Show Payment Result

- (void)showPaymentSuccess {
    NSString *title = NSLocalizedString(@"Payment successful", nil);
    NSString *message = NSLocalizedString(@"Your payment has been charged", nil);
    [self showAlert:message withTitle:title];
}

- (void)showPaymentFailure:(nullable NSError *)error {
    NSString *title = NSLocalizedString(@"Payment failed", nil);
    NSString *message = error.localizedDescription ?: NSLocalizedString(@"There was an error while processing your payment. Please try again.", nil);
    [self showAlert:message withTitle:title];
}

- (void)showPaymentCancel {
    NSString *title = NSLocalizedString(@"Payment cancelled", nil);
    NSString *message = NSLocalizedString(@"Your payment has been cancelled", nil);
    [self showAlert:message withTitle:title];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.products.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 9;
    }
    return 24;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ShippingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShippingCell" forIndexPath:indexPath];
        cell.shipping = self.shipping;
        return cell;
    }

    if (self.products.count == indexPath.row) {
        TotalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TotalCell" forIndexPath:indexPath];
        NSDecimalNumber *subtotal = [self.products valueForKeyPath:@"@sum.self.price"];
        NSDecimalNumber *shipping = [NSDecimalNumber zero];
        cell.subtotal = subtotal;
        cell.shipping = shipping;
        cell.total = [subtotal decimalNumberByAdding:shipping];
        return cell;
    }

    ProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell" forIndexPath:indexPath];
    cell.product = self.products[indexPath.row];
    __weak __typeof(self) weakSelf = self;
    cell.handler = ^(Product *product) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.products removeObject:product];
        [strongSelf reloadData];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        AWXShippingViewController *controller = [[AWXShippingViewController alloc] initWithNibName:nil bundle:nil];
        controller.delegate = self;
        controller.shipping = self.shipping;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - AWXShippingViewControllerDelegate

- (void)shippingViewController:(AWXShippingViewController *)controller didEditShipping:(AWXPlaceDetails *)shipping {
    [controller.navigationController popViewControllerAnimated:YES];
    self.shipping = shipping;
    [self reloadData];
}

#pragma mark - AWXPaymentResultDelegate

- (void)paymentViewController:(UIViewController *)controller didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error {
    [controller dismissViewControllerAnimated:YES
                                   completion:^{
                                       switch (status) {
                                       case AirwallexPaymentStatusSuccess:
                                           [self showPaymentSuccess];
                                           break;
                                       case AirwallexPaymentStatusFailure:
                                           [self showPaymentFailure:error];
                                           break;
                                       case AirwallexPaymentStatusCancel:
                                           [self showPaymentCancel];
                                           break;
                                       default:
                                           break;
                                       }
                                   }];
}

- (void)paymentViewController:(UIViewController *)controller didCompleteWithPaymentConsentId:(NSString *)Id {
    NSLog(@"didGetPaymentConsentId: %@", Id);
}

#pragma mark - AWXProviderDelegate

- (void)provider:(nonnull AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error {
    switch (status) {
    case AirwallexPaymentStatusSuccess:
        [self showPaymentSuccess];
        break;
    case AirwallexPaymentStatusFailure:
        [self showPaymentFailure:error];
        break;
    case AirwallexPaymentStatusCancel:
        [self showPaymentCancel];
        break;
    case AirwallexPaymentStatusInProgress:
        NSLog(@"Payment in progress");
        break;
    }
}

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithPaymentConsentId:(NSString *)Id {
    NSLog(@"didGetPaymentConsentId: %@", Id);
}

- (void)provider:(nonnull AWXDefaultProvider *)provider didInitializePaymentIntentId:(nonnull NSString *)paymentIntentId {
    NSLog(@"didInitializePaymentIntentId: %@", paymentIntentId);
}

- (void)providerDidEndRequest:(nonnull AWXDefaultProvider *)provider {
    NSLog(@"providerDidEndRequest");
}

- (void)providerDidStartRequest:(nonnull AWXDefaultProvider *)provider {
    NSLog(@"providerDidStartRequest");
}

@end
