//
//  Widgets.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXWidgets.h"
#import "AWXCardValidator.h"
#import "AWXTheme.h"
#import "AWXUtils.h"
#import "UIColor+AWXTheme.h"

@interface AWXView ()

@end

@implementation AWXView

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

- (instancetype)initWithKey:(NSString *)key {
    if (self = [super initWithFrame:CGRectZero]) {
        self.key = key;
    }
    return self;
}

@end

@interface AWXFloatingLabelTextField ()<UITextFieldDelegate>

@end

@implementation AWXFloatingLabelTextField

- (instancetype)init {
    self = [super init];
    if (self) {
        _borderView = [AWXView new];
        _borderView.cornerRadius = 8.0;
        _borderView.borderWidth = 1.0;
        _borderView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_borderView];

        _floatingLabel = [UILabel new];
        _floatingLabel.font = [UIFont bodyFont];
        _floatingLabel.alpha = 0;
        _floatingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_borderView addSubview:_floatingLabel];

        _textField = [UITextField new];
        _textField.font = [UIFont bodyFont];
        _textField.delegate = self;
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_borderView addSubview:_textField];

        _errorLabel = [UILabel new];
        _errorLabel.font = [UIFont caption1Font];
        _errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _errorLabel.numberOfLines = 0;
        [self addSubview:_errorLabel];

        [self setupLayouts];
        [self updateColors];
    }
    return self;
}

- (void)layoutSubviews {
    if (_prefixText) {
        _textField.text = _prefixText;
        [self showFloatingLabel];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self updateColors];
}

- (void)updateColors {
    self.borderView.borderColor = [AWXTheme sharedTheme].lineColor;
    self.floatingLabel.textColor = [AWXTheme sharedTheme].secondaryTextColor;
    self.textField.textColor = [AWXTheme sharedTheme].primaryTextColor;
    self.errorLabel.textColor = [AWXTheme sharedTheme].errorColor;
}

- (void)setupLayouts {
    NSDictionary *views = @{@"borderView": _borderView, @"floatingLabel": _floatingLabel, @"textField": _textField, @"errorLabel": _errorLabel};
    NSDictionary *metrics = @{@"margin": @16.0, @"spacing": @6.0, @"fieldHeight": @60.0};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[borderView]|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[errorLabel]-margin-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[borderView(fieldHeight)]-spacing-[errorLabel]|" options:0 metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[floatingLabel]-margin-|" options:0 metrics:metrics views:views]];
    _floatingTopConstraint = [NSLayoutConstraint constraintWithItem:_floatingLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_borderView attribute:NSLayoutAttributeTop multiplier:1.0 constant:30.0];
    _floatingTopConstraint.active = YES;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[textField]-margin-|" options:0 metrics:metrics views:views]];
    _textTopConstraint = [NSLayoutConstraint constraintWithItem:_textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_borderView attribute:NSLayoutAttributeTop multiplier:1.0 constant:9];
    _textTopConstraint.active = YES;
    [NSLayoutConstraint constraintWithItem:_borderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_textField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:9].active = YES;
}

- (NSString *)text {
    return [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSAttributedString *)formatText:(NSString *)text {
    NSString *nonNilText = text ?: @"";
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:nonNilText attributes:@{NSFontAttributeName: [UIFont bodyFont], NSForegroundColorAttributeName: [AWXTheme sharedTheme].primaryTextColor}];
    return attributedString;
}

- (void)setText:(NSString *)text animated:(BOOL)animated {
    NSString *_text = text;
    if (self.fieldType == AWXTextFieldTypeExpires) {
        NSString *expirationMonth = [_text substringToIndex:MIN(_text.length, 2)];
        NSString *expirationYear = _text.length < 2 ? @"" : [_text substringFromIndex:2];
        if (expirationYear) {
            expirationYear = [expirationYear stringByRemovingIllegalCharacters];
            expirationYear = [expirationYear substringToIndex:MIN(expirationYear.length, 2)];
        }

        if (expirationMonth.length == 1 && ![expirationMonth isEqualToString:@"0"] && ![expirationMonth isEqualToString:@"1"]) {
            expirationMonth = [NSString stringWithFormat:@"0%@", text];
        }

        NSMutableArray *array = [NSMutableArray array];
        if (expirationMonth && ![expirationMonth isEqualToString:@""]) {
            [array addObject:expirationMonth];
        }
        if (expirationMonth.length == 2 && expirationMonth.integerValue > 0 && expirationMonth.integerValue <= 12) {
            [array addObject:expirationYear];
        }

        _text = [array componentsJoinedByString:@"/"];
    }
    self.textField.attributedText = [self formatText:_text];
    text.length > 0 ? [self activateAnimated:animated] : [self deactivateAnimated:animated];
}

- (void)setFieldType:(AWXTextFieldType)fieldType {
    _fieldType = fieldType;
    switch (self.fieldType) {
    case AWXTextFieldTypeDefault:
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.textContentType = UITextContentTypeName;
        break;
    case AWXTextFieldTypeFirstName:
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.textContentType = UITextContentTypeName;
        break;
    case AWXTextFieldTypeLastName:
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.textContentType = UITextContentTypeName;
        break;
    case AWXTextFieldTypeEmail:
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.keyboardType = UIKeyboardTypeEmailAddress;
        self.textField.textContentType = UITextContentTypeEmailAddress;
        break;
    case AWXTextFieldTypePhoneNumber:
        self.textField.keyboardType = UIKeyboardTypePhonePad;
        self.textField.textContentType = UITextContentTypeTelephoneNumber;
        break;
    case AWXTextFieldTypeCountry:
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.textContentType = UITextContentTypeCountryName;
        break;
    case AWXTextFieldTypeState:
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.textContentType = UITextContentTypeAddressState;
        break;
    case AWXTextFieldTypeCity:
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.textContentType = UITextContentTypeAddressCity;
        break;
    case AWXTextFieldTypeStreet:
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.textContentType = UITextContentTypeFullStreetAddress;
        break;
    case AWXTextFieldTypeZipcode:
        self.textField.keyboardType = UIKeyboardTypeASCIICapableNumberPad;
        self.textField.textContentType = UITextContentTypePostalCode;
        break;
    case AWXTextFieldTypeCardNumber:
        self.textField.keyboardType = UIKeyboardTypeASCIICapableNumberPad;
        break;
    case AWXTextFieldTypeNameOnCard:
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.textContentType = UITextContentTypeName;
        break;
    case AWXTextFieldTypeExpires:
        self.textField.keyboardType = UIKeyboardTypeASCIICapableNumberPad;
        break;
    case AWXTextFieldTypeCVC:
        self.textField.keyboardType = UIKeyboardTypeASCIICapableNumberPad;
        break;
    }
}

- (void)setNextTextField:(AWXFloatingLabelTextField *)nextTextField {
    _nextTextField = nextTextField;
    self.textField.returnKeyType = nextTextField == nil ? UIReturnKeyDefault : UIReturnKeyNext;
}

- (nullable NSString *)errorText {
    return self.errorLabel.text;
}

- (void)setErrorText:(nullable NSString *)errorText {
    if (errorText) {
        self.borderView.borderColor = [AWXTheme sharedTheme].errorColor;
        self.errorLabel.text = errorText;
    } else {
        self.borderView.borderColor = [AWXTheme sharedTheme].lineColor;
        self.errorLabel.text = nil;
    }
}

- (NSString *)placeholder {
    return self.textField.placeholder;
}

- (void)setPlaceholder:(NSString *)placeholder {
    if (self.fieldType != AWXTextFieldTypeCardNumber) {
        self.floatingLabel.text = placeholder;
    }
    self.textField.placeholder = placeholder;
}

- (void)activateAnimated:(BOOL)animated {
    if (self.floatingLabel.alpha == 1) {
        return;
    }

    self.floatingTopConstraint.constant = 30; // not 9?
    self.floatingLabel.alpha = 0;

    void (^callback)(void) = ^{
        [self showFloatingLabel];
    };

    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             callback();
                         }];
    } else {
        callback();
    }
}

- (void)deactivateAnimated:(BOOL)animated {
    if (self.floatingTopConstraint.constant == 20) {
        return;
    }

    self.floatingTopConstraint.constant = 9;
    self.floatingLabel.alpha = 1;

    void (^callback)(void) = ^{
        self.floatingLabel.font = [UIFont bodyFont];
        self.floatingTopConstraint.constant = 30; // not 20?
        self.textTopConstraint.constant = 9;
        self.floatingLabel.alpha = 0;
    };

    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             callback();
                             [self layoutIfNeeded];
                         }];
    } else {
        callback();
    }
}

- (void)showFloatingLabel {
    self.floatingLabel.font = [UIFont caption2Font];
    self.floatingTopConstraint.constant = 9;
    self.textTopConstraint.constant = 30;
    self.floatingLabel.alpha = 1;
    [self layoutIfNeeded];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (!(self.fieldType == AWXTextFieldTypeExpires)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(floatingLabelTextField:textDidChange:)]) {
            [self.delegate floatingLabelTextField:self textDidChange:text];
        }
        return YES;
    }

    self.errorText = nil;
    if (self.fieldType == AWXTextFieldTypeExpires) {
        BOOL deleting = (range.location == textField.text.length - 1 && range.length == 1 && [string isEqualToString:@""]);
        if (deleting) {
            NSString *string = [textField.text stringByRemovingIllegalCharacters];
            text = [string substringToIndex:string.length - 1];
        }
    }
    text.length > 0 ? [self activateAnimated:YES] : [self deactivateAnimated:YES];
    [self setText:text animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(floatingLabelTextField:textDidChange:)]) {
        [self.delegate floatingLabelTextField:self textDidChange:text];
    }
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(floatingLabelTextField:textFieldShouldBeginEditing:)]) {
        return [self.delegate floatingLabelTextField:self textFieldShouldBeginEditing:textField];
    }
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(floatingLabelTextField:textDidChange:)]) {
        [self.delegate floatingLabelTextField:self textDidChange:textField.text];
    }

    if (self.fieldType == AWXTextFieldTypeExpires || self.fieldType == AWXTextFieldTypeCVC) {
        return;
    }

    textField.text.length > 0 ? [self activateAnimated:YES] : [self deactivateAnimated:YES];
}

- (void)validateEmail:(NSString *)text {
    NSString *errorMessage = nil;
    if (text.length > 0) {
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if (![emailTest evaluateWithObject:text]) {
            errorMessage = @"Invalid email";
        }
    }
    self.errorText = errorMessage;
}

- (void)validateExpires:(NSString *)text {
    NSString *errorMessage = nil;
    if (text.length > 0) {
        NSArray *array = [text componentsSeparatedByString:@"/"];
        if (array.count == 2) {
            NSString *month = array.firstObject;
            NSString *year = array.lastObject;
            BOOL isValidMonth = month.integerValue > 0 && month.integerValue <= 12;
            NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            NSDate *date = [NSDate date];
            NSInteger currentYear = [calendar component:NSCalendarUnitYear fromDate:date] % 100;
            NSInteger currentMonth = [calendar component:NSCalendarUnitMonth fromDate:date];
            BOOL isValidYear;
            if (year.integerValue == currentYear) {
                isValidYear = month.integerValue >= currentMonth;
            } else {
                isValidYear = year.integerValue > currentYear;
            }
            if (!(isValidYear && isValidMonth)) {
                errorMessage = NSLocalizedString(@"Card’s expiration date is invalid", nil);
            }
        } else {
            errorMessage = NSLocalizedString(@"Card’s expiration date is invalid", nil);
        }
    } else {
        errorMessage = NSLocalizedString(@"Expiry date is required", nil);
    }
    self.errorText = errorMessage;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (!self.isRequired && textField.text.length == 0) {
        return;
    }

    switch (self.fieldType) {
    case AWXTextFieldTypePhoneNumber:
        textField.text = [[textField.text componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet] componentsJoinedByString:@""];
    case AWXTextFieldTypeFirstName:
        self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your first name", nil);
        break;
    case AWXTextFieldTypeLastName:
        self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your last name", nil);
        break;
    case AWXTextFieldTypeEmail:
        if (textField.text.length > 0) {
            [self validateEmail:textField.text];
        } else {
            self.errorText = self.defaultErrorMessage;
        }
        break;
    case AWXTextFieldTypeCountry:
        self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your country", nil);
        break;
    case AWXTextFieldTypeState:
        self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Invalid state", nil);
        break;
    case AWXTextFieldTypeCity:
        self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your state", nil);
        break;
    case AWXTextFieldTypeStreet:
        self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your street", nil);
        break;
    case AWXTextFieldTypeNameOnCard:
        self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your card name", nil);
        break;
    case AWXTextFieldTypeExpires:
        [self validateExpires:textField.text];
        break;
    default:
        self.errorText = textField.text.length > 0 ? nil : self.defaultErrorMessage;
        break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (!self.nextTextField) {
        [textField resignFirstResponder];
        return YES;
    }

    [self.nextTextField.textField becomeFirstResponder];
    return NO;
}

@end

@interface AWXFloatingLabelView ()

@property (strong, nonatomic, nonnull) AWXView *borderView;
@property (strong, nonatomic, nonnull) UILabel *floatingLabel;
@property (strong, nonatomic, nonnull) UILabel *textLabel;
@property (strong, nonatomic, nonnull) NSLayoutConstraint *floatingTopConstraint;
@property (strong, nonatomic, nonnull) UIImageView *imageView;

@end

@implementation AWXFloatingLabelView

- (instancetype)init {
    self = [super init];
    if (self) {
        AWXView *borderView = [AWXView new];
        borderView.cornerRadius = 8.0;
        borderView.borderWidth = 1.0;
        self.borderView = borderView;
        borderView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:borderView];

        _floatingLabel = [UILabel new];
        _floatingLabel.font = [UIFont bodyFont];
        _floatingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [borderView addSubview:_floatingLabel];

        _textLabel = [UILabel new];
        _textLabel.font = [UIFont bodyFont];
        _textLabel.alpha = 0;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [borderView addSubview:_textLabel];

        _imageView = [UIImageView new];
        _imageView.image = [UIImage imageNamed:@"down" inBundle:[NSBundle resourceBundle]];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [borderView addSubview:_imageView];

        NSDictionary *views = @{@"borderView": borderView, @"floatingLabel": _floatingLabel, @"textLabel": _textLabel, @"imageView": _imageView};
        NSDictionary *metrics = @{@"margin": @16.0, @"spacing": @6.0, @"fieldHeight": @60.0, @"top": @30.0};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[borderView]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[borderView(fieldHeight)]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[floatingLabel]-margin-[imageView]-margin-|" options:0 metrics:metrics views:views]];
        _floatingTopConstraint = [NSLayoutConstraint constraintWithItem:_floatingLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:borderView attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.0];
        _floatingTopConstraint.active = YES;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[textLabel]-margin-[imageView]" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[textLabel]->=spacing-|" options:0 metrics:metrics views:views]];
        [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:17.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:16.0].active = YES;
        [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_imageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;

        [self updateColors];
    }
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    [self updateColors];
}

- (void)updateColors {
    self.borderView.borderColor = [AWXTheme sharedTheme].lineColor;
    self.floatingLabel.textColor = [AWXTheme sharedTheme].secondaryTextColor;
    self.textLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
}

- (NSString *)text {
    return self.textLabel.text;
}

- (void)setText:(NSString *)text animated:(BOOL)animated {
    self.textLabel.text = text;
    text.length > 0 ? [self activateAnimated:animated] : [self deactivateAnimated:animated];
}

- (NSString *)placeholder {
    return self.floatingLabel.text;
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.floatingLabel.text = placeholder;
}

- (void)activateAnimated:(BOOL)animated {
    if (self.textLabel.alpha == 1) {
        return;
    }

    self.floatingTopConstraint.constant = 20;
    self.textLabel.alpha = 0;

    void (^callback)(void) = ^{
        self.floatingLabel.font = [UIFont caption2Font];
        self.floatingTopConstraint.constant = 9;
        self.textLabel.alpha = 1;
        [self layoutIfNeeded];
    };

    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             callback();
                         }];
    } else {
        callback();
    }
}

- (void)deactivateAnimated:(BOOL)animated {
    if (self.floatingTopConstraint.constant == 20) {
        return;
    }

    self.floatingTopConstraint.constant = 9;
    self.textLabel.alpha = 1;

    void (^callback)(void) = ^{
        self.floatingLabel.font = [UIFont bodyFont];
        self.floatingTopConstraint.constant = 20;
        self.textLabel.alpha = 0;
    };

    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             callback();
                             [self layoutIfNeeded];
                         }];
    } else {
        callback();
    }
}

@end

@interface AWXCurrencyView ()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIImageView *flagImageView;
@property (strong, nonatomic) UILabel *currencyNameLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) NSLayoutConstraint *labelLeftConstraint;

@end

@implementation AWXCurrencyView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8.0f;
        self.layer.borderColor = [AWXTheme sharedTheme].lineColor.CGColor;
        self.layer.borderWidth = 1.0;

        _contentView = [UIView new];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_contentView];

        UIView *topView = [UIView new];
        topView.translatesAutoresizingMaskIntoConstraints = NO;
        [_contentView addSubview:topView];

        _flagImageView = [UIImageView new];
        _flagImageView.contentMode = UIViewContentModeScaleAspectFit;
        _flagImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [topView addSubview:_flagImageView];

        _currencyNameLabel = [UILabel new];
        _currencyNameLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
        _currencyNameLabel.font = [UIFont subhead1Font];
        _currencyNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [topView addSubview:_currencyNameLabel];

        _priceLabel = [UILabel new];
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        _priceLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
        _priceLabel.font = [UIFont headlineFont];
        _priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_contentView addSubview:_priceLabel];

        _button = [UIButton new];
        [_button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_button];

        NSDictionary *views = @{@"contentView": _contentView, @"topView": topView, @"flagImageView": _flagImageView, @"currencyNameLabel": _currencyNameLabel, @"priceLabel": _priceLabel, @"button": _button};
        NSDictionary *metrics = @{@"margin": @16, @"imageWidth": @34, @"imageHeight": @24};

        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topView]|" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topView]-margin-[priceLabel]|" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:metrics views:views]];

        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[flagImageView(imageWidth)]" options:0 metrics:metrics views:views]];
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[flagImageView(imageHeight)]|" options:0 metrics:metrics views:views]];
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[currencyNameLabel]|" options:0 metrics:metrics views:views]];
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[currencyNameLabel]|" options:0 metrics:metrics views:views]];

        _labelLeftConstraint = [_currencyNameLabel.leftAnchor constraintEqualToAnchor:topView.leftAnchor constant:44];
        _labelLeftConstraint.active = YES;
        [_contentView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [_contentView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:0 metrics:metrics views:views]];
    }
    return self;
}

- (IBAction)buttonPressed:(id)sender {
    self.isSelected = YES;
    if (self.exclusiveView) {
        self.exclusiveView.isSelected = NO;
    }
}

- (BOOL)isSelected {
    return self.button.isSelected;
}

- (void)setIsSelected:(BOOL)isSelected {
    self.button.selected = isSelected;
    self.layer.borderWidth = (isSelected ? 1.5 : 1.0) / [UIScreen mainScreen].scale;
    self.layer.borderColor = isSelected ? [AWXTheme sharedTheme].tintColor.CGColor : [AWXTheme sharedTheme].lineColor.CGColor;
}

- (NSString *)currencyName {
    return self.currencyNameLabel.text;
}

- (void)setCurrencyName:(NSString *)currencyName {
    self.currencyNameLabel.text = currencyName;
}

- (UIImage *)flag {
    return self.flagImageView.image;
}

- (void)setFlag:(nullable UIImage *)flag {
    if (flag) {
        self.labelLeftConstraint.constant = 44;
    } else {
        self.labelLeftConstraint.constant = 0;
    }
    self.flagImageView.image = flag;
}

- (NSString *)price {
    return self.priceLabel.text;
}

- (void)setPrice:(NSString *)price {
    self.priceLabel.text = price;
}

@end

@interface AWXOptionView ()

@property (nonatomic, strong) UIButton *contentView;
@property (nonatomic, strong) UILabel *formLabel;
@property (nonatomic, strong) NSString *placeholder;

@end

@implementation AWXOptionView

- (instancetype)initWithKey:(NSString *)key formLabel:(NSString *)formLabelText logoURL:(NSURL *)logoURL {
    if (self = [super initWithKey:key]) {
        UIButton *contentView = [UIButton autoLayoutView];
        self.contentView = contentView;
        contentView.layer.masksToBounds = YES;
        contentView.layer.cornerRadius = 8;

        UIColor *color = [[AWXTheme sharedTheme].tintColor colorWithAlphaComponent:0.1];

        [contentView awx_setBackgroundColor:color forState:UIControlStateHighlighted];

        [self addSubview:contentView];

        UILabel *formLabel = [UILabel new];
        self.formLabel = formLabel;
        formLabel.text = formLabelText;
        formLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
        formLabel.font = [UIFont subhead1Font];
        formLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:formLabel];

        UIImageViewAligned *imageView = [UIImageViewAligned autoLayoutView];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.alignRight = YES;
        [imageView setImageURL:logoURL
                   placeholder:nil];
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
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[formLabel]->=0-[imageView]|"
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

- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [self.contentView addTarget:target action:action forControlEvents:controlEvents];
}

@end

@implementation UIImageViewAligned

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self)
        [self commonInit];

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self)
        [self commonInit];
    return self;
}

- (void)commonInit {
    _enableScaleDown = YES;
    _enableScaleUp = YES;

    _alignment = UIImageViewAlignmentMaskCenter;

    _realImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _realImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _realImageView.contentMode = self.contentMode;
    [self addSubview:_realImageView];

    if (super.image != nil) {
        UIImage *img = super.image;
        super.image = nil;
        self.image = img;
    }
}

- (UIImage *)image {
    return _realImageView.image;
}

- (void)setImage:(UIImage *)image {
    [_realImageView setImage:image];
    [self setNeedsLayout];
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    _realImageView.contentMode = contentMode;
    [self setNeedsLayout];
}

- (void)setAlignment:(UIImageViewAlignmentMask)alignment {
    if (_alignment == alignment)
        return;

    _alignment = alignment;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    CGSize realsize = [self realContentSize];

    CGRect realframe = CGRectMake((self.bounds.size.width - realsize.width) / 2, (self.bounds.size.height - realsize.height) / 2, realsize.width, realsize.height);

    if ((_alignment & UIImageViewAlignmentMaskLeft) != 0)
        realframe.origin.x = 0;
    else if ((_alignment & UIImageViewAlignmentMaskRight) != 0)
        realframe.origin.x = CGRectGetMaxX(self.bounds) - realframe.size.width;

    if ((_alignment & UIImageViewAlignmentMaskTop) != 0)
        realframe.origin.y = 0;
    else if ((_alignment & UIImageViewAlignmentMaskBottom) != 0)
        realframe.origin.y = CGRectGetMaxY(self.bounds) - realframe.size.height;

    _realImageView.frame = realframe;

    self.layer.contents = nil;
}

- (CGSize)realContentSize {
    CGSize size = self.bounds.size;

    if (self.image == nil)
        return size;

    switch (self.contentMode) {
    case UIViewContentModeScaleAspectFit: {
        float scalex = self.bounds.size.width / _realImageView.image.size.width;
        float scaley = self.bounds.size.height / _realImageView.image.size.height;
        float scale = MIN(scalex, scaley);

        if ((scale > 1.0f && !_enableScaleUp) ||
            (scale < 1.0f && !_enableScaleDown))
            scale = 1.0f;
        size = CGSizeMake(_realImageView.image.size.width * scale, _realImageView.image.size.height * scale);
        break;
    }

    case UIViewContentModeScaleAspectFill: {
        float scalex = self.bounds.size.width / _realImageView.image.size.width;
        float scaley = self.bounds.size.height / _realImageView.image.size.height;
        float scale = MAX(scalex, scaley);

        if ((scale > 1.0f && !_enableScaleUp) ||
            (scale < 1.0f && !_enableScaleDown))
            scale = 1.0f;

        size = CGSizeMake(_realImageView.image.size.width * scale, _realImageView.image.size.height * scale);
        break;
    }

    case UIViewContentModeScaleToFill: {
        float scalex = self.bounds.size.width / _realImageView.image.size.width;
        float scaley = self.bounds.size.height / _realImageView.image.size.height;

        if ((scalex > 1.0f && !_enableScaleUp) ||
            (scalex < 1.0f && !_enableScaleDown))
            scalex = 1.0f;
        if ((scaley > 1.0f && !_enableScaleUp) ||
            (scaley < 1.0f && !_enableScaleDown))
            scaley = 1.0f;

        size = CGSizeMake(_realImageView.image.size.width * scalex, _realImageView.image.size.height * scaley);
        break;
    }

    default:
        size = _realImageView.image.size;
        break;
    }

    return size;
}

#pragma mark - UIImageView overloads

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.layer.contents = nil;
}

#pragma mark - Properties needed for Interface Builder

- (BOOL)alignLeft {
    return (_alignment & UIImageViewAlignmentMaskLeft) != 0;
}
- (void)setAlignLeft:(BOOL)alignLeft {
    if (alignLeft)
        self.alignment |= UIImageViewAlignmentMaskLeft;
    else
        self.alignment &= ~UIImageViewAlignmentMaskLeft;
}

- (BOOL)alignRight {
    return (_alignment & UIImageViewAlignmentMaskRight) != 0;
}
- (void)setAlignRight:(BOOL)alignRight {
    if (alignRight)
        self.alignment |= UIImageViewAlignmentMaskRight;
    else
        self.alignment &= ~UIImageViewAlignmentMaskRight;
}

- (BOOL)alignTop {
    return (_alignment & UIImageViewAlignmentMaskTop) != 0;
}
- (void)setAlignTop:(BOOL)alignTop {
    if (alignTop)
        self.alignment |= UIImageViewAlignmentMaskTop;
    else
        self.alignment &= ~UIImageViewAlignmentMaskTop;
}

- (BOOL)alignBottom {
    return (_alignment & UIImageViewAlignmentMaskBottom) != 0;
}
- (void)setAlignBottom:(BOOL)alignBottom {
    if (alignBottom)
        self.alignment |= UIImageViewAlignmentMaskBottom;
    else
        self.alignment &= ~UIImageViewAlignmentMaskBottom;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.realImageView sizeThatFits:size];
}

@end

@implementation AWXActionButton

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    [self updateColors];
}

- (void)setupView {
    self.translatesAutoresizingMaskIntoConstraints = NO;

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:52]];

    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 6;

    self.titleLabel.font = UIFont.headlineFont;

    [self updateColors];
}

- (void)updateColors {
    [self awx_setBackgroundColor:[AWXTheme sharedTheme].tintColor forState:UIControlStateNormal];
    [self awx_setBackgroundColor:[AWXTheme sharedTheme].disabledButtonColor forState:UIControlStateDisabled];
    [self setTitleColor:[AWXTheme sharedTheme].primaryButtonTextColor forState:UIControlStateNormal];
}

@end

@implementation UIButton (BackgroundColor)

- (void)awx_setBackgroundColor:(UIColor *)color forState:(UIControlState)state {
    self.clipsToBounds = YES;

    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    colorView.backgroundColor = color;

    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [self setBackgroundImage:colorImage forState:state];
}

@end

@implementation AWXWarningView

- (instancetype)initWithMessage:(NSString *)message {
    self = [super init];

    self.translatesAutoresizingMaskIntoConstraints = NO;

    // Apply corner radius
    UIView *roundView = [[UIView alloc] initWithFrame:self.bounds];
    roundView.backgroundColor = UIColor.airwallexYellow10Color;
    roundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:roundView atIndex:0];
    roundView.layer.cornerRadius = 6;
    roundView.layer.masksToBounds = YES;
    roundView.clipsToBounds = YES;

    [self setSpacing:16];
    [self setAlignment:UIStackViewAlignmentCenter];
    [self setLayoutMarginsRelativeArrangement:YES];
    [self setDirectionalLayoutMargins:NSDirectionalEdgeInsetsMake(12, 16, 12, 16)];

    UIImageView *iconImage = [UIImageView new];
    [iconImage.widthAnchor constraintEqualToConstant:24].active = YES;
    [iconImage.heightAnchor constraintEqualToConstant:24].active = YES;
    iconImage.image = [UIImage systemImageNamed:@"exclamationmark.circle.fill"];
    iconImage.tintColor = UIColor.airwallexOrange50Color;

    UILabel *warningLabel = [UILabel new];
    [warningLabel setTextColor:UIColor.airwallexGray80Color];
    [warningLabel setFont:UIFont.body2Font];
    warningLabel.numberOfLines = 0;
    warningLabel.text = message;

    [self addArrangedSubview:iconImage];
    [self addArrangedSubview:warningLabel];
    return self;
}

@end
