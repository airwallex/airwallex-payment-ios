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

@property (weak, nonatomic) IBOutlet AWXCurrencyView *leftCurrencyView;
@property (weak, nonatomic) IBOutlet AWXCurrencyView *rightCurrencyView;
@property (weak, nonatomic) IBOutlet UIImageView *rateImageView;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@end

@implementation AWXDCCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    static NSDictionary* flags = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        flags = @{@"AED": @"AE",
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
    });

    self.leftCurrencyView.currencyName = self.response.currency;
    self.leftCurrencyView.price = [NSString stringWithFormat:@"%@%@", [self.response.amount currencySymbol:self.response.currency], self.response.amount.stringValue];
    NSString *flagPath = flags[self.response.currency];
    if (flagPath) {
        self.leftCurrencyView.flag = [UIImage imageNamed:[NSString stringWithFormat:@"Flag/%@", flagPath] inBundle:[NSBundle resourceBundle]];
    }

    self.leftCurrencyView.layer.masksToBounds = NO;
    self.leftCurrencyView.layer.cornerRadius = 6.0f;
    self.leftCurrencyView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.08].CGColor;
    self.leftCurrencyView.layer.shadowOffset = CGSizeMake(0, 0);
    self.leftCurrencyView.layer.shadowOpacity = 1;
    self.leftCurrencyView.layer.shadowRadius = 16;
    self.leftCurrencyView.exclusiveView = self.rightCurrencyView;
    self.leftCurrencyView.isSelected = YES;

    AWXDccResponse *dccResponse = self.response.nextAction.dccResponse;
    if (dccResponse) {
        self.rightCurrencyView.currencyName = dccResponse.currency;
        self.rightCurrencyView.price = [NSString stringWithFormat:@"%@%@", [dccResponse.amount currencySymbol:dccResponse.currency], dccResponse.amountString];
        NSString *flagPath = flags[dccResponse.currency];
        if (flagPath) {
            self.rightCurrencyView.flag = [UIImage imageNamed:[NSString stringWithFormat:@"Flag/%@", flagPath] inBundle:[NSBundle resourceBundle]];
        }
        self.rateLabel.text = [NSString stringWithFormat:@"1 %@ = %@ %@", self.response.currency, dccResponse.clientRateString, dccResponse.currency];
    }

    self.rightCurrencyView.layer.masksToBounds = NO;
    self.rightCurrencyView.layer.cornerRadius = 6.0f;
    self.rightCurrencyView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.08].CGColor;
    self.rightCurrencyView.layer.shadowOffset = CGSizeMake(0, 0);
    self.rightCurrencyView.layer.shadowOpacity = 1;
    self.rightCurrencyView.layer.shadowRadius = 16;
    self.rightCurrencyView.exclusiveView = self.leftCurrencyView;

    self.rateImageView.image = [UIImage imageNamed:@"fxRate" inBundle:[NSBundle resourceBundle]];

    self.confirmButton.enabled = YES;
}

- (IBAction)confirmPressed:(id)sender
{
    [self.delegate dccViewController:self useDCC:self.rightCurrencyView.isSelected];
}

@end
