//
//  PaymentMethodListView.m
//  Examples
//
//  Created by Tony He (CTR) on 2024/8/9.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "PaymentMethodListView.h"
#import "AWXAPIClient.h"
#import "PaymentMethodCell.h"
#import <Airwallex/Airwallex-Swift.h>
#import <SDWebImage/SDWebImage.h>

@interface PaymentMethodListView ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIButton *close;

@property (strong, nonatomic) UITableView *table;
@property (nonatomic, strong) NSArray<AWXPaymentMethodType *> *paymentMethodTypeList;

@end

@implementation PaymentMethodListView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3];

    [self addSubview:self.close];
    [self addSubview:self.table];

    [NSLayoutConstraint activateConstraints:@[
        [self.close.bottomAnchor constraintEqualToAnchor:self.table.topAnchor
                                                constant:-20],
        [self.close.trailingAnchor constraintEqualToAnchor:self.trailingAnchor
                                                  constant:-20],
        [self.close.heightAnchor constraintEqualToConstant:40],
        [self.close.widthAnchor constraintEqualToConstant:40],

        [self.table.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.table.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.table.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.table.heightAnchor constraintEqualToAnchor:self.heightAnchor
                                              multiplier:0.5]
    ]];
}

- (UITableView *)table {
    if (!_table) {
        _table = [UITableView new];
        [_table registerClass:PaymentMethodCell.class forCellReuseIdentifier:@"paymentMethodCell"];
        _table.delegate = self;
        _table.dataSource = self;
        _table.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _table;
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

- (void)reloadWith:(NSArray<AWXPaymentMethodType *> *)list {
    self.paymentMethodTypeList = list;
    [self.table reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.paymentMethodTypeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PaymentMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"paymentMethodCell" forIndexPath:indexPath];

    AWXPaymentMethodType *paymentMethodType = self.paymentMethodTypeList[indexPath.row];
    [cell.logoImageView sd_setImageWithURL:paymentMethodType.resources.logoURL placeholderImage:[UIImage new]];
    cell.titleLabel.text = paymentMethodType.displayName;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return;
}

- (void)closeTapped {
    self.hidden = YES;
}

@end
