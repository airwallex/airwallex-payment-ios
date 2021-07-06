//
//  TotalCell.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "TotalCell.h"
#import <Airwallex/Airwallex.h>

@implementation TotalCell

- (void)setSubtotal:(NSDecimalNumber *)subtotal
{
    _subtotal = subtotal;
    self.subtotalLabel.text = [NSString stringWithFormat:@"$%@", subtotal.string];
}

- (void)setShipping:(NSDecimalNumber *)shipping
{
    _shipping = shipping;
    self.shippingLabel.text = [NSString stringWithFormat:@"$%@", shipping.string];
}

- (void)setTotal:(NSDecimalNumber *)total
{
    _total = total;
    self.totalLabel.text = [NSString stringWithFormat:@"$%@", total.string];
}

@end
