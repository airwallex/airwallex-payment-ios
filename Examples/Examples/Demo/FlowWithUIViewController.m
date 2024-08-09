//
//  FlowWithUIViewController.m
//  Examples
//
//  Created by Tony He (CTR) on 2024/8/8.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "FlowWithUIViewController.h"
#import "APIClient.h"
#import "AWXCardProvider.h"
#import "AWXShippingViewController.h"
#import "AirwallexExamplesKeys.h"
#import "InputViewController.h"
#import "OptionsViewController.h"
#import "Product.h"
#import "UIViewController+Utils.h"
#import "WechatPayViewController.h"
#import <Airwallex/Airwallex-Swift.h>
#import <Airwallex/ApplePay.h>
#import <Airwallex/Core.h>
#import <SafariServices/SFSafariViewController.h>

typedef NS_ENUM(NSInteger, AirwallexFlowMode) {
    AirwallexFlowModePresentEntire,
    AirwallexFlowModePushEntire,
    AirwallexFlowModePresentCard,
    AirwallexFlowModePushCard
};

@interface FlowWithUIViewController ()<AWXPaymentResultDelegate, AWXProviderDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UITableView *paymentModeTable;
@property (strong, nonatomic) NSArray<NSString *> *dataArray;
@property (assign, nonatomic) NSInteger selectedIndex;

@property (strong, nonatomic) UIScrollView *scroll;

@property (strong, nonatomic) UIButton *presentPaymentListButton;
@property (strong, nonatomic) UIButton *pushPaymentListButton;
@property (strong, nonatomic) UIButton *presentCardPaymentButton;
@property (strong, nonatomic) UIButton *pushCardPaymentButton;

@property (nonatomic) AirwallexCheckoutMode checkoutMode;
@property (strong, nonatomic) AWXPaymentIntent *paymentIntent;
@property (strong, nonatomic) AWXApplePayProvider *applePayProvider;
@property (nonatomic) AirwallexFlowMode flowMode;

@property (strong, nonatomic) AWXDefaultProvider *provider;
@property (strong, nonatomic) AWXSession *session;

@end

@implementation FlowWithUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.checkoutMode = AirwallexCheckoutOneOffMode;
    self.selectedIndex = 0;
    self.dataArray = @[@"One-off", @"Recurring", @"Recurring and Payment"];

    [self setupViews];
    [self setupExamplesAPIClient];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSIndexPath *defaultIndexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
    [self.paymentModeTable selectRowAtIndexPath:defaultIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    UITableViewCell *defaultCell = [self.paymentModeTable cellForRowAtIndexPath:defaultIndexPath];
    defaultCell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.activityIndicator.center = self.view.center;
}

- (void)setupViews {
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settingTapped)];

    [self.view addSubview:self.paymentModeTable];
    [self.view addSubview:self.scroll];
    [self.view addSubview:self.activityIndicator];

    [self.scroll addSubview:self.presentPaymentListButton];
    [self.scroll addSubview:self.pushPaymentListButton];
    [self.scroll addSubview:self.presentCardPaymentButton];
    [self.scroll addSubview:self.pushCardPaymentButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.paymentModeTable.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor
                                                        constant:20],
        [self.paymentModeTable.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [self.paymentModeTable.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
        [self.paymentModeTable.heightAnchor constraintEqualToConstant:140],

        [self.scroll.topAnchor constraintEqualToAnchor:self.paymentModeTable.bottomAnchor
                                              constant:10.0],
        [self.scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scroll.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],

        [self.presentPaymentListButton.leadingAnchor constraintEqualToAnchor:self.scroll.leadingAnchor
                                                                    constant:48],
        [self.presentPaymentListButton.trailingAnchor constraintEqualToAnchor:self.scroll.trailingAnchor
                                                                     constant:-48],
        [self.presentPaymentListButton.widthAnchor constraintEqualToAnchor:self.scroll.widthAnchor
                                                                  constant:-96],
        [self.presentPaymentListButton.topAnchor constraintEqualToAnchor:self.scroll.topAnchor
                                                                constant:10],
        [self.presentPaymentListButton.heightAnchor constraintEqualToConstant:50.0],

        [self.pushPaymentListButton.leadingAnchor constraintEqualToAnchor:self.scroll.leadingAnchor
                                                                 constant:48],
        [self.pushPaymentListButton.trailingAnchor constraintEqualToAnchor:self.scroll.trailingAnchor
                                                                  constant:-48],
        [self.pushPaymentListButton.topAnchor constraintEqualToAnchor:self.presentPaymentListButton.bottomAnchor
                                                             constant:20],
        [self.pushPaymentListButton.heightAnchor constraintEqualToConstant:50.0],

        [self.presentCardPaymentButton.centerXAnchor constraintEqualToAnchor:self.scroll.centerXAnchor],
        [self.presentCardPaymentButton.widthAnchor constraintEqualToAnchor:self.scroll.widthAnchor
                                                                  constant:-96],
        [self.presentCardPaymentButton.topAnchor constraintEqualToAnchor:self.pushPaymentListButton.bottomAnchor
                                                                constant:20.0],
        [self.presentCardPaymentButton.heightAnchor constraintEqualToConstant:50.0],

        [self.pushCardPaymentButton.centerXAnchor constraintEqualToAnchor:self.scroll.centerXAnchor],
        [self.pushCardPaymentButton.widthAnchor constraintEqualToAnchor:self.scroll.widthAnchor
                                                               constant:-96],
        [self.pushCardPaymentButton.topAnchor constraintEqualToAnchor:self.presentCardPaymentButton.bottomAnchor
                                                             constant:20.0],
        [self.pushCardPaymentButton.heightAnchor constraintEqualToConstant:50.0],
        [self.pushCardPaymentButton.bottomAnchor constraintEqualToAnchor:self.scroll.bottomAnchor
                                                                constant:-30.0]
    ]];
}

- (void)setupExamplesAPIClient {
    APIClient *client = [APIClient sharedClient];
    client.apiKey = [AirwallexExamplesKeys shared].apiKey;
    client.clientID = [AirwallexExamplesKeys shared].clientId;
}

- (void)mainButtonTapped:(UIButton *)button {
    if (button == self.presentPaymentListButton) {
        self.flowMode = AirwallexFlowModePresentEntire;
    } else if (button == self.pushPaymentListButton) {
        self.flowMode = AirwallexFlowModePushEntire;
    } else if (button == self.presentCardPaymentButton) {
        self.flowMode = AirwallexFlowModePresentCard;
    } else if (button == self.pushCardPaymentButton) {
        self.flowMode = AirwallexFlowModePushCard;
    }

    [self startAnimating];
    // Usually you should call your backend to get these info. You should not store api_key or client_id in your APP directly.
    [[APIClient sharedClient] createAuthenticationTokenWithCompletionHandler:^(NSError *_Nullable error) {
        if (error) {
            [self showAlert:error.localizedDescription withTitle:NSLocalizedString(@"Fail to request token.", nil)];
            [self stopAnimating];
        } else {
            NSString *customerId = [[NSUserDefaults standardUserDefaults] stringForKey:kCachedCustomerID];
            NSLog(@"%@", customerId);
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

    if (self.checkoutMode != AirwallexCheckoutRecurringMode) {
        dispatch_group_enter(group);
        [[APIClient sharedClient] createPaymentIntentWithParameters:parameters
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

    if (customerId && self.checkoutMode == AirwallexCheckoutRecurringMode) {
        dispatch_group_enter(group);
        [[APIClient sharedClient] generateClientSecretWithCustomerId:customerId
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
        // This is only for example. You should call your backend to get payment intent.
        if (_paymentIntent) {
            [AWXAPIClientConfiguration sharedConfiguration].clientSecret = _paymentIntent.clientSecret;
        } else if (_customerSecret) {
            [AWXAPIClientConfiguration sharedConfiguration].clientSecret = _customerSecret;
        }
        [strongSelf showEntirePaymentFlowWithPaymentIntent:_paymentIntent];
    });
}

#pragma mark - Show Payment Method List

- (void)showEntirePaymentFlowWithPaymentIntent:(nullable AWXPaymentIntent *)paymentIntent {
    self.paymentIntent = paymentIntent;
    // Step 3: Create session
    AWXSession *session = [self createSession:paymentIntent];

    // Step 4: Present payment flow
    AWXUIContext *context = [AWXUIContext sharedContext];

    context.delegate = self;
    context.session = session;
    self.session = session;
    switch (self.flowMode) {
    case AirwallexFlowModePresentEntire:
        [context presentEntirePaymentFlowFrom:self];
        break;
    case AirwallexFlowModePushEntire:
        [context pushEntirePaymentFlowFrom:self];
        break;
    case AirwallexFlowModePresentCard: {
        NSArray *cardSchemes = @[@(AWXBrandTypeVisa), @(AWXBrandTypeMastercard), @(AWXBrandTypeAmex), @(AWXBrandTypeUnionPay), @(AWXBrandTypeJCB)];
        [context presentCardPaymentFlowFrom:self cardSchemes:cardSchemes];
        break;
    }
    case AirwallexFlowModePushCard: {
        NSArray *cardSchemes = @[@(AWXBrandTypeVisa), @(AWXBrandTypeMastercard), @(AWXBrandTypeAmex), @(AWXBrandTypeUnionPay), @(AWXBrandTypeJCB)];
        [context pushCardPaymentFlowFrom:self cardSchemes:cardSchemes];
        break;
    }
    default:
        break;
    }
}

- (void)settingTapped {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OptionsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"OptionsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableView *)paymentModeTable {
    if (!_paymentModeTable) {
        _paymentModeTable = [UITableView new];
        [_paymentModeTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PaymentModeTableCell"];
        _paymentModeTable.dataSource = self;
        _paymentModeTable.delegate = self;
        _paymentModeTable.bounces = NO;
        _paymentModeTable.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _paymentModeTable;
}

- (UIScrollView *)scroll {
    if (!_scroll) {
        _scroll = [UIScrollView new];
        _scroll.showsVerticalScrollIndicator = NO;
        _scroll.translatesAutoresizingMaskIntoConstraints = NO;
        _scroll.bounces = NO;
    }
    return _scroll;
}

- (UIButton *)presentPaymentListButton {
    if (!_presentPaymentListButton) {
        _presentPaymentListButton = [UIButton new];
        [_presentPaymentListButton setTitle:@"present payment list" forState:UIControlStateNormal];
        _presentPaymentListButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_presentPaymentListButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_presentPaymentListButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _presentPaymentListButton.layer.cornerRadius = 8;
        _presentPaymentListButton.layer.borderWidth = 1;
        _presentPaymentListButton.layer.borderColor = UIColor.blackColor.CGColor;
        _presentPaymentListButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _presentPaymentListButton;
}

- (UIButton *)pushPaymentListButton {
    if (!_pushPaymentListButton) {
        _pushPaymentListButton = [UIButton new];
        [_pushPaymentListButton setTitle:@"push payment list" forState:UIControlStateNormal];
        _pushPaymentListButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_pushPaymentListButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_pushPaymentListButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _pushPaymentListButton.layer.cornerRadius = 8;
        _pushPaymentListButton.layer.borderWidth = 1;
        _pushPaymentListButton.layer.borderColor = UIColor.blackColor.CGColor;
        _pushPaymentListButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _pushPaymentListButton;
}

- (UIButton *)presentCardPaymentButton {
    if (!_presentCardPaymentButton) {
        _presentCardPaymentButton = [UIButton new];
        [_presentCardPaymentButton setTitle:@"present card payment" forState:UIControlStateNormal];
        _presentCardPaymentButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_presentCardPaymentButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_presentCardPaymentButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _presentCardPaymentButton.layer.cornerRadius = 8;
        _presentCardPaymentButton.layer.borderWidth = 1;
        _presentCardPaymentButton.layer.borderColor = UIColor.blackColor.CGColor;
        _presentCardPaymentButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _presentCardPaymentButton;
}

- (UIButton *)pushCardPaymentButton {
    if (!_pushCardPaymentButton) {
        _pushCardPaymentButton = [UIButton new];
        [_pushCardPaymentButton setTitle:@"push card payment" forState:UIControlStateNormal];
        _pushCardPaymentButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_pushCardPaymentButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_pushCardPaymentButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _pushCardPaymentButton.layer.cornerRadius = 8;
        _pushCardPaymentButton.layer.borderWidth = 1;
        _pushCardPaymentButton.layer.borderColor = UIColor.blackColor.CGColor;
        _pushCardPaymentButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _pushCardPaymentButton;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.hidden = YES;
    }
    return _activityIndicator;
}

- (void)startAnimating {
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
}

- (void)stopAnimating {
    [self.activityIndicator stopAnimating];
    self.view.userInteractionEnabled = YES;
}

#pragma mark - Create session

- (AWXSession *)createSession:(nullable AWXPaymentIntent *)paymentIntent {
    switch (self.checkoutMode) {
    case AirwallexCheckoutOneOffMode: {
        AWXOneOffSession *session = [AWXOneOffSession new];

        AWXApplePayOptions *options = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchant.com.airwallex.paymentacceptance"];

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

        // you can configure the payment method list manually.(But only available ones will be displayed)
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

        // you can configure the payment method list manually.(But only available ones will be displayed)
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

        // you can configure the payment method list manually.(But only available ones will be displayed)
        //        session.paymentMethods = @[@"card"];

        return session;
    }
    }
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

#pragma mark - AWXPaymentResultDelegate

- (void)paymentViewController:(UIViewController *)controller didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error {
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

- (void)provider:(AWXDefaultProvider *)provider shouldHandleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    Class class = ClassToHandleNextActionForType(nextAction);
    if (class == nil) {
        [self showAlert:NSLocalizedString(@"No provider matched the next action.", nil)];
        return;
    }

    AWXDefaultActionProvider *actionProvider = [[class alloc] initWithDelegate:self session:self.session];
    [actionProvider handleNextAction:nextAction];
    self.provider = actionProvider;
}

- (void)provider:(AWXDefaultProvider *)provider shouldPresentViewController:(nullable UIViewController *)controller forceToDismiss:(BOOL)forceToDismiss withAnimation:(BOOL)withAnimation {
    if (controller) {
        if ([controller isKindOfClass:UINavigationController.class]) {
            [self presentViewController:controller animated:withAnimation completion:nil];
        } else {
            [self.navigationController pushViewController:controller animated:withAnimation];
            //        [self presentViewController:controller animated:withAnimation completion:nil];
        }
    }
}

- (void)provider:(AWXDefaultProvider *)provider shouldInsertViewController:(UIViewController *)controller {
    [self addChildViewController:controller];
    controller.view.frame = CGRectInset(self.view.frame, 0, CGRectGetMaxY(self.view.bounds));
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

- (void)showAlert:(NSString *)message {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentModeTableCell" forIndexPath:indexPath];

    cell.textLabel.text = self.dataArray[indexPath.row];

    cell.accessoryType = (indexPath.row == self.selectedIndex) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
    UITableViewCell *previousCell = [tableView cellForRowAtIndexPath:previousIndexPath];
    previousCell.accessoryType = UITableViewCellAccessoryNone;

    self.selectedIndex = indexPath.row;
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;

    self.checkoutMode = (AirwallexCheckoutMode)indexPath.row;
}

@end
