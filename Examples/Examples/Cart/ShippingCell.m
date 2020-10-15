//
//  ShippingCell.m
//  Examples
//
//  Created by Victor Zhu on 2020/5/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "ShippingCell.h"

@implementation ShippingCell

- (void)setShipping:(AWXPlaceDetails *)shipping
{
    if (shipping) {
        self.shippingLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@ %@", shipping.firstName, shipping.lastName, shipping.address.street, shipping.address.city, shipping.address.state, shipping.address.countryCode];
        self.shippingLabel.textColor = [UIColor colorNamed:@"Black Text Color"];
    } else {
        self.shippingLabel.text = @"Enter shipping information";
        self.shippingLabel.textColor = [UIColor colorNamed:@"Placeholder Color"];
    }
}

@end
