//
//  AWPaymentMethodCell.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentMethodCell.h"

@implementation AWPaymentMethodCell

- (void)setIsLastCell:(BOOL)isLastCell
{
    _isLastCell = isLastCell;
    CGFloat constant = isLastCell ? 0 : 16;
    self.lineLeftConstraint.constant = constant;
    self.lineRightConstraint.constant = constant;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.tickView.hidden = !selected;
}

@end

@implementation AWNoCardCell

- (void)setIsLastCell:(BOOL)isLastCell
{
    _isLastCell = isLastCell;
    CGFloat constant = isLastCell ? 0 : 16;
    self.lineLeftConstraint.constant = constant;
    self.lineRightConstraint.constant = constant;
}

@end
