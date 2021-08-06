//
//  AWXDCCViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/9/29.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXDCCViewController.h"
#import "AWXWidgets.h"
#import "AWXUtils.h"

@interface AWXDCCViewController ()

@property (strong, nonatomic) AWXCurrencyView *leftCurrencyView;
@property (strong, nonatomic) AWXCurrencyView *rightCurrencyView;
@property (strong, nonatomic) UILabel *rateLabel;
@property (strong, nonatomic) AWXButton *confirmButton;

@end

@implementation AWXDCCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(close:)];

    NSDictionary *flags = @{@"AED": @"AE",
                            @"AUD": @"AU",
                            @"BEL" :@"BE",
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
    titleLabel.text = NSLocalizedString(@"Select your currency", @"Select your currency");
    titleLabel.textColor = [UIColor textColor];
    titleLabel.font = [UIFont fontWithName:AWXFontFamilyNameCircularXX size:14];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleLabel];
    
    UILabel *subTitleLabel = [UILabel new];
    subTitleLabel.text = NSLocalizedString(@"Select the currency you would like to pay with", @"Select the currency you would like to pay with");
    subTitleLabel.textColor = [UIColor textColor];
    subTitleLabel.font = [UIFont fontWithName:AWXFontNameCircularStdBold size:18];
    subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subTitleLabel];
    
    UIView *contentView = [UIView new];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:contentView];
    
    _leftCurrencyView = [AWXCurrencyView new];
    _leftCurrencyView.currencyName = self.response.currency;
    _leftCurrencyView.price = [NSString stringWithFormat:@"%@%@", [self.response.amount currencySymbol:self.response.currency], self.response.amount.stringValue];
    NSString *flagPath = flags[self.response.currency];
    if (flagPath) {
        _leftCurrencyView.flag = [UIImage imageNamed:[NSString stringWithFormat:@"Flag/%@", flagPath] inBundle:[NSBundle resourceBundle]];
    } else {
        _leftCurrencyView.flag = nil;
    }
    _leftCurrencyView.layer.masksToBounds = NO;
    _leftCurrencyView.layer.cornerRadius = 6.0f;
    _leftCurrencyView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.08].CGColor;
    _leftCurrencyView.layer.shadowOffset = CGSizeMake(0, 0);
    _leftCurrencyView.layer.shadowOpacity = 1;
    _leftCurrencyView.layer.shadowRadius = 16;
    _leftCurrencyView.exclusiveView = self.rightCurrencyView;
    _leftCurrencyView.isSelected = YES;
    _leftCurrencyView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:_leftCurrencyView];
    
    _rightCurrencyView = [AWXCurrencyView new];
    _rightCurrencyView.layer.masksToBounds = NO;
    _rightCurrencyView.layer.cornerRadius = 6.0f;
    _rightCurrencyView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.08].CGColor;
    _rightCurrencyView.layer.shadowOffset = CGSizeMake(0, 0);
    _rightCurrencyView.layer.shadowOpacity = 1;
    _rightCurrencyView.layer.shadowRadius = 16;
    _rightCurrencyView.exclusiveView = self.leftCurrencyView;
    _rightCurrencyView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:_rightCurrencyView];
    
    UIView *tipView = [UIView new];
    tipView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tipView];
    
    UIImageView *rateImageView = [UIImageView new];
    rateImageView.image = [UIImage imageNamed:@"fxRate" inBundle:[NSBundle resourceBundle]];
    rateImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [tipView addSubview:rateImageView];

    _rateLabel = [UILabel new];
    _rateLabel.textColor = [UIColor floatingTitleColor];
    _rateLabel.font = [UIFont fontWithName:AWXFontFamilyNameCircularXX size:14];
    _rateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [tipView addSubview:_rateLabel];
    
    _confirmButton = [AWXButton new];
    _confirmButton.enabled = YES;
    _confirmButton.cornerRadius = 6;
    [_confirmButton setTitle:NSLocalizedString(@"Confirm payment", @"Confirm payment") forState:UIControlStateNormal];
    _confirmButton.titleLabel.font = [UIFont fontWithName:AWXFontNameCircularStdBold size:14];
    [_confirmButton addTarget:self action:@selector(confirmPressed:) forControlEvents:UIControlEventTouchUpInside];
    _confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_confirmButton];
    
    NSDictionary *views = @{@"titleLabel": titleLabel, @"subTitleLabel": subTitleLabel, @"contentView": contentView, @"leftCurrencyView": _leftCurrencyView, @"rightCurrencyView": _rightCurrencyView, @"tipView": tipView, @"rateImageView": rateImageView, @"rateLabel": _rateLabel, @"confirmButton": _confirmButton};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[titleLabel]-24-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-32-[titleLabel]-16-[subTitleLabel]-24-[contentView]-18-[tipView]-40-[confirmButton(44)]" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:nil views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftCurrencyView]-16-[rightCurrencyView]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftCurrencyView]|" options:0 metrics:nil views:views]];
    [_leftCurrencyView.widthAnchor constraintEqualToAnchor:_rightCurrencyView.widthAnchor].active = YES;
    [tipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[rateImageView(16)]-8-[rateLabel]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [tipView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rateImageView(16)]|" options:0 metrics:nil views:views]];

    AWXDccResponse *dccResponse = self.response.nextAction.dccResponse;
    if (dccResponse) {
        _rightCurrencyView.currencyName = dccResponse.currency;
        _rightCurrencyView.price = [NSString stringWithFormat:@"%@%@", [dccResponse.amount currencySymbol:dccResponse.currency], dccResponse.amountString];
        NSString *flagPath = flags[dccResponse.currency];
        if (flagPath) {
            _rightCurrencyView.flag = [UIImage imageNamed:[NSString stringWithFormat:@"Flag/%@", flagPath] inBundle:[NSBundle resourceBundle]];
        } else {
            _rightCurrencyView.flag = nil;
        }
        _rateLabel.text = [NSString stringWithFormat:@"1 %@ = %@ %@", self.response.currency, dccResponse.clientRateString, dccResponse.currency];
    }
}

- (IBAction)confirmPressed:(id)sender
{
    [self.delegate dccViewController:self useDCC:self.rightCurrencyView.isSelected];
}

@end
