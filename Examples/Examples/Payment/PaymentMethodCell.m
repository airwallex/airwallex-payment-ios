//
//  PaymentMethodCell.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "PaymentMethodCell.h"

@implementation PaymentMethodCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.tickView.hidden = !selected;
}

@end
