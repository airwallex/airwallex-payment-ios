//
//  AWXPaymentMethodCell.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodCell.h"
#import "AWXConstants.h"
#import "AWXUtils.h"

@implementation AWXPaymentMethodCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _logoImageView = [UIImageView new];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_logoImageView];
        
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor textColor];
        _titleLabel.font = [UIFont fontWithName:AWXFontNameCircularStdMedium size:14];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_titleLabel];
        
        NSDictionary *views = @{@"logoImageView": _logoImageView, @"titleLabel": _titleLabel};
        NSDictionary *metrics = @{@"margin": @16.0, @"spacing": @20.0, @"logoWidth": @40.0, @"logoHeight": @23.0};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[logoImageView(logoWidth)]-spacing-[titleLabel]-margin-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[logoImageView(logoHeight)]->=margin-|" options:0 metrics:metrics views:views]];
    }
    return self;
}

@end
