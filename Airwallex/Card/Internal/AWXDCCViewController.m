//
//  AWXDCCViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/9/29.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXDCCViewController.h"
#import "AWXDccResponse.h"
#import "AWXSession.h"
#import "AWXTheme.h"
#import "AWXUtils.h"
#import "AWXWidgets.h"
#import "NSBundle+Card.h"

@interface AWXDCCViewController ()

@property (strong, nonatomic) AWXCurrencyView *leftCurrencyView;
@property (strong, nonatomic) AWXCurrencyView *rightCurrencyView;
@property (strong, nonatomic) UILabel *rateLabel;
@property (strong, nonatomic) AWXActionButton *confirmButton;

@end

@implementation AWXDCCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [AWXTheme sharedTheme].primaryBackgroundColor;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [NSBundle cardBundle], @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(close:)];

    NSDictionary *flags = @{@"AED": @"AE",
                            @"AUD": @"AU",
                            @"BEL": @"BE",
                            @"BDT": @"BD",
                            @"BGR": @"BG",
                            @"CAD": @"CA",
                            @"CHF": @"CH",
                            @"CNH": @"CN",
                            @"CNY": @"CN",
                            @"CNY_ONSHORE": @"CN",
                            @"CSK": @"CZ",
                            @"CYP": @"CY",
                            @"CZE": @"CZ",
                            @"DKK": @"DK",
                            @"EEK": @"EE",
                            @"EUR": @"EU",
                            @"GBP": @"GB",
                            @"GIP": @"GI",
                            @"HKD": @"HK",
                            @"HRK": @"HR",
                            @"HRV": @"HR",
                            @"HUF": @"HU",
                            @"IDR": @"ID",
                            @"INR": @"IN",
                            @"JPY": @"JP",
                            @"ISK": @"IS",
                            @"KRW": @"KR",
                            @"LKR": @"LK",
                            @"MYR": @"MY",
                            @"NOK": @"NO",
                            @"NPR": @"NP",
                            @"NZD": @"NZ",
                            @"PHP": @"PH",
                            @"PKR": @"PK",
                            @"PLN": @"PL",
                            @"RON": @"RO",
                            @"SEK": @"SE",
                            @"SGD": @"SG",
                            @"THB": @"TH",
                            @"TRY": @"TR",
                            @"USD": @"US",
                            @"VND": @"VN"};

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = NSLocalizedStringFromTableInBundle(@"Select your currency", nil, [NSBundle cardBundle], @"Select your currency");
    titleLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
    titleLabel.font = [UIFont headlineFont];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleLabel];

    UILabel *subTitleLabel = [UILabel new];
    subTitleLabel.text = NSLocalizedStringFromTableInBundle(@"Select the currency you would like to pay with", nil, [NSBundle cardBundle], @"Select the currency you would like to pay with");
    subTitleLabel.textColor = [AWXTheme sharedTheme].secondaryTextColor;
    subTitleLabel.font = [UIFont subhead1Font];
    subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subTitleLabel];

    UIView *contentView = [UIView new];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:contentView];

    _leftCurrencyView = [AWXCurrencyView new];
    _leftCurrencyView.currencyName = self.session.currency;
    _leftCurrencyView.price = [NSString stringWithFormat:@"%@%@", [self.session.amount currencySymbol:self.session.currency], self.session.amount.stringValue];
    NSString *flagPath = flags[self.session.currency];
    if (flagPath) {
        _leftCurrencyView.flag = [UIImage imageNamed:[NSString stringWithFormat:@"Flag/%@", flagPath] inBundle:[NSBundle resourceBundle]];
    } else {
        _leftCurrencyView.flag = nil;
    }
    _leftCurrencyView.layer.masksToBounds = NO;
    _leftCurrencyView.layer.cornerRadius = 8;
    _leftCurrencyView.layer.shadowColor = [AWXTheme sharedTheme].shadowColor.CGColor;
    _leftCurrencyView.layer.shadowOffset = CGSizeMake(0, 0);
    _leftCurrencyView.layer.shadowOpacity = 1;
    _leftCurrencyView.layer.shadowRadius = 16;
    _leftCurrencyView.isSelected = YES;
    _leftCurrencyView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:_leftCurrencyView];

    _rightCurrencyView = [AWXCurrencyView new];
    _rightCurrencyView.layer.masksToBounds = NO;
    _rightCurrencyView.layer.cornerRadius = 8;
    _rightCurrencyView.layer.shadowColor = [AWXTheme sharedTheme].shadowColor.CGColor;
    _rightCurrencyView.layer.shadowOffset = CGSizeMake(0, 0);
    _rightCurrencyView.layer.shadowOpacity = 1;
    _rightCurrencyView.layer.shadowRadius = 16;
    _rightCurrencyView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:_rightCurrencyView];

    _leftCurrencyView.exclusiveView = _rightCurrencyView;
    _rightCurrencyView.exclusiveView = _leftCurrencyView;

    UIView *tipView = [UIView new];
    tipView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tipView];

    UIImageView *rateImageView = [UIImageView new];
    rateImageView.image = [UIImage imageNamed:@"fxRate" inBundle:[NSBundle resourceBundle]];
    rateImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [tipView addSubview:rateImageView];

    _rateLabel = [UILabel new];
    _rateLabel.textColor = [AWXTheme sharedTheme].secondaryTextColor;
    _rateLabel.font = [UIFont subhead1Font];
    _rateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [tipView addSubview:_rateLabel];

    _confirmButton = [AWXActionButton new];
    _confirmButton.enabled = YES;
    [_confirmButton setTitle:NSLocalizedStringFromTableInBundle(@"Confirm payment", nil, [NSBundle cardBundle], @"Confirm payment") forState:UIControlStateNormal];
    _confirmButton.titleLabel.font = [UIFont subhead2Font];
    [_confirmButton addTarget:self action:@selector(confirmPressed:) forControlEvents:UIControlEventTouchUpInside];
    _confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_confirmButton];

    NSDictionary *views = @{@"titleLabel": titleLabel, @"subTitleLabel": subTitleLabel, @"contentView": contentView, @"leftCurrencyView": _leftCurrencyView, @"rightCurrencyView": _rightCurrencyView, @"tipView": tipView, @"rateImageView": rateImageView, @"rateLabel": _rateLabel, @"confirmButton": _confirmButton};

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[titleLabel]-24-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleLabel]-16-[subTitleLabel]-24-[contentView(110)]-18-[tipView]-40-[confirmButton(52)]" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:nil views:views]];
    [titleLabel.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant:24].active = YES;
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftCurrencyView]-16-[rightCurrencyView]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftCurrencyView]|" options:0 metrics:nil views:views]];
    [_leftCurrencyView.widthAnchor constraintEqualToAnchor:_rightCurrencyView.widthAnchor].active = YES;
    [tipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[rateImageView(16)]-8-[rateLabel]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [tipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rateImageView(16)]|" options:0 metrics:nil views:views]];

    AWXDccResponse *dccResponse = self.response;
    if (dccResponse) {
        _rightCurrencyView.currencyName = dccResponse.currency;
        _rightCurrencyView.price = [NSString stringWithFormat:@"%@%@", [dccResponse.amount currencySymbol:dccResponse.currency], dccResponse.amountString];
        NSString *flagPath = flags[dccResponse.currency];
        if (flagPath) {
            _rightCurrencyView.flag = [UIImage imageNamed:[NSString stringWithFormat:@"Flag/%@", flagPath] inBundle:[NSBundle resourceBundle]];
        } else {
            _rightCurrencyView.flag = nil;
        }
        _rateLabel.text = [NSString stringWithFormat:@"1 %@ = %@ %@", self.session.currency, dccResponse.clientRateString, dccResponse.currency];
    }
}

- (IBAction)confirmPressed:(id)sender {
    [self.delegate dccViewController:self useDCC:self.rightCurrencyView.isSelected];
}

@end
