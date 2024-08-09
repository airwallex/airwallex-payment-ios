//
//  AWXFloatingCardTextField.m
//  Core
//
//  Created by Hector.Huang on 2022/11/10.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXFloatingCardTextField.h"
#import "AWXCardImageView.h"
#import "AWXTheme.h"
#import "AWXUtils.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWXFloatingCardTextField ()

@property (strong, nonatomic) UIStackView *brandView;
@property (strong, nonatomic) NSMutableArray<AWXCardImageView *> *cardImageViews;

@end

@implementation AWXFloatingCardTextField

#pragma mark Override parent methods

- (void)setupLayouts {
    self.fieldType = AWXTextFieldTypeCardNumber;
    [self setupBrandView];

    NSDictionary *views = @{@"borderView": self.borderView, @"floatingLabel": self.floatingLabel, @"textField": self.textField, @"brandView": self.brandView, @"errorLabel": self.errorLabel};
    NSDictionary *metrics = @{@"margin": @16.0, @"spacing": @6.0, @"fieldHeight": @60.0};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[borderView]|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[errorLabel]-margin-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[borderView(fieldHeight)]-spacing-[errorLabel]|" options:0 metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[floatingLabel]-spacing-[brandView]-margin-|" options:0 metrics:metrics views:views]];
    [NSLayoutConstraint constraintWithItem:_brandView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.borderView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0].active = YES;
    self.floatingTopConstraint = [NSLayoutConstraint constraintWithItem:self.floatingLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.borderView attribute:NSLayoutAttributeTop multiplier:1.0 constant:30.0];
    self.floatingTopConstraint.active = YES;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[textField]-spacing-[brandView]-margin-|" options:0 metrics:metrics views:views]];
    self.textTopConstraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.borderView attribute:NSLayoutAttributeTop multiplier:1.0 constant:9];
    self.textTopConstraint.active = YES;
    [NSLayoutConstraint constraintWithItem:self.borderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:9].active = YES;
}

- (NSAttributedString *)formatText:(NSString *)text {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont bodyFont], NSForegroundColorAttributeName: [AWXTheme sharedTheme].primaryTextColor}];
    AWXBrandType type = [self typeOfNumber:text];
    NSArray *cardNumberFormat = [AWXCardValidator cardNumberFormatForBrand:type];
    NSUInteger index = 0;
    for (NSNumber *segmentLength in cardNumberFormat) {
        NSUInteger segmentIndex = 0;
        for (; index < attributedString.length && segmentIndex < [segmentLength unsignedIntegerValue]; index++, segmentIndex++) {
            if (index + 1 != attributedString.length && segmentIndex + 1 == [segmentLength unsignedIntegerValue]) {
                [attributedString addAttribute:NSKernAttributeName
                                         value:@(5)
                                         range:NSMakeRange(index, 1)];
            } else {
                [attributedString addAttribute:NSKernAttributeName
                                         value:@(0)
                                         range:NSMakeRange(index, 1)];
            }
        }
    }
    return attributedString;
}

- (void)setText:(NSString *)text animated:(BOOL)animated {
    [super setText:text animated:animated];
    [self updateBrandWithNumber:text];
}

#pragma mark Lifecycle methods

- (void)layoutSubviews {
    if (!_cardImageViews) {
        self.cardImageViews = [NSMutableArray new];
        for (id cardBrand in _cardBrands) {
            AWXBrandType brand = [cardBrand intValue];
            AWXCardImageView *cardView = [[AWXCardImageView alloc] initWithCardBrand:brand];
            [_cardImageViews addObject:cardView];
            [_brandView addArrangedSubview:cardView];
            [cardView.widthAnchor constraintEqualToConstant:35].active = YES;
            [cardView.heightAnchor constraintEqualToConstant:24].active = YES;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.errorText = nil;
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    text.length > 0 ? [self activateAnimated:YES] : [self deactivateAnimated:YES];

    if (text.length > [[AWXCardValidator shared] maxLengthForCardNumber:text]) {
        return NO;
    }

    [self setText:text animated:YES];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.errorText = _validationMessageCallback(textField.text);
}

#pragma mark Private helper methods

- (void)setFloatingText:(NSString *)floatingText {
    self.floatingLabel.text = floatingText;
}

- (void)setupBrandView {
    _brandView = [UIStackView new];
    _brandView.axis = UILayoutConstraintAxisHorizontal;
    _brandView.alignment = UIStackViewAlignmentFill;
    _brandView.distribution = UIStackViewDistributionFill;
    _brandView.spacing = 5;
    _brandView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_brandView];
}

- (AWXBrandType)typeOfNumber:(NSString *)number {
    AWXBrandType type = AWXBrandTypeUnknown;
    if (number.length != 0) {
        AWXBrand *brand = [[AWXCardValidator shared] brandForCardNumber:number];
        if (brand) {
            type = brand.type;
        }
    }
    return type;
}

- (void)updateBrandWithNumber:(NSString *)number {
    AWXBrandType type = [self typeOfNumber:number];
    _brandUpdateCallback(type);
    BOOL shouldShowBrands = NO;
    if ([_cardBrands containsObject:[NSNumber numberWithInteger:type]]) {
        shouldShowBrands = YES;
    }
    self.brandView.alpha = shouldShowBrands ? 1 : 0.5;
    for (AWXCardImageView *cardView in _cardImageViews) {
        if (shouldShowBrands) {
            cardView.hidden = cardView.cardBrand != type;
        } else {
            cardView.hidden = NO;
        }
    }
}

@end
