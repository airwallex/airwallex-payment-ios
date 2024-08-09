//
//  ShippingCell.m
//  Examples
//
//  Created by Victor Zhu on 2020/5/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "ShippingCell.h"
#import "AWXTheme.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@implementation ShippingCell

#pragma mark - Init

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [AWXTheme sharedTheme].primaryBackgroundColor;
    self.shippingTitleLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
    self.shippingLabel.textColor = [AWXTheme sharedTheme].secondaryTextColor;
    self.separator.backgroundColor = [AWXTheme sharedTheme].lineColor;
    self.disclosureIndicator.tintColor = [AWXTheme sharedTheme].glyphColor;
}

#pragma mark - ShippingCell

- (void)setShipping:(AWXPlaceDetails *)shipping {
    if (shipping) {
        self.shippingLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@ %@", shipping.firstName, shipping.lastName, shipping.address.street, shipping.address.city, shipping.address.state, shipping.address.countryCode];
        self.shippingLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
    } else {
        self.shippingLabel.text = @"Enter shipping information";
        self.shippingLabel.textColor = [AWXTheme sharedTheme].secondaryTextColor;
    }
}

@end
