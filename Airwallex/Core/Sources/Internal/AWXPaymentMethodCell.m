//
//  AWXPaymentMethodCell.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodCell.h"
#import "AWXConstants.h"
#import "AWXTheme.h"
#import "AWXUtils.h"

@implementation AWXPaymentMethodCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _logoImageView = [UIImageView new];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_logoImageView];

        _titleLabel = [UILabel new];
        _titleLabel.textColor = [AWXTheme sharedTheme].textColor;
        _titleLabel.font = [UIFont subhead1Font];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_titleLabel];

        NSDictionary *views = @{@"logoImageView": _logoImageView, @"titleLabel": _titleLabel};
        NSDictionary *metrics = @{@"margin": @24.0, @"spacing": @16.0, @"logoWidth": @40.0, @"logoHeight": @23.0};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[logoImageView(logoWidth)]-spacing-[titleLabel]-margin-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[logoImageView(logoHeight)]->=margin-|" options:0 metrics:metrics views:views]];
    }
    return self;
}

@end
