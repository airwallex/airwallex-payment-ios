//
//  FlowWithoutUIViewController.m
//  Examples
//
//  Created by Tony He (CTR) on 2024/8/8.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "FlowWithoutUIViewController.h"
#import "APIClient.h"
#import "AWXCardProvider.h"
#import "AWXShippingViewController.h"
#import "AirwallexExamplesKeys.h"
#import "CardInfoView.h"
#import "InputViewController.h"
#import "OptionsViewController.h"
#import "PaymentMethodListView.h"
#import "Product.h"
#import "SavedCardView.h"
#import "UIViewController+Utils.h"
#import "WechatPayViewController.h"
#import <Airwallex/Airwallex-Swift.h>
#import <Airwallex/ApplePay.h>
#import <Airwallex/Core.h>
#import <SafariServices/SFSafariViewController.h>

typedef NS_ENUM(NSInteger, AirwallexFlowMode) {
    AirwallexFlowModeCardWithoutUI,
    AirwallexFlowModeCardAndSaveWithoutUI,
    AirwallexFlowModeCardWith3DS,
    AirwallexFlowModeApplepay,
    AirwallexFlowModeSavedCard,
    AirwallexFlowModePaymentMethods
};

@interface FlowWithoutUIViewController ()<AWXPaymentResultDelegate, AWXProviderDelegate, UITableViewDelegate, UITableViewDataSource, SavedCardViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UITableView *paymentModeTable;
@property (strong, nonatomic) NSArray<NSString *> *dataArray;
@property (assign, nonatomic) NSInteger selectedIndex;

@property (strong, nonatomic) UIScrollView *scroll;

@property (strong, nonatomic) UIButton *payWithCardDetailButton;
@property (strong, nonatomic) UIButton *payWithCardDetailAndSaveButton;
@property (strong, nonatomic) UIButton *payWithCardDetailWith3DS;
@property (strong, nonatomic) UIButton *applepayButton;
@property (strong, nonatomic) UIButton *paymentMethodsButton;
@property (strong, nonatomic) UIButton *savedCardButton;
@property (strong, nonatomic) CardInfoView *cardInfo;
@property (strong, nonatomic) PaymentMethodListView *paymentMethodList;
@property (strong, nonatomic) SavedCardView *savedCard;

@property (nonatomic) AirwallexCheckoutMode checkoutMode;
@property (strong, nonatomic) AWXPaymentIntent *paymentIntent;
@property (strong, nonatomic) AWXApplePayProvider *applePayProvider;
@property (nonatomic) AirwallexFlowMode flowMode;

@property (strong, nonatomic) AWXDefaultProvider *provider;
@property (strong, nonatomic) AWXSession *session;

@property (strong, nonatomic) AWXCard *editableCard;
@property (strong, nonatomic) AWXCard *fixedCard;

@property (nonatomic, strong, nonnull) AWXAPIClient *client;

@end

@implementation FlowWithoutUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.checkoutMode = AirwallexCheckoutOneOffMode;
    self.selectedIndex = 0;
    self.dataArray = @[@"One-off", @"Recurring", @"Recurring and Payment"];

    self.editableCard = [[AWXCard alloc] initWithNumber:@"4012000300000005" expiryMonth:@"12" expiryYear:@"2032" name:@"John Citizen" cvc:@"123" bin:nil last4:nil brand:nil country:nil funding:nil fingerprint:nil cvcCheck:nil avsCheck:nil numberType:nil];

    self.fixedCard = [[AWXCard alloc] initWithNumber:@"4012000300000088" expiryMonth:@"12" expiryYear:@"2032" name:@"John Citizen" cvc:@"123" bin:nil last4:nil brand:nil country:nil funding:nil fingerprint:nil cvcCheck:nil avsCheck:nil numberType:nil];

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
    [self.view addSubview:self.cardInfo];
    [self.view addSubview:self.paymentMethodList];
    [self.view addSubview:self.savedCard];

    [self.scroll addSubview:self.payWithCardDetailButton];
    [self.scroll addSubview:self.payWithCardDetailAndSaveButton];
    [self.scroll addSubview:self.payWithCardDetailWith3DS];
    [self.scroll addSubview:self.applepayButton];
    [self.scroll addSubview:self.paymentMethodsButton];
    [self.scroll addSubview:self.savedCardButton];

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

        [self.payWithCardDetailButton.leadingAnchor constraintEqualToAnchor:self.scroll.leadingAnchor
                                                                   constant:48],

        [self.payWithCardDetailButton.centerXAnchor constraintEqualToAnchor:self.scroll.centerXAnchor],
        [self.payWithCardDetailButton.widthAnchor constraintEqualToAnchor:self.scroll.widthAnchor
                                                                 constant:-96],
        [self.payWithCardDetailButton.heightAnchor constraintEqualToConstant:50.0],
        [self.payWithCardDetailButton.topAnchor constraintEqualToAnchor:self.scroll.topAnchor
                                                               constant:10],

        [self.payWithCardDetailAndSaveButton.centerXAnchor constraintEqualToAnchor:self.scroll.centerXAnchor],
        [self.payWithCardDetailAndSaveButton.widthAnchor constraintEqualToAnchor:self.scroll.widthAnchor
                                                                        constant:-96],
        [self.payWithCardDetailAndSaveButton.heightAnchor constraintEqualToConstant:50.0],
        [self.payWithCardDetailAndSaveButton.topAnchor constraintEqualToAnchor:self.payWithCardDetailButton.bottomAnchor
                                                                      constant:15.0],

        [self.payWithCardDetailWith3DS.centerXAnchor constraintEqualToAnchor:self.scroll.centerXAnchor],
        [self.payWithCardDetailWith3DS.widthAnchor constraintEqualToAnchor:self.scroll.widthAnchor
                                                                  constant:-96],
        [self.payWithCardDetailWith3DS.heightAnchor constraintEqualToConstant:50.0],
        [self.payWithCardDetailWith3DS.topAnchor constraintEqualToAnchor:self.payWithCardDetailAndSaveButton.bottomAnchor
                                                                constant:15.0],

        [self.applepayButton.centerXAnchor constraintEqualToAnchor:self.scroll.centerXAnchor],
        [self.applepayButton.widthAnchor constraintEqualToAnchor:self.scroll.widthAnchor
                                                        constant:-96],
        [self.applepayButton.heightAnchor constraintEqualToConstant:50.0],
        [self.applepayButton.topAnchor constraintEqualToAnchor:self.payWithCardDetailWith3DS.bottomAnchor
                                                      constant:15.0],

        [self.paymentMethodsButton.centerXAnchor constraintEqualToAnchor:self.scroll.centerXAnchor],
        [self.paymentMethodsButton.widthAnchor constraintEqualToAnchor:self.scroll.widthAnchor
                                                              constant:-96],
        [self.paymentMethodsButton.heightAnchor constraintEqualToConstant:50.0],
        [self.paymentMethodsButton.topAnchor constraintEqualToAnchor:self.applepayButton.bottomAnchor
                                                            constant:15.0],

        [self.savedCardButton.centerXAnchor constraintEqualToAnchor:self.scroll.centerXAnchor],
        [self.savedCardButton.widthAnchor constraintEqualToAnchor:self.scroll.widthAnchor
                                                         constant:-96],
        [self.savedCardButton.heightAnchor constraintEqualToConstant:50.0],
        [self.savedCardButton.topAnchor constraintEqualToAnchor:self.paymentMethodsButton.bottomAnchor
                                                       constant:15.0],
        [self.savedCardButton.bottomAnchor constraintEqualToAnchor:self.scroll.bottomAnchor
                                                          constant:-30.0],

        [self.cardInfo.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.cardInfo.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.cardInfo.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.cardInfo.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.paymentMethodList.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.paymentMethodList.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.paymentMethodList.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.paymentMethodList.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.savedCard.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.savedCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.savedCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.savedCard.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)setupExamplesAPIClient {
    APIClient *client = [APIClient sharedClient];
    client.apiKey = [AirwallexExamplesKeys shared].apiKey;
    client.clientID = [AirwallexExamplesKeys shared].clientId;

    self.client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
}

- (void)mainButtonTapped:(UIButton *)button {
    if (button == self.payWithCardDetailButton) {
        self.flowMode = AirwallexFlowModeCardWithoutUI;
    } else if (button == self.payWithCardDetailAndSaveButton) {
        self.flowMode = AirwallexFlowModeCardAndSaveWithoutUI;
    } else if (button == self.payWithCardDetailWith3DS) {
        self.flowMode = AirwallexFlowModeCardWith3DS;
    } else if (button == self.applepayButton) {
        self.flowMode = AirwallexFlowModeApplepay;
    } else if (button == self.paymentMethodsButton) {
        self.flowMode = AirwallexFlowModePaymentMethods;
    } else if (button == self.savedCardButton) {
        self.flowMode = AirwallexFlowModeSavedCard;
    }
    [self startAnimating];

    // Usually you should call your backend to get these info. You should not store api_key or client_id in your APP directly.
    [[APIClient sharedClient] createAuthenticationTokenWithCompletionHandler:^(NSError *_Nullable error) {
        if (error) {
            [self showAlert:error.localizedDescription withTitle:NSLocalizedString(@"Fail to request token.", nil)];
        } else {
            NSString *customerId = [[NSUserDefaults standardUserDefaults] stringForKey:kCachedCustomerID];
            NSLog(@"%@", customerId);
            [self createPaymentIntentWithCustomerId:customerId];
        }
    }];
}

- (void)getAvailablePaymentMethods {
    AWXGetPaymentMethodTypesRequest *request = [AWXGetPaymentMethodTypesRequest new];
    request.transactionCurrency = self.session.currency;
    request.transactionMode = self.session.transactionMode;
    request.countryCode = self.session.countryCode;
    request.lang = self.session.lang;
    request.pageNum = 0;
    request.pageSize = 20;
    [self.client send:request
              handler:^(AWXResponse *_Nullable response, NSError *_Nullable responseError) {
                  AWXGetPaymentMethodTypesResponse *result = (AWXGetPaymentMethodTypesResponse *)response;
                  [self.view bringSubviewToFront:self.paymentMethodList];
                  self.paymentMethodList.hidden = NO;
                  [self.paymentMethodList reloadWith:result.items];
              }];
}

- (void)getSavedCards {
    AWXGetPaymentConsentsRequest *request = [AWXGetPaymentConsentsRequest new];
    request.customerId = self.session.customerId;
    request.status = @"VERIFIED";
    request.nextTriggeredBy = FormatNextTriggerByType(AirwallexNextTriggerByCustomerType);
    request.pageNum = 0;
    request.pageSize = 20;
    [self.client send:request
              handler:^(AWXResponse *_Nullable response, NSError *_Nullable responseError) {
                  AWXGetPaymentConsentsResponse *result = (AWXGetPaymentConsentsResponse *)response;
                  [self.view bringSubviewToFront:self.savedCard];
                  self.savedCard.hidden = NO;
                  [self.savedCard reloadWith:result.items];
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

- (void)payTapped {
    self.cardInfo.hidden = YES;
    switch (self.flowMode) {
    case AirwallexFlowModeCardWithoutUI: {
        AWXCardProvider *provider = (AWXCardProvider *)self.provider;
        self.editableCard = self.cardInfo.card;
        [self startAnimating];
        [provider confirmPaymentIntentWithCard:self.editableCard billing:self.shipping saveCard:NO];
        break;
    }
    case AirwallexFlowModeCardAndSaveWithoutUI: {
        AWXCardProvider *provider = (AWXCardProvider *)self.provider;
        self.editableCard = self.cardInfo.card;
        [self startAnimating];
        [provider confirmPaymentIntentWithCard:self.editableCard billing:self.shipping saveCard:YES];
        break;
    }
    case AirwallexFlowModeCardWith3DS: {
        AWXCardProvider *provider = (AWXCardProvider *)self.provider;
        [self startAnimating];
        [provider confirmPaymentIntentWithCard:self.fixedCard billing:self.shipping saveCard:NO];
        break;
    }
    default:
        break;
    }
}

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
    case AirwallexFlowModeCardWithoutUI: {
        AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:self session:session];
        self.provider = provider;
        self.cardInfo.card = self.editableCard;
        self.cardInfo.isEditEnabled = YES;
        self.cardInfo.hidden = NO;
        [self.view bringSubviewToFront:self.cardInfo];
        break;
    }
    case AirwallexFlowModeCardAndSaveWithoutUI: {
        AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:self session:session];
        self.provider = provider;
        self.cardInfo.card = self.editableCard;
        self.cardInfo.isEditEnabled = YES;
        self.cardInfo.hidden = NO;
        [self.view bringSubviewToFront:self.cardInfo];
        break;
    }
    case AirwallexFlowModeCardWith3DS: {
        AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:self session:session];
        self.provider = provider;
        self.cardInfo.card = self.fixedCard;
        self.cardInfo.isEditEnabled = NO;
        self.cardInfo.hidden = NO;
        [self.view bringSubviewToFront:self.cardInfo];
        break;
    }
    case AirwallexFlowModeApplepay: {
        AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:self session:session];
        [provider startPayment];
        self.applePayProvider = provider;
        break;
    }
    case AirwallexFlowModePaymentMethods: {
        [self getAvailablePaymentMethods];
        break;
        ;
    }
    case AirwallexFlowModeSavedCard: {
        [self getSavedCards];
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

- (UIButton *)payWithCardDetailButton {
    if (!_payWithCardDetailButton) {
        _payWithCardDetailButton = [UIButton new];
        [_payWithCardDetailButton setTitle:@"pay with card detail" forState:UIControlStateNormal];
        _payWithCardDetailButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_payWithCardDetailButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_payWithCardDetailButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _payWithCardDetailButton.layer.cornerRadius = 8;
        _payWithCardDetailButton.layer.borderWidth = 1;
        _payWithCardDetailButton.layer.borderColor = UIColor.blackColor.CGColor;
        _payWithCardDetailButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _payWithCardDetailButton;
}

- (UIButton *)payWithCardDetailAndSaveButton {
    if (!_payWithCardDetailAndSaveButton) {
        _payWithCardDetailAndSaveButton = [UIButton new];
        [_payWithCardDetailAndSaveButton setTitle:@"pay with card detail and save" forState:UIControlStateNormal];
        _payWithCardDetailAndSaveButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_payWithCardDetailAndSaveButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_payWithCardDetailAndSaveButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateDisabled];
        [_payWithCardDetailAndSaveButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _payWithCardDetailAndSaveButton.layer.cornerRadius = 8;
        _payWithCardDetailAndSaveButton.layer.borderWidth = 1;
        _payWithCardDetailAndSaveButton.layer.borderColor = UIColor.blackColor.CGColor;
        _payWithCardDetailAndSaveButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _payWithCardDetailAndSaveButton;
}

- (UIButton *)payWithCardDetailWith3DS {
    if (!_payWithCardDetailWith3DS) {
        _payWithCardDetailWith3DS = [UIButton new];
        [_payWithCardDetailWith3DS setTitle:@"pay with card detail with 3DS" forState:UIControlStateNormal];
        _payWithCardDetailWith3DS.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_payWithCardDetailWith3DS setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_payWithCardDetailWith3DS setTitleColor:UIColor.lightGrayColor forState:UIControlStateDisabled];
        [_payWithCardDetailWith3DS addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _payWithCardDetailWith3DS.layer.cornerRadius = 8;
        _payWithCardDetailWith3DS.layer.borderWidth = 1;
        _payWithCardDetailWith3DS.layer.borderColor = UIColor.blackColor.CGColor;
        _payWithCardDetailWith3DS.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _payWithCardDetailWith3DS;
}

- (UIButton *)applepayButton {
    if (!_applepayButton) {
        _applepayButton = [UIButton new];
        [_applepayButton setTitle:@"Apple Pay" forState:UIControlStateNormal];
        _applepayButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_applepayButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_applepayButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateDisabled];
        [_applepayButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _applepayButton.layer.cornerRadius = 8;
        _applepayButton.layer.borderWidth = 1;
        _applepayButton.layer.borderColor = UIColor.blackColor.CGColor;
        _applepayButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _applepayButton;
}

- (UIButton *)paymentMethodsButton {
    if (!_paymentMethodsButton) {
        _paymentMethodsButton = [UIButton new];
        [_paymentMethodsButton setTitle:@"get payment methods" forState:UIControlStateNormal];
        _paymentMethodsButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_paymentMethodsButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_paymentMethodsButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateDisabled];
        [_paymentMethodsButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _paymentMethodsButton.layer.cornerRadius = 8;
        _paymentMethodsButton.layer.borderWidth = 1;
        _paymentMethodsButton.layer.borderColor = UIColor.blackColor.CGColor;
        _paymentMethodsButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _paymentMethodsButton;
}

- (UIButton *)savedCardButton {
    if (!_savedCardButton) {
        _savedCardButton = [UIButton new];
        [_savedCardButton setTitle:@"get saved cards" forState:UIControlStateNormal];
        _savedCardButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_savedCardButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_savedCardButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateDisabled];
        [_savedCardButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _savedCardButton.layer.cornerRadius = 8;
        _savedCardButton.layer.borderWidth = 1;
        _savedCardButton.layer.borderColor = UIColor.blackColor.CGColor;
        _savedCardButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _savedCardButton;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.hidden = YES;
    }
    return _activityIndicator;
}

- (CardInfoView *)cardInfo {
    if (!_cardInfo) {
        _cardInfo = [CardInfoView new];
        _cardInfo.translatesAutoresizingMaskIntoConstraints = NO;
        _cardInfo.hidden = YES;
        [_cardInfo.pay addTarget:self action:@selector(payTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cardInfo;
}

- (PaymentMethodListView *)paymentMethodList {
    if (!_paymentMethodList) {
        _paymentMethodList = [PaymentMethodListView new];
        _paymentMethodList.translatesAutoresizingMaskIntoConstraints = NO;
        _paymentMethodList.hidden = YES;
    }
    return _paymentMethodList;
}

- (SavedCardView *)savedCard {
    if (!_savedCard) {
        _savedCard = [SavedCardView new];
        _savedCard.translatesAutoresizingMaskIntoConstraints = NO;
        _savedCard.delegate = self;
        _savedCard.hidden = YES;
    }
    return _savedCard;
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
    [self stopAnimating];
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
    [self stopAnimating];
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
            [self.navigationController pushViewController:controller animated:YES];
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

    self.payWithCardDetailAndSaveButton.enabled = indexPath.row != 1;
    self.applepayButton.enabled = indexPath.row == 0;
}

#pragma mark - SavedCardViewDelegate

- (void)consentSelected:(AWXPaymentConsent *)consent {
    if ([consent.paymentMethod.card.numberType isEqualToString:@"PAN"]) {
        [self showPayment:consent];
    } else {
        AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:self session:self.session];
        [provider confirmPaymentIntentWithPaymentMethod:consent.paymentMethod paymentConsent:consent device:nil];
        self.provider = provider;
    }
}

- (void)showPayment:(AWXPaymentConsent *)paymentConsent {
    AWXPaymentViewController *controller = [[AWXPaymentViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = [AWXUIContext sharedContext].delegate;
    controller.session = self.session;
    controller.paymentConsent = paymentConsent;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
