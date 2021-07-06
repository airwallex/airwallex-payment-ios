//
//  ProductCell.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "ProductCell.h"
#import <Airwallex/Airwallex.h>

@implementation Product

- (instancetype)initWithName:(NSString *)name
                      detail:(NSString *)detail
                       price:(NSDecimalNumber *)price
{
    if (self = [super init]) {
        self.name = name;
        self.detail = detail;
        self.price = price;
    }
    return self;
}

@end

@implementation ProductCell

- (void)setProduct:(Product *)product
{
    _product = product;
    self.nameLabel.text = product.name;
    self.detailLabel.text = product.detail;
    self.priceLabel.text = [NSString stringWithFormat:@"$%@", product.price.string];
    [self.removeButton setTitleColor:[AWXTheme sharedTheme].tintColor forState:UIControlStateNormal];
}

- (IBAction)removePressed:(id)sender
{
    if (self.handler) {
        self.handler(self.product);
    }
}

@end
