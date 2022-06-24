//
//  Product.m
//  Examples
//
//  Created by Jarrod Robins on 20/6/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "Product.h"

@implementation Product

- (instancetype)initWithName:(NSString *)name
                      detail:(NSString *)detail
                       price:(NSDecimalNumber *)price {
    if (self = [super init]) {
        self.name = name;
        self.detail = detail;
        self.price = price;
    }
    return self;
}

@end
