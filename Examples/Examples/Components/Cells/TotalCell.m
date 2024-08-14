//
//  TotalCell.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "TotalCell.h"
#import <Airwallex/Core.h>

@implementation TotalCell

#pragma mark - Init

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [AWXTheme sharedTheme].primaryBackgroundColor;

    self.subtotalTitleLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
    self.subtotalLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;

    self.totalTitleLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
    self.totalLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;

    for (UIView *separator in self.separators) {
        separator.backgroundColor = [AWXTheme sharedTheme].lineColor;
    }
}

#pragma mark - TotalCell

- (void)setSubtotal:(NSDecimalNumber *)subtotal {
    _subtotal = subtotal;
    self.subtotalLabel.text = [NSString stringWithFormat:@"$%@", subtotal.string];
}

- (void)setTotal:(NSDecimalNumber *)total {
    _total = total;
    self.totalLabel.text = [NSString stringWithFormat:@"$%@", total.string];
}

@end
