//
//  AWXDCCViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/9/29.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXDCCViewController.h"
#import "AWXWidgets.h"

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
    self.leftCurrencyView.currencyName = self.response.currency;
    self.leftCurrencyView.price = [NSString stringWithFormat:@"$ %@", self.response.amount.stringValue];
//    self.leftCurrencyView.flag = [UIImage imageNamed:self.response.currency inBundle:[NSBundle resourceBundle]];
    self.leftCurrencyView.flag = [UIImage imageNamed:@"USD" inBundle:[NSBundle resourceBundle]];

    self.leftCurrencyView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.leftCurrencyView.layer.shadowOffset = CGSizeMake(0, 0);
    self.leftCurrencyView.layer.shadowOpacity = 0.5;
    self.leftCurrencyView.layer.shadowRadius = 5;

    AWXDccResponse *dccResponse = self.response.nextAction.dccResponse;
    if (dccResponse) {
        self.rightCurrencyView.currencyName = dccResponse.currency;
        self.rightCurrencyView.price = [NSString stringWithFormat:@"$ %@", dccResponse.amount.stringValue];
//        self.rightCurrencyView.flag = [UIImage imageNamed:dccResponse.currency inBundle:[NSBundle resourceBundle]];
        self.rightCurrencyView.flag = [UIImage imageNamed:@"AUD" inBundle:[NSBundle resourceBundle]];
        self.rateLabel.text = [NSString stringWithFormat:@"1 %@ = %@ %@", self.response.currency, dccResponse.clientRate.stringValue, dccResponse.currency];
    }

    self.rightCurrencyView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.rightCurrencyView.layer.shadowOffset = CGSizeMake(0, 0);
    self.rightCurrencyView.layer.shadowOpacity = 0.5;
    self.rightCurrencyView.layer.shadowRadius = 5;

    self.rateImageView.image = [UIImage imageNamed:@"fxRate" inBundle:[NSBundle resourceBundle]];
}

- (IBAction)confirmPressed:(id)sender
{
    
}

@end
