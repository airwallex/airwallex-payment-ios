//
//  PaymentItemCell.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "PaymentItemCell.h"

@interface PaymentItemCell () <UITextFieldDelegate>

@end

@implementation PaymentItemCell

- (void)setIsLastCell:(BOOL)isLastCell
{
    _isLastCell = isLastCell;
    CGFloat constant = isLastCell ? 0 : 16;
    self.lineLeftConstraint.constant = constant;
    self.lineRightConstraint.constant = constant;
}

- (void)setCvcHidden:(BOOL)cvcHidden
{
    _cvcHidden = cvcHidden;
    self.cvcView.hidden = cvcHidden;
    self.lineTopConstraint.constant = cvcHidden ? 20 : 72;
}

@end
