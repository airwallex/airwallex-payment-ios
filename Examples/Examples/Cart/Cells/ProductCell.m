//
//  ProductCell.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "ProductCell.h"
#import <Airwallex/Core.h>

@implementation ProductCell

#pragma mark - Init

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [AWXTheme sharedTheme].primaryBackgroundColor;
    self.nameLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
    self.detailTextLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
    self.priceLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
    self.separator.backgroundColor = [AWXTheme sharedTheme].lineColor;
}

#pragma mark - ProductCell

- (void)setProduct:(Product *)product {
    _product = product;
    self.nameLabel.text = product.name;
    self.detailLabel.text = product.detail;
    self.priceLabel.text = [NSString stringWithFormat:@"$%@", product.price.string];
}

- (IBAction)removePressed:(id)sender {
    if (self.handler) {
        self.handler(self.product);
    }
}

@end
