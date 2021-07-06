//
//  AWXOptionView.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/29.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXOptionView.h"
#import "AWXUtils.h"
#import "AWXConstants.h"

@interface AWXOptionView ()

@property (nonatomic, strong) UIButton *contentView;
@property (nonatomic, strong) UILabel *formLabel;
@property (nonatomic, strong) NSString *placeholder;

@end

@implementation AWXOptionView

- (instancetype)initWithKey:(NSString *)key formLabel:(NSString *)formLabelText placeholder:(NSString *)placeholder logo:(NSString *)logo
{
    if (self = [super initWithKey:key]) {
        self.placeholder = placeholder;
        
        UIButton *contentView = [UIButton autoLayoutView];
        self.contentView = contentView;
        contentView.layer.masksToBounds = YES;
        contentView.layer.cornerRadius = 6;
        [contentView setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithRed:0.94 green:0.94 blue:1 alpha:1]] forState:UIControlStateHighlighted];
        [self addSubview:contentView];

        UILabel *formLabel = [UILabel new];
        self.formLabel = formLabel;
        formLabel.text = formLabelText;
        formLabel.textColor = [UIColor textColor];
        formLabel.font = [UIFont fontWithName:AWXFontFamilyNameCircularXX size:14];
        formLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:formLabel];
    
        [contentView addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

        UIImageView *imageView = [UIImageView autoLayoutView];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:logo];
        [contentView addSubview:imageView];

        NSDictionary *views = @{@"formLabel": formLabel, @"contentView": contentView, @"imageView": imageView};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[contentView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[contentView]-8-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:views]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[formLabel]->=0-[imageView]-8-|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:nil
                                                                       views:views]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[imageView(20)]-10-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:views]];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([@"highlighted" isEqualToString:keyPath]) {
        self.formLabel.textColor = self.contentView.isHighlighted ? [UIColor colorWithRed:0.38 green:0.18 blue:1 alpha:1] : [UIColor textColor];
    }
}

- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.contentView addTarget:target action:action forControlEvents:controlEvents];
}

@end
