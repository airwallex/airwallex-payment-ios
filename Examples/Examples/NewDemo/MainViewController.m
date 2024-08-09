//
//  MainViewController.m
//  Examples
//
//  Created by Tony He (CTR) on 2024/7/31.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "MainViewController.h"
#import "APIClient.h"
#import "AWXCardProvider.h"
#import "AWXShippingViewController.h"
#import "AirwallexExamplesKeys.h"
#import "FlowWithUIViewController.h"
#import "FlowWithoutUIViewController.h"
#import "InputViewController.h"
#import "OptionsViewController.h"
#import "Product.h"
#import "UIViewController+Utils.h"
#import "WechatPayViewController.h"
#import <Airwallex/Airwallex-Swift.h>
#import <Airwallex/ApplePay.h>
#import <Airwallex/Core.h>
#import <SafariServices/SFSafariViewController.h>

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

    [self.view addSubview:self.flowWithUIButton];
    [self.view addSubview:self.flowWithoutUIButton];
    [self.view addSubview:self.h5DemoButton];
    [self.view addSubview:self.wechatDemoButton];
    [self.view addSubview:self.shippingButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.flowWithUIButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                            constant:48],
        [self.flowWithUIButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                                             constant:-48],
        [self.flowWithUIButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor
                                                        constant:80],
        [self.flowWithUIButton.heightAnchor constraintEqualToConstant:50.0],

        [self.flowWithoutUIButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                               constant:48],
        [self.flowWithoutUIButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                                                constant:-48],
        [self.flowWithoutUIButton.topAnchor constraintEqualToAnchor:self.flowWithUIButton.bottomAnchor
                                                           constant:20],
        [self.flowWithoutUIButton.heightAnchor constraintEqualToConstant:50.0],

        [self.h5DemoButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.h5DemoButton.widthAnchor constraintEqualToAnchor:self.view.widthAnchor
                                                      constant:-96],
        [self.h5DemoButton.topAnchor constraintEqualToAnchor:self.flowWithoutUIButton.bottomAnchor
                                                    constant:20.0],
        [self.h5DemoButton.heightAnchor constraintEqualToConstant:50.0],

        [self.wechatDemoButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.wechatDemoButton.widthAnchor constraintEqualToAnchor:self.view.widthAnchor
                                                          constant:-96],
        [self.wechatDemoButton.topAnchor constraintEqualToAnchor:self.h5DemoButton.bottomAnchor
                                                        constant:20.0],
        [self.wechatDemoButton.heightAnchor constraintEqualToConstant:50.0],

        [self.shippingButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.shippingButton.widthAnchor constraintEqualToAnchor:self.view.widthAnchor
                                                        constant:-96],
        [self.shippingButton.topAnchor constraintEqualToAnchor:self.wechatDemoButton.bottomAnchor
                                                      constant:20.0],
        [self.shippingButton.heightAnchor constraintEqualToConstant:50.0]
    ]];
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

- (UIButton *)flowWithUIButton {
    if (!_flowWithUIButton) {
        _flowWithUIButton = [UIButton new];
        [_flowWithUIButton setTitle:@"integrate with Airwallex UI" forState:UIControlStateNormal];
        _flowWithUIButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_flowWithUIButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_flowWithUIButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _flowWithUIButton.layer.cornerRadius = 8;
        _flowWithUIButton.layer.borderWidth = 1;
        _flowWithUIButton.layer.borderColor = UIColor.blackColor.CGColor;
        _flowWithUIButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _flowWithUIButton;
}

- (UIButton *)flowWithoutUIButton {
    if (!_flowWithoutUIButton) {
        _flowWithoutUIButton = [UIButton new];
        [_flowWithoutUIButton setTitle:@"integrate with low level API" forState:UIControlStateNormal];
        _flowWithoutUIButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_flowWithoutUIButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_flowWithoutUIButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _flowWithoutUIButton.layer.cornerRadius = 8;
        _flowWithoutUIButton.layer.borderWidth = 1;
        _flowWithoutUIButton.layer.borderColor = UIColor.blackColor.CGColor;
        _flowWithoutUIButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _flowWithoutUIButton;
}

- (UIButton *)h5DemoButton {
    if (!_h5DemoButton) {
        _h5DemoButton = [UIButton new];
        [_h5DemoButton setTitle:@"H5Demo" forState:UIControlStateNormal];
        _h5DemoButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_h5DemoButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_h5DemoButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _h5DemoButton.layer.cornerRadius = 8;
        _h5DemoButton.layer.borderWidth = 1;
        _h5DemoButton.layer.borderColor = UIColor.blackColor.CGColor;
        _h5DemoButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _h5DemoButton;
}

- (UIButton *)wechatDemoButton {
    if (!_wechatDemoButton) {
        _wechatDemoButton = [UIButton new];
        [_wechatDemoButton setTitle:@"WeChat Demo" forState:UIControlStateNormal];
        _wechatDemoButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_wechatDemoButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_wechatDemoButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _wechatDemoButton.layer.cornerRadius = 8;
        _wechatDemoButton.layer.borderWidth = 1;
        _wechatDemoButton.layer.borderColor = UIColor.blackColor.CGColor;
        _wechatDemoButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _wechatDemoButton;
}

- (UIButton *)shippingButton {
    if (!_shippingButton) {
        _shippingButton = [UIButton new];
        [_shippingButton setTitle:@"Shipping" forState:UIControlStateNormal];
        _shippingButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_shippingButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_shippingButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _shippingButton.layer.cornerRadius = 8;
        _shippingButton.layer.borderWidth = 1;
        _shippingButton.layer.borderColor = UIColor.blackColor.CGColor;
        _shippingButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _shippingButton;
}

#pragma mark - AWXShippingViewControllerDelegate

- (void)shippingViewController:(AWXShippingViewController *)controller didEditShipping:(AWXPlaceDetails *)shipping {
    [controller.navigationController popViewControllerAnimated:YES];
    self.shipping = shipping;
}

@end
