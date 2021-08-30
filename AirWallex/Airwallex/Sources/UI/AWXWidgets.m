//
//  Widgets.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXWidgets.h"
#import "AWXConstants.h"
#import "AWXCardValidator.h"
#import "AWXTheme.h"
#import "AWXUtils.h"

@interface AWXView ()

@property (nonatomic, strong) NSString *key;

@end

@implementation AWXView

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth / [UIScreen mainScreen].scale;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

- (instancetype)initWithKey:(NSString *)key
{
    if (self = [super initWithFrame:CGRectZero]) {
        self.key = key;
    }
    return self;
}

@end

@interface AWXButton ()

@end

@implementation AWXButton

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled = enabled;
    self.backgroundColor = enabled ? [AWXTheme sharedTheme].tintColor : [UIColor gray10Color];
}

@end

@interface AWXFloatingLabelTextField () <UITextFieldDelegate>

@end

@implementation AWXFloatingLabelTextField

- (instancetype)init
{
    self = [super init];
    if (self) {
        _borderView = [AWXView new];
        _borderView.borderColor = [AWXTheme sharedTheme].lineColor;
        _borderView.cornerRadius = 8.0;
        _borderView.borderWidth = 1.0 / [UIScreen mainScreen].scale;
        _borderView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_borderView];
        
        _floatingLabel = [UILabel new];
        _floatingLabel.textColor = [UIColor gray50Color];
        _floatingLabel.font = [UIFont bodyFont];
        _floatingLabel.alpha = 0;
        _floatingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_borderView addSubview:_floatingLabel];
        
        _textField = [UITextField new];
        _textField.textColor = [AWXTheme sharedTheme].textColor;
        _textField.font = [UIFont bodyFont];
        _textField.delegate = self;
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_borderView addSubview:_textField];
        
        _errorLabel = [UILabel new];
        _errorLabel.textColor = [UIColor infraredColor];
        _errorLabel.font = [UIFont caption1Font];
        _errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_errorLabel];
        
        [self setupLayouts];
    }
    return self;
}

- (void)setupLayouts
{
    NSDictionary *views = @{@"borderView": _borderView, @"floatingLabel": _floatingLabel, @"textField": _textField, @"errorLabel": _errorLabel};
    NSDictionary *metrics = @{@"margin": @16.0, @"spacing": @6.0};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[borderView]|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[errorLabel]-margin-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[borderView]-spacing-[errorLabel]|" options:0 metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[floatingLabel]-margin-|" options:0 metrics:metrics views:views]];
    _floatingTopConstraint = [NSLayoutConstraint constraintWithItem:_floatingLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_borderView attribute:NSLayoutAttributeTop multiplier:1.0 constant:30.0];
    _floatingTopConstraint.active = YES;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[textField]-margin-|" options:0 metrics:metrics views:views]];
    _textTopConstraint = [NSLayoutConstraint constraintWithItem:_textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_borderView attribute:NSLayoutAttributeTop multiplier:1.0 constant:9];
    _textTopConstraint.active = YES;
    [NSLayoutConstraint constraintWithItem:_borderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_textField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:9].active = YES;
}

- (NSString *)text
{
    return [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSAttributedString *)formatText:(NSString *)text
{
    NSString *nonNilText = text ?: @"";
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:nonNilText attributes:@{NSFontAttributeName: [UIFont bodyFont], NSForegroundColorAttributeName: [AWXTheme sharedTheme].textColor}];
    return attributedString;
}

- (void)setText:(NSString *)text
{
    NSString *_text = text;
    if (self.fieldType == AWXTextFieldTypeExpires) {
        NSString *expirationMonth = [_text substringToIndex:MIN(_text.length, 2)];
        NSString *expirationYear = _text.length < 2 ? @"" : [_text substringFromIndex:2];
        if (expirationYear) {
            expirationYear = [expirationYear stringByRemovingIllegalCharacters];
            expirationYear = [expirationYear substringToIndex:MIN(expirationYear.length, 4)];
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
    text.length > 0 ? [self active] : [self inactive];
}

- (void)setFieldType:(AWXTextFieldType)fieldType
{
    _fieldType = fieldType;
    switch (self.fieldType) {
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
        default:
            break;
    }
}

- (void)setNextTextField:(AWXFloatingLabelTextField *)nextTextField
{
    _nextTextField = nextTextField;
    self.textField.returnKeyType = nextTextField == nil ? UIReturnKeyDefault : UIReturnKeyNext;
}

- (nullable NSString *)errorText
{
    return self.errorLabel.text;
}

- (void)setErrorText:(nullable NSString *)errorText
{
    if (errorText) {
        self.borderView.borderColor = [UIColor infraredColor];
        self.errorLabel.text = errorText;
    } else {
        self.borderView.borderColor = [AWXTheme sharedTheme].lineColor;
        self.errorLabel.text = nil;
    }
}

- (NSString *)placeholder
{
    return self.textField.placeholder;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    self.floatingLabel.text = placeholder;
    self.textField.placeholder = placeholder;
}

- (void)active
{
    if (self.floatingLabel.alpha == 1) {
        return;
    }
    
    self.floatingTopConstraint.constant = 30;
    self.textTopConstraint.constant = 9;
    self.floatingLabel.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.floatingTopConstraint.constant = 9;
        self.textTopConstraint.constant = 30;
        [self layoutIfNeeded];
        self.floatingLabel.alpha = 1;
    }];
}

- (void)inactive
{
    if (self.floatingLabel.alpha == 0) {
        return;
    }
    
    self.floatingTopConstraint.constant = 9;
    self.textTopConstraint.constant = 30;
    self.floatingLabel.alpha = 1;
    [UIView animateWithDuration:0.25 animations:^{
        self.floatingTopConstraint.constant = 30;
        self.textTopConstraint.constant = 9;
        [self layoutIfNeeded];
        self.floatingLabel.alpha = 0;
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!(self.fieldType == AWXTextFieldTypeExpires || self.fieldType == AWXTextFieldTypeCVC)) {
        return YES;
    }
    
    self.errorText = nil;
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.fieldType == AWXTextFieldTypeExpires) {
        BOOL deleting = (range.location == textField.text.length - 1 && range.length == 1 && [string isEqualToString:@""]);
        if (deleting) {
            NSString *string = [textField.text stringByRemovingIllegalCharacters];
            text = [string substringToIndex:string.length - 1];
        }
    } else if (self.fieldType == AWXTextFieldTypeCVC) {
        text = [text substringToIndex:MIN(text.length, 4)];
    }
    text.length > 0 ? [self active] : [self inactive];
    [self setText:text];
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (self.fieldType == AWXTextFieldTypeExpires || self.fieldType == AWXTextFieldTypeCVC) {
        return;
    }
    
    textField.text.length > 0 ? [self active] : [self inactive];
}

- (void)validateEmail:(NSString *)text
{
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

- (void)validateExpires:(NSString *)text
{
    NSString *errorMessage = nil;
    if (text.length > 0) {
        NSArray *array = [text componentsSeparatedByString:@"/"];
        if (array.count == 2) {
            NSString *month = array.firstObject;
            NSString *year = array.lastObject;
            BOOL isValidMonth = month.integerValue > 0 && month.integerValue <= 12;
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *date = [NSDate date];
            NSInteger currentYear = [calendar component:NSCalendarUnitYear fromDate:date];
            NSInteger currentMonth = [calendar component:NSCalendarUnitMonth fromDate:date];
            BOOL isValidYear;
            if (year.integerValue == currentYear) {
                isValidYear = month.integerValue >= currentMonth;
            } else {
                isValidYear = year.integerValue > currentYear;
            }
            if (!(isValidYear && isValidMonth)) {
                errorMessage = NSLocalizedString(@"Please enter a valid expiry date", nil);
            }
        } else {
            errorMessage = NSLocalizedString(@"Please enter a valid expiry date", nil);
        }
    } else {
        errorMessage = NSLocalizedString(@"Please enter a valid expiry date", nil);
    }
    self.errorText = errorMessage;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (self.fieldType) {
        case AWXTextFieldTypeFirstName:
            self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your first name", nil);
            break;
        case AWXTextFieldTypeLastName:
            self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your last name", nil);
            break;
        case AWXTextFieldTypeEmail:
            [self validateEmail:textField.text];
            break;
        case AWXTextFieldTypeCountry:
            self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your country", nil);
            break;
        case AWXTextFieldTypeState:
            self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your state", nil);
            break;
        case AWXTextFieldTypeCity:
            self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your city", nil);
            break;
        case AWXTextFieldTypeStreet:
            self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your street", nil);
            break;
        case AWXTextFieldTypeCardNumber:
            self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your card number", nil);
            break;
        case AWXTextFieldTypeNameOnCard:
            self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your name on card", nil);
            break;
        case AWXTextFieldTypeExpires:
            [self validateExpires:textField.text];
            break;
        case AWXTextFieldTypeCVC:
            self.errorText = textField.text.length > 0 ? nil : NSLocalizedString(@"Please enter your card CVC", nil);
            break;
        default:
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (!self.nextTextField) {
        [textField resignFirstResponder];
        return YES;
    }
    
    [self.nextTextField.textField becomeFirstResponder];
    return NO;
}

@end

@interface AWXFloatingLabelView ()

@property (strong, nonatomic) UILabel *floatingLabel;
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) NSLayoutConstraint *floatingTopConstraint;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation AWXFloatingLabelView

- (instancetype)init
{
    self = [super init];
    if (self) {
        AWXView *borderView = [AWXView new];
        borderView.borderColor = [AWXTheme sharedTheme].lineColor;
        borderView.cornerRadius = 8.0;
        borderView.borderWidth = 1.0 / [UIScreen mainScreen].scale;
        borderView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:borderView];
        
        _floatingLabel = [UILabel new];
        _floatingLabel.textColor = [UIColor gray50Color];
        _floatingLabel.font = [UIFont caption2Font];
        _floatingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [borderView addSubview:_floatingLabel];
        
        _textLabel = [UILabel new];
        _textLabel.alpha = 0;
        _textLabel.textColor = [AWXTheme sharedTheme].textColor;
        _textLabel.font = [UIFont bodyFont];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [borderView addSubview:_textLabel];
        
        _imageView = [UIImageView new];
        _imageView.image = [UIImage imageNamed:@"down" inBundle:[NSBundle resourceBundle]];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [borderView addSubview:_imageView];
        
        NSDictionary *views = @{@"borderView": borderView, @"floatingLabel": _floatingLabel, @"textLabel": _textLabel, @"imageView": _imageView};
        NSDictionary *metrics = @{@"margin": @16.0, @"spacing": @6.0, @"top": @30.0};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[borderView]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[borderView]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[floatingLabel]-margin-[imageView]-margin-|" options:0 metrics:metrics views:views]];
        _floatingTopConstraint = [NSLayoutConstraint constraintWithItem:_floatingLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:borderView attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.0];
        _floatingTopConstraint.active = YES;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[textLabel]-margin-[imageView]" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[textLabel]->=spacing-|" options:0 metrics:metrics views:views]];
        [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:17.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:16.0].active = YES;
        [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_imageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    }
    return self;
}

- (NSString *)text
{
    return self.textLabel.text;
}

- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
    text.length > 0 ? [self active] : [self inactive];
}

- (NSString *)placeholder
{
    return self.floatingLabel.text;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    self.floatingLabel.text = placeholder;
}

- (void)active
{
    if (self.textLabel.alpha == 1) {
        return;
    }
    
    self.floatingTopConstraint.constant = 20;
    self.textLabel.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.floatingLabel.font = [UIFont caption2Font];
        self.floatingTopConstraint.constant = 9;
        self.textLabel.alpha = 1;
        [self layoutIfNeeded];
    }];
}

- (void)inactive
{
    if (self.floatingTopConstraint.constant == 20) {
        return;
    }
    
    self.floatingTopConstraint.constant = 9;
    self.textLabel.alpha = 1;
    [UIView animateWithDuration:0.25 animations:^{
        self.floatingLabel.font = [UIFont bodyFont];
        self.floatingTopConstraint.constant = 20;
        self.textLabel.alpha = 0;
        [self layoutIfNeeded];
    }];
}

@end

@interface AWXFloatingCardTextField ()

@property (strong, nonatomic) UIStackView *brandView;
@property (strong, nonatomic) UIImageView *visaView;
@property (strong, nonatomic) UIImageView *masterView;

@end

@implementation AWXFloatingCardTextField

- (void)setupLayouts
{
    _brandView = [UIStackView new];
    _brandView.axis = UILayoutConstraintAxisHorizontal;
    _brandView.alignment = UIStackViewAlignmentFill;
    _brandView.distribution = UIStackViewDistributionFill;
    _brandView.spacing = 5;
    _brandView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_brandView];
    
    _visaView = [UIImageView new];
    _visaView.image = [UIImage imageNamed:@"visa" inBundle:[NSBundle resourceBundle]];
    _visaView.contentMode = UIViewContentModeScaleAspectFit;
    [_brandView addArrangedSubview:_visaView];
    [_visaView.widthAnchor constraintEqualToConstant:35].active = YES;
    [_visaView.heightAnchor constraintEqualToConstant:24].active = YES;
    
    _masterView = [UIImageView new];
    _masterView.image = [UIImage imageNamed:@"mastercard" inBundle:[NSBundle resourceBundle]];
    _masterView.contentMode = UIViewContentModeScaleAspectFit;
    [_brandView addArrangedSubview:_masterView];
    [_masterView.widthAnchor constraintEqualToConstant:35].active = YES;
    [_masterView.heightAnchor constraintEqualToConstant:24].active = YES;
    
    NSDictionary *views = @{@"borderView": self.borderView, @"floatingLabel": self.floatingLabel, @"textField": self.textField, @"brandView": self.brandView, @"errorLabel": self.errorLabel};
    NSDictionary *metrics = @{@"margin": @16.0, @"spacing": @6.0};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[borderView]|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[errorLabel]-margin-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[borderView]-spacing-[errorLabel]|" options:0 metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[floatingLabel]-spacing-[brandView]-margin-|" options:0 metrics:metrics views:views]];
    [NSLayoutConstraint constraintWithItem:_brandView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.borderView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0].active = YES;
    self.floatingTopConstraint = [NSLayoutConstraint constraintWithItem:self.floatingLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.borderView attribute:NSLayoutAttributeTop multiplier:1.0 constant:30.0];
    self.floatingTopConstraint.active = YES;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[textField]-spacing-[brandView]-margin-|" options:0 metrics:metrics views:views]];
    self.textTopConstraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.borderView attribute:NSLayoutAttributeTop multiplier:1.0 constant:9];
    self.textTopConstraint.active = YES;
    [NSLayoutConstraint constraintWithItem:self.borderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:9].active = YES;
}

- (NSAttributedString *)formatText:(NSString *)text
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont bodyFont], NSForegroundColorAttributeName: [AWXTheme sharedTheme].textColor}];
    AWXBrandType type = [self typeOfNumber:text];
    NSArray *cardNumberFormat = [AWXCardValidator cardNumberFormatForBrand:type];
    NSUInteger index = 0;
    for (NSNumber *segmentLength in cardNumberFormat) {
        NSUInteger segmentIndex = 0;
        for (; index < attributedString.length && segmentIndex < [segmentLength unsignedIntegerValue]; index++, segmentIndex++) {
            if (index + 1 != attributedString.length && segmentIndex + 1 == [segmentLength unsignedIntegerValue]) {
                [attributedString addAttribute:NSKernAttributeName value:@(5)
                                         range:NSMakeRange(index, 1)];
            } else {
                [attributedString addAttribute:NSKernAttributeName value:@(0)
                                         range:NSMakeRange(index, 1)];
            }
        }
    }
    return attributedString;
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self updateBrandWithNumber:text];
}

- (AWXBrandType)typeOfNumber:(NSString *)number
{
    AWXBrandType type = AWXBrandTypeUnknown;
    if (number.length != 0) {
        AWXBrand *brand = [[AWXCardValidator sharedCardValidator] brandForCardNumber:number];
        if (brand) {
            type = brand.type;
        }
    }
    return type;
}

- (void)updateBrandWithNumber:(NSString *)number
{
    AWXBrandType type = [self typeOfNumber:number];
    self.brandView.alpha = (type == AWXBrandTypeVisa || type == AWXBrandTypeMastercard) ? 1 : 0.5;
    if (self.brandView.alpha == 1) {
        self.visaView.hidden = type != AWXBrandTypeVisa;
        self.masterView.hidden = type != AWXBrandTypeMastercard;
    } else {
        self.visaView.hidden = NO;
        self.masterView.hidden = NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.errorText = nil;
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    text.length > 0 ? [self active] : [self inactive];
    
    AWXBrand *brand = [[AWXCardValidator sharedCardValidator] brandForCardNumber:text];
    if (brand && text.length > brand.length) {
        return NO;
    }
    
    [self setText:text];
    return NO;
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8.0f;
        self.layer.borderColor = [AWXTheme sharedTheme].lineColor.CGColor;
        self.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
        
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
        _currencyNameLabel.textColor = [AWXTheme sharedTheme].textColor;
        _currencyNameLabel.font = [UIFont subhead1Font];
        _currencyNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [topView addSubview:_currencyNameLabel];
        
        _priceLabel = [UILabel new];
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        _priceLabel.textColor = [AWXTheme sharedTheme].textColor;
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

- (IBAction)buttonPressed:(id)sender
{
    self.isSelected = YES;
    if (self.exclusiveView) {
        self.exclusiveView.isSelected = NO;
    }
}

- (BOOL)isSelected
{
    return self.button.isSelected;
}

- (void)setIsSelected:(BOOL)isSelected
{
    self.button.selected = isSelected;
    self.layer.borderWidth = (isSelected ? 1.5 : 1.0) / [UIScreen mainScreen].scale;
    self.layer.borderColor = isSelected ? [AWXTheme sharedTheme].tintColor.CGColor : [AWXTheme sharedTheme].lineColor.CGColor;
}

- (NSString *)currencyName
{
    return self.currencyNameLabel.text;
}

- (void)setCurrencyName:(NSString *)currencyName
{
    self.currencyNameLabel.text = currencyName;
}

- (UIImage *)flag
{
    return self.flagImageView.image;
}

- (void)setFlag:(nullable UIImage *)flag
{
    if (flag) {
        self.labelLeftConstraint.constant = 44;
    } else {
        self.labelLeftConstraint.constant = 0;
    }
    self.flagImageView.image = flag;
}

- (NSString *)price
{
    return self.priceLabel.text;
}

- (void)setPrice:(NSString *)price
{
    self.priceLabel.text = price;
}

@end

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

- (instancetype)initWithKey:(NSString *)key formLabel:(NSString *)formLabelText textField:(UITextField *)textField
{
    if (self = [super initWithKey:key]) {
        UILabel *formLabel = [UILabel new];
        formLabel.text = formLabelText;
        formLabel.textColor = [AWXTheme sharedTheme].textColor;
        formLabel.font = [UIFont bodyFont];
        formLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.formLabel = formLabel;
        [self addSubview:formLabel];
        
        UIView *contentView = [UIView autoLayoutView];
        contentView.layer.masksToBounds = YES;
        contentView.layer.cornerRadius = 8;
        contentView.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
        contentView.layer.borderColor = [AWXTheme sharedTheme].lineColor.CGColor;
        [self addSubview:contentView];
        
        textField.textColor = [AWXTheme sharedTheme].textColor;
        textField.font = [UIFont bodyFont];
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        self.textField = textField;
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
        contentView.layer.cornerRadius = 8;
        [contentView setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithRed:0.94 green:0.94 blue:1 alpha:1]] forState:UIControlStateHighlighted];
        [self addSubview:contentView];
        
        UILabel *formLabel = [UILabel new];
        self.formLabel = formLabel;
        formLabel.text = formLabelText;
        formLabel.textColor = [AWXTheme sharedTheme].textColor;
        formLabel.font = [UIFont subhead1Font];
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
        self.formLabel.textColor = self.contentView.isHighlighted ? [AWXTheme sharedTheme].tintColor : [UIColor gray70Color];
    }
}

- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.contentView addTarget:target action:action forControlEvents:controlEvents];
}

@end
