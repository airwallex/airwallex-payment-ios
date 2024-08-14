//
//  CardInfoView.m
//  Examples
//
//  Created by Tony He (CTR) on 2024/8/8.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "CardInfoView.h"
#import "AWXAPIClient.h"
#import <Airwallex/Airwallex-Swift.h>

@interface CardInfoView ()

@property (strong, nonatomic) UIButton *close;

@property (strong, nonatomic) UIView *background;

@property (strong, nonatomic) UILabel *title;

@property (strong, nonatomic) UITextField *number;
@property (strong, nonatomic) UITextField *name;
@property (strong, nonatomic) UITextField *month;
@property (strong, nonatomic) UITextField *year;
@property (strong, nonatomic) UITextField *cvc;

@end

@implementation CardInfoView

@synthesize card = _card;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3];

    self.background.layer.cornerRadius = 20;
    self.background.clipsToBounds = YES;

    [self addSubview:self.close];
    [self addSubview:self.background];

    [self.background addSubview:self.title];
    [self.background addSubview:self.number];
    [self.background addSubview:self.name];
    [self.background addSubview:self.month];
    [self.background addSubview:self.year];
    [self.background addSubview:self.cvc];
    [self.background addSubview:self.pay];

    [NSLayoutConstraint activateConstraints:@[
        [self.close.bottomAnchor constraintEqualToAnchor:self.background.topAnchor
                                                constant:-20],
        [self.close.trailingAnchor constraintEqualToAnchor:self.background.trailingAnchor
                                                  constant:-20],
        [self.close.heightAnchor constraintEqualToConstant:40],
        [self.close.widthAnchor constraintEqualToConstant:40],

        [self.background.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.background.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.background.widthAnchor constraintEqualToAnchor:self.widthAnchor
                                                    constant:-50],

        [self.title.topAnchor constraintEqualToAnchor:self.background.topAnchor
                                             constant:10],
        [self.title.leadingAnchor constraintEqualToAnchor:self.background.leadingAnchor
                                                 constant:10],
        [self.title.trailingAnchor constraintEqualToAnchor:self.background.trailingAnchor
                                                  constant:-10],
        [self.title.heightAnchor constraintEqualToConstant:40],

        [self.number.topAnchor constraintEqualToAnchor:self.title.bottomAnchor
                                              constant:5],
        [self.number.leadingAnchor constraintEqualToAnchor:self.background.leadingAnchor
                                                  constant:10],
        [self.number.trailingAnchor constraintEqualToAnchor:self.background.trailingAnchor
                                                   constant:-10],
        [self.number.heightAnchor constraintEqualToConstant:40],

        [self.name.topAnchor constraintEqualToAnchor:self.number.bottomAnchor
                                            constant:5],
        [self.name.leadingAnchor constraintEqualToAnchor:self.background.leadingAnchor
                                                constant:10],
        [self.name.trailingAnchor constraintEqualToAnchor:self.background.trailingAnchor
                                                 constant:-10],
        [self.name.heightAnchor constraintEqualToConstant:40],

        [self.month.topAnchor constraintEqualToAnchor:self.name.bottomAnchor
                                             constant:5],
        [self.month.leadingAnchor constraintEqualToAnchor:self.background.leadingAnchor
                                                 constant:10],
        [self.month.heightAnchor constraintEqualToConstant:40],

        [self.year.topAnchor constraintEqualToAnchor:self.name.bottomAnchor
                                            constant:5],
        [self.year.leadingAnchor constraintEqualToAnchor:self.month.trailingAnchor
                                                constant:10],
        [self.year.widthAnchor constraintEqualToAnchor:self.month.widthAnchor],
        [self.year.heightAnchor constraintEqualToConstant:40],

        [self.cvc.topAnchor constraintEqualToAnchor:self.name.bottomAnchor
                                           constant:5],
        [self.cvc.leadingAnchor constraintEqualToAnchor:self.year.trailingAnchor
                                               constant:10],
        [self.cvc.trailingAnchor constraintEqualToAnchor:self.background.trailingAnchor
                                                constant:-10],
        [self.cvc.widthAnchor constraintEqualToAnchor:self.month.widthAnchor],
        [self.cvc.heightAnchor constraintEqualToConstant:40],

        [self.pay.topAnchor constraintEqualToAnchor:self.cvc.bottomAnchor
                                           constant:20],
        [self.pay.leadingAnchor constraintEqualToAnchor:self.background.leadingAnchor
                                               constant:60],
        [self.pay.trailingAnchor constraintEqualToAnchor:self.background.trailingAnchor
                                                constant:-60],
        [self.pay.bottomAnchor constraintEqualToAnchor:self.background.bottomAnchor
                                              constant:-20],
        [self.pay.heightAnchor constraintEqualToConstant:48]
    ]];
}

- (UIButton *)close {
    if (!_close) {
        _close = [UIButton new];
        _close.backgroundColor = UIColor.whiteColor;
        [_close addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
        [_close setImage:[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] forState:UIControlStateNormal];
        _close.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _close;
}

- (UIView *)background {
    if (!_background) {
        _background = [UIView new];
        _background.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        _background.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _background;
}

- (UILabel *)title {
    if (!_title) {
        _title = [UILabel new];
    }
    NSString *mode;
    switch (Airwallex.mode) {
    case AirwallexSDKProductionMode:
        mode = @"PRODUCTION";
        break;
    case AirwallexSDKDemoMode:
        mode = @"DEMO";
        break;
    case AirwallexSDKStagingMode:
        mode = @"STAGING";
        break;
    default:
        break;
    }
    _title.textAlignment = NSTextAlignmentCenter;
    _title.text = [NSString stringWithFormat:@"card info / current environment: %@", mode];
    _title.translatesAutoresizingMaskIntoConstraints = NO;
    return _title;
}

- (UITextField *)createTextField {
    UITextField *textField = [UITextField new];
    textField.layer.cornerRadius = 6;
    textField.clipsToBounds = YES;
    textField.backgroundColor = UIColor.whiteColor;
    textField.layer.borderColor = UIColor.darkGrayColor.CGColor;
    textField.layer.borderWidth = 1;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    return textField;
}

- (UITextField *)number {
    if (!_number) {
        _number = [self createTextField];
    }
    return _number;
}

- (UITextField *)name {
    if (!_name) {
        _name = [self createTextField];
    }
    return _name;
}

- (UITextField *)month {
    if (!_month) {
        _month = [self createTextField];
    }
    return _month;
}

- (UITextField *)year {
    if (!_year) {
        _year = [self createTextField];
    }
    return _year;
}

- (UITextField *)cvc {
    if (!_cvc) {
        _cvc = [self createTextField];
    }
    return _cvc;
}
- (UIButton *)pay {
    if (!_pay) {
        _pay = [UIButton new];
        [_pay setTitle:@"pay" forState:UIControlStateNormal];
        [_pay setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _pay.backgroundColor = UIColor.systemBlueColor;
        _pay.layer.cornerRadius = 8;
        _pay.clipsToBounds = YES;
        _pay.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _pay;
}

- (void)setCard:(AWXCard *)card {
    _card = card;
    self.number.text = card.number;
    self.name.text = card.name;
    self.month.text = card.expiryMonth;
    self.year.text = card.expiryYear;
    self.cvc.text = card.cvc;
}

- (AWXCard *)card {
    AWXCard *c = [[AWXCard alloc] initWithNumber:self.number.text expiryMonth:self.month.text expiryYear:self.year.text name:self.name.text cvc:self.cvc.text bin:nil last4:nil brand:nil country:nil funding:nil fingerprint:nil cvcCheck:nil avsCheck:nil numberType:nil];
    return c;
}

- (void)setIsEditEnabled:(BOOL)isEditEnabled {
    _isEditEnabled = isEditEnabled;
    self.number.enabled = isEditEnabled;
    self.name.enabled = isEditEnabled;
    self.month.enabled = isEditEnabled;
    self.year.enabled = isEditEnabled;
    self.cvc.enabled = isEditEnabled;
}

- (void)closeTapped {
    self.hidden = YES;
}

@end
