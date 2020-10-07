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
    self.leftCurrencyView.currencyName = self.response.currency;
    self.leftCurrencyView.price = [self.response.amount stringWithCurrencyCode:self.response.currency];
//    self.leftCurrencyView.flag = [UIImage imageNamed:self.response.currency inBundle:[NSBundle resourceBundle]];
    self.leftCurrencyView.flag = [UIImage imageNamed:@"USD" inBundle:[NSBundle resourceBundle]];

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
        self.rightCurrencyView.price = [dccResponse.amount stringWithCurrencyCode:dccResponse.currency];
//        self.rightCurrencyView.flag = [UIImage imageNamed:dccResponse.currency inBundle:[NSBundle resourceBundle]];
        self.rightCurrencyView.flag = [UIImage imageNamed:@"AUD" inBundle:[NSBundle resourceBundle]];
        self.rateLabel.text = [NSString stringWithFormat:@"1 %@ = %@ %@", self.response.currency, dccResponse.clientRate.string, dccResponse.currency];
    }

    self.rightCurrencyView.layer.masksToBounds = NO;
    self.rightCurrencyView.layer.cornerRadius = 6.0f;
    self.rightCurrencyView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.08].CGColor;
    self.rightCurrencyView.layer.shadowOffset = CGSizeMake(0, 0);
    self.rightCurrencyView.layer.shadowOpacity = 1;
    self.rightCurrencyView.layer.shadowRadius = 16;
    self.rightCurrencyView.exclusiveView = self.leftCurrencyView;

    self.rateImageView.image = [UIImage imageNamed:@"fxRate" inBundle:[NSBundle resourceBundle]];

    self.confirmButton.layer.masksToBounds = NO;
    self.confirmButton.layer.cornerRadius = 6.0f;
}

- (IBAction)confirmPressed:(id)sender
{
    
}

@end
