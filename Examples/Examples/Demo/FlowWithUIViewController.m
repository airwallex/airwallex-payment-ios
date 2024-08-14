//
//  FlowWithUIViewController.m
//  Examples
//
//  Created by Tony He (CTR) on 2024/8/8.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "FlowWithUIViewController.h"
#import "APIClient.h"
#import "AirwallexExamplesKeys.h"
#import "OptionsViewController.h"
#import "UIViewController+Utils.h"
#import <Airwallex/Airwallex-Swift.h>
#import <Airwallex/ApplePay.h>

typedef NS_ENUM(NSInteger, AirwallexFlowMode) {
    AirwallexFlowModePresentEntire,
    AirwallexFlowModePushEntire,
    AirwallexFlowModePresentCustomEntire,
    AirwallexFlowModePushCustomEntire,
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
@property (strong, nonatomic) UIButton *presentCustomPaymentListButton;
@property (strong, nonatomic) UIButton *pushCustomPaymentListButton;
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
    [self.paymentModeTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.activityIndicator.center = self.view.center;
}

- (void)setupViews {
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settingTapped)];

    NSArray *views = @[
        self.paymentModeTable,
        self.scroll,
        self.activityIndicator
    ];
    for (UIView *view in views) {
        [self.view addSubview:view];
    }

    NSArray *buttons = @[
        self.presentPaymentListButton,
        self.pushPaymentListButton,
        self.presentCustomPaymentListButton,
        self.pushCustomPaymentListButton,
        self.presentCardPaymentButton,
        self.pushCardPaymentButton
    ];
    for (UIButton *button in buttons) {
        [self.scroll addSubview:button];
    }

    NSArray *constraints = @[
        [self.paymentModeTable.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor
                                                        constant:20],
        [self.paymentModeTable.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [self.paymentModeTable.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
        [self.paymentModeTable.heightAnchor constraintEqualToConstant:140],

        [self.scroll.topAnchor constraintEqualToAnchor:self.paymentModeTable.bottomAnchor
                                              constant:10.0],
        [self.scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scroll.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ];
    NSMutableArray *allConstraints = [NSMutableArray arrayWithArray:constraints];
    [allConstraints addObjectsFromArray:[self setupButtonConstraints:self.presentPaymentListButton topAnchor:self.scroll.topAnchor]];
    [allConstraints addObjectsFromArray:[self setupButtonConstraints:self.pushPaymentListButton topAnchor:self.presentPaymentListButton.bottomAnchor]];
    [allConstraints addObjectsFromArray:[self setupButtonConstraints:self.presentCustomPaymentListButton topAnchor:self.pushPaymentListButton.bottomAnchor]];
    [allConstraints addObjectsFromArray:[self setupButtonConstraints:self.pushCustomPaymentListButton topAnchor:self.presentCustomPaymentListButton.bottomAnchor]];
    [allConstraints addObjectsFromArray:[self setupButtonConstraints:self.presentCardPaymentButton topAnchor:self.pushCustomPaymentListButton.bottomAnchor]];
    [allConstraints addObjectsFromArray:[self setupButtonConstraints:self.pushCardPaymentButton topAnchor:self.presentCardPaymentButton.bottomAnchor]];
    [allConstraints addObject:[self.pushCardPaymentButton.bottomAnchor constraintEqualToAnchor:self.scroll.bottomAnchor constant:-30]];
    [NSLayoutConstraint activateConstraints:allConstraints];
}

- (NSArray<NSLayoutConstraint *> *)setupButtonConstraints:(UIButton *)button topAnchor:(NSLayoutYAxisAnchor *)topAnchor {
    return @[
        [button.leadingAnchor constraintEqualToAnchor:self.scroll.leadingAnchor
                                             constant:48],
        [button.trailingAnchor constraintEqualToAnchor:self.scroll.trailingAnchor
                                              constant:-48],
        [button.widthAnchor constraintEqualToAnchor:self.scroll.widthAnchor
                                           constant:-96],
        [button.topAnchor constraintEqualToAnchor:topAnchor
                                         constant:20],
        [button.heightAnchor constraintEqualToConstant:50]
    ];
}

- (void)setupExamplesAPIClient {
    [APIClient sharedClient].apiKey = [AirwallexExamplesKeys shared].apiKey;
    [APIClient sharedClient].clientID = [AirwallexExamplesKeys shared].clientId;
}

- (void)mainButtonTapped:(UIButton *)button {
    if (button == self.presentPaymentListButton) {
        self.flowMode = AirwallexFlowModePresentEntire;
    } else if (button == self.pushPaymentListButton) {
        self.flowMode = AirwallexFlowModePushEntire;
    } else if (button == self.presentCustomPaymentListButton) {
        self.flowMode = AirwallexFlowModePresentCustomEntire;
    } else if (button == self.pushCustomPaymentListButton) {
        self.flowMode = AirwallexFlowModePushCustomEntire;
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
    case AirwallexFlowModePresentCustomEntire:
        session.paymentMethods = @[@"PayPal", @"card", @"alipaycn"];
        [context presentEntirePaymentFlowFrom:self];
        break;
    case AirwallexFlowModePushCustomEntire:
        session.paymentMethods = @[@"PayPal", @"card", @"alipaycn"];
        [context pushEntirePaymentFlowFrom:self];
        break;
    case AirwallexFlowModePresentCard: {
        [context presentCardPaymentFlowFrom:self cardSchemes:@[AWXCardBrandVisa, AWXCardBrandMastercard, AWXCardBrandAmex, AWXCardBrandUnionPay, AWXCardBrandJCB]];
        break;
    }
    case AirwallexFlowModePushCard: {
        [context pushCardPaymentFlowFrom:self cardSchemes:@[AWXCardBrandVisa, AWXCardBrandMastercard, AWXCardBrandAmex, AWXCardBrandUnionPay, AWXCardBrandJCB]];
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

- (UIButton *)createButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton new];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 8;
    button.layer.borderWidth = 1;
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

- (UIButton *)presentPaymentListButton {
    if (!_presentPaymentListButton) {
        _presentPaymentListButton = [self createButtonWithTitle:@"present payment list" action:@selector(mainButtonTapped:)];
    }
    return _presentPaymentListButton;
}

- (UIButton *)pushPaymentListButton {
    if (!_pushPaymentListButton) {
        _pushPaymentListButton = [self createButtonWithTitle:@"push payment list" action:@selector(mainButtonTapped:)];
    }
    return _pushPaymentListButton;
}

- (UIButton *)presentCustomPaymentListButton {
    if (!_presentCustomPaymentListButton) {
        _presentCustomPaymentListButton = [self createButtonWithTitle:@"present custom payment list" action:@selector(mainButtonTapped:)];
    }
    return _presentCustomPaymentListButton;
}

- (UIButton *)pushCustomPaymentListButton {
    if (!_pushCustomPaymentListButton) {
        _pushCustomPaymentListButton = [self createButtonWithTitle:@"push custom payment list" action:@selector(mainButtonTapped:)];
    }
    return _pushCustomPaymentListButton;
}

- (UIButton *)presentCardPaymentButton {
    if (!_presentCardPaymentButton) {
        _presentCardPaymentButton = [self createButtonWithTitle:@"present card payment" action:@selector(mainButtonTapped:)];
    }
    return _presentCardPaymentButton;
}

- (UIButton *)pushCardPaymentButton {
    if (!_pushCardPaymentButton) {
        _pushCardPaymentButton = [self createButtonWithTitle:@"push card payment" action:@selector(mainButtonTapped:)];
    }
    return _pushCardPaymentButton;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        _activityIndicator.hidesWhenStopped = YES;
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
    [self showAlert:NSLocalizedString(@"Your payment has been charged", nil) withTitle:NSLocalizedString(@"Payment successful", nil)];
}

- (void)showPaymentFailure:(nullable NSError *)error {
    [self showAlert:error.localizedDescription ?: NSLocalizedString(@"There was an error while processing your payment. Please try again.", nil) withTitle:NSLocalizedString(@"Payment failed", nil)];
}

- (void)showPaymentCancel {
    [self showAlert:NSLocalizedString(@"Your payment has been cancelled", nil) withTitle:NSLocalizedString(@"Payment cancelled", nil)];
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
