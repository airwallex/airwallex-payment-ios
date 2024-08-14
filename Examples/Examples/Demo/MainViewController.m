//
//  MainViewController.m
//  Examples
//
//  Created by Tony He (CTR) on 2024/7/31.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "MainViewController.h"
#import "APIClient.h"
#import "AWXShippingViewController.h"
#import "AirwallexExamplesKeys.h"
#import "FlowWithUIViewController.h"
#import "FlowWithoutUIViewController.h"
#import "InputViewController.h"
#import "OptionsViewController.h"
#import "Product.h"
#import "WechatPayViewController.h"
#import <Airwallex/Airwallex-Swift.h>

@interface MainViewController ()<AWXShippingViewControllerDelegate>

@property (strong, nonatomic) UIButton *flowWithUIButton;
@property (strong, nonatomic) UIButton *flowWithoutUIButton;
@property (strong, nonatomic) UIButton *h5DemoButton;
@property (strong, nonatomic) UIButton *wechatDemoButton;
@property (strong, nonatomic) UIButton *shippingButton;

@property (strong, nonatomic) AWXPlaceDetails *shipping;
@property (strong, nonatomic) NSMutableArray *products;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self setupAirwallexSDK];
    [self setupCartData];
    [self setupExamplesAPIClient];
}

- (void)setupAirwallexSDK {
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

- (void)setupViews {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settingTapped)];

    NSArray *buttons = @[
        self.flowWithUIButton,
        self.flowWithoutUIButton,
        self.h5DemoButton,
        self.wechatDemoButton,
        self.shippingButton
    ];

    for (UIButton *button in buttons) {
        [self.view addSubview:button];
    }

    NSArray *constraints = @[
        [self setupConstraintsForButton:self.flowWithUIButton
                              topAnchor:self.view.safeAreaLayoutGuide.topAnchor
                               constant:80],
        [self setupConstraintsForButton:self.flowWithoutUIButton
                              topAnchor:self.flowWithUIButton.bottomAnchor
                               constant:20],
        [self setupConstraintsForButton:self.h5DemoButton
                              topAnchor:self.flowWithoutUIButton.bottomAnchor
                               constant:20],
        [self setupConstraintsForButton:self.wechatDemoButton
                              topAnchor:self.h5DemoButton.bottomAnchor
                               constant:20],
        [self setupConstraintsForButton:self.shippingButton
                              topAnchor:self.wechatDemoButton.bottomAnchor
                               constant:20]
    ];

    NSMutableArray *flattenedConstraints = [NSMutableArray array];
    for (NSArray *constraintArray in constraints) {
        [flattenedConstraints addObjectsFromArray:constraintArray];
    }
    [NSLayoutConstraint activateConstraints:flattenedConstraints];
}

- (NSArray<NSLayoutConstraint *> *)setupConstraintsForButton:(UIButton *)button topAnchor:(NSLayoutAnchor *)topAnchor constant:(CGFloat)constant {
    return @[
        [button.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                             constant:48],
        [button.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                              constant:-48],
        [button.topAnchor constraintEqualToAnchor:topAnchor
                                         constant:constant],
        [button.heightAnchor constraintEqualToConstant:50.0]
    ];
}

- (void)setupCartData {
    Product *product0 = [[Product alloc] initWithName:@"AirPods Pro"
                                               detail:@"Free engraving x 1"
                                                price:[NSDecimalNumber decimalNumberWithString:@"399"]];
    Product *product1 = [[Product alloc] initWithName:@"HomePod"
                                               detail:@"White x 1"
                                                price:[NSDecimalNumber decimalNumberWithString:@"469"]];
    self.products = [@[product0, product1] mutableCopy];
    self.shipping = [[AWXPlaceDetails alloc] initWithFirstName:@"Jason" lastName:@"Wang" email:nil dateOfBirth:nil phoneNumber:@"13800000000" address:[[AWXAddress alloc] initWithCountryCode:@"CN" city:@"Shanghai" street:@"Pudong District" state:@"Shanghai" postcode:@"100000"]];
}

- (void)setupExamplesAPIClient {
    APIClient *client = [APIClient sharedClient];
    client.apiKey = [AirwallexExamplesKeys shared].apiKey;
    client.clientID = [AirwallexExamplesKeys shared].clientId;
}

- (void)mainButtonTapped:(UIButton *)button {
    if (button == self.flowWithUIButton) {
        [self showFlowWithUI];
    } else if (button == self.flowWithoutUIButton) {
        [self showFlowWithoutUI];
    } else if (button == self.h5DemoButton) {
        [self showH5Demo];
        return;
    } else if (button == self.wechatDemoButton) {
        [self showWechatDemo];
        return;
    } else if (button == self.shippingButton) {
        [self showShipping];
        return;
    }
}

- (void)settingTapped {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OptionsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"OptionsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showFlowWithUI {
    FlowWithUIViewController *vc = [FlowWithUIViewController new];
    vc.shipping = self.shipping;
    vc.products = self.products;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showFlowWithoutUI {
    FlowWithoutUIViewController *vc = [FlowWithoutUIViewController new];
    vc.shipping = self.shipping;
    vc.products = self.products;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showH5Demo {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InputViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InputViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showWechatDemo {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WechatPayViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WechatPayViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showShipping {
    AWXShippingViewController *controller = [[AWXShippingViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.shipping = self.shipping;
    [self.navigationController pushViewController:controller animated:YES];
}

- (UIButton *)createButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton new];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 8;
    button.layer.borderWidth = 1;
    button.layer.borderColor = UIColor.blackColor.CGColor;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

- (UIButton *)flowWithUIButton {
    if (!_flowWithUIButton) {
        _flowWithUIButton = [self createButtonWithTitle:@"integrate with Airwallex UI"];
    }
    return _flowWithUIButton;
}

- (UIButton *)flowWithoutUIButton {
    if (!_flowWithoutUIButton) {
        _flowWithoutUIButton = [self createButtonWithTitle:@"integrate with low level API"];
    }
    return _flowWithoutUIButton;
}

- (UIButton *)h5DemoButton {
    if (!_h5DemoButton) {
        _h5DemoButton = [self createButtonWithTitle:@"H5Demo"];
    }
    return _h5DemoButton;
}

- (UIButton *)wechatDemoButton {
    if (!_wechatDemoButton) {
        _wechatDemoButton = [self createButtonWithTitle:@"WeChat Demo"];
    }
    return _wechatDemoButton;
}

- (UIButton *)shippingButton {
    if (!_shippingButton) {
        _shippingButton = [self createButtonWithTitle:@"Shipping"];
    }
    return _shippingButton;
}

#pragma mark - AWXShippingViewControllerDelegate

- (void)shippingViewController:(AWXShippingViewController *)controller didEditShipping:(AWXPlaceDetails *)shipping {
    [controller.navigationController popViewControllerAnimated:YES];
    self.shipping = shipping;
}

@end
