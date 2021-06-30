//
//  AWXLabeledFormTextFieldView.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXLabeledFormTextFieldView.h"
#import "AWXUtils.h"
#import "AWXConstants.h"

@interface AWXLabeledFormTextFieldView ()

@property (nonatomic, strong) UILabel *formLabel;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation AWXLabeledFormTextFieldView

- (NSString *)label
{
    return self.formLabel.text;
}

- (NSString *)input
{
    return self.textField.text;
}

- (instancetype)initWithFormLabel:(NSString *)formLabelText textField:(UITextField *)textField
{
    if (self = [super initWithFrame:CGRectZero]) {
        UILabel *formLabel = [UILabel new];
        formLabel.text = formLabelText;
        formLabel.textColor = [UIColor textColor];
        formLabel.font = [UIFont fontWithName:AWXFontFamilyNameCircularXX size:14];
        formLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.formLabel = formLabel;
        [self addSubview:formLabel];

        UIView *contentView = [UIView autoLayoutView];
        contentView.layer.masksToBounds = YES;
        contentView.layer.cornerRadius = 6;
        contentView.layer.borderWidth = 1;
        contentView.layer.borderColor = [UIColor colorWithRed:0.92 green:0.93 blue:0.94 alpha:1].CGColor;
        [self addSubview:contentView];

        textField.textColor = [UIColor textColor];
        textField.font = [UIFont fontWithName:AWXFontFamilyNameCircularXX size:14];
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:textField];

        NSDictionary *views = @{@"formLabel": formLabel, @"contentView": contentView, @"textField": textField};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[formLabel]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[formLabel(21)][contentView]|"
                                                                     options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                     metrics:nil
                                                                       views:views]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[textField]-8-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:views]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textField(40)]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:views]];
    }
    return self;
}

@end
