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

@end

@interface AWXNibView ()

@property (nonatomic, strong) UIView *view;

@end

@implementation AWXNibView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self addNibView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addNibView];
    }
    return self;
}

- (void)addNibView
{
    UIView *view = [self loadFromNib:self.nibName index:self.nibIndex];
    view.frame = self.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_view = view];
    [self setup];
}

- (void)setup
{
}

- (NSString *)nibName
{
    return NSStringFromClass(self.class);
}

- (NSInteger)nibIndex
{
    return 0;
}

- (UIView *)loadFromNib:(NSString *)nibName index:(NSInteger)index
{
    UINib *nib = [UINib nibWithNibName:self.nibName bundle:[NSBundle bundleForClass:self.class]];
    return [nib instantiateWithOwner:self options:nil][self.nibIndex];
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
    self.backgroundColor = enabled ? [AWXTheme sharedTheme].tintColor : [AWXTheme sharedTheme].lineColor;
}

@end

@interface AWXFloatLabeledTextField () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet AWXView *borderView;
@property (weak, nonatomic) IBOutlet UILabel *floatingLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *floatingTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textTopConstraint;

@end

@implementation AWXFloatLabeledTextField

- (void)setup
{
    [super setup];
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (NSString *)text
{
    return [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSAttributedString *)formatText:(NSString *)text
{
    NSString *nonNilText = text ?: @"";
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:nonNilText attributes:@{NSFontAttributeName: [UIFont fontWithName:AWXFontNameCircularStdMedium size:16], NSForegroundColorAttributeName: [AWXTheme sharedTheme].textColor}];
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

- (void)setNextTextField:(AWXFloatLabeledTextField *)nextTextField
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
        self.borderView.borderColor = [UIColor colorWithRed:255.0f/255.0f green:79.0f/255.0f blue:66.0f/255.0f alpha:1];
        self.errorLabel.text = errorText;
    } else {
        self.borderView.borderColor = [UIColor colorWithRed:235.0f/255.0f green:246.0f/255.0f blue:240.0f/255.0f alpha:1];
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
                errorMessage = @"Please enter a valid expiry date";
            }
        } else {
            errorMessage = @"Please enter a valid expiry date";
        }
    } else {
        errorMessage = @"Please enter a valid expiry date";
    }
    self.errorText = errorMessage;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (self.fieldType) {
        case AWXTextFieldTypeFirstName:
            self.errorText = textField.text.length > 0 ? nil : @"Please enter your first name";
            break;
        case AWXTextFieldTypeLastName:
            self.errorText = textField.text.length > 0 ? nil : @"Please enter your last name";
            break;
        case AWXTextFieldTypeEmail:
            [self validateEmail:textField.text];
            break;
        case AWXTextFieldTypeCountry:
            self.errorText = textField.text.length > 0 ? nil : @"Please enter your country";
            break;
        case AWXTextFieldTypeState:
            self.errorText = textField.text.length > 0 ? nil : @"Please enter your state";
            break;
        case AWXTextFieldTypeCity:
            self.errorText = textField.text.length > 0 ? nil : @"Please enter your city";
            break;
        case AWXTextFieldTypeStreet:
            self.errorText = textField.text.length > 0 ? nil : @"Please enter your street";
            break;
        case AWXTextFieldTypeCardNumber:
            self.errorText = textField.text.length > 0 ? nil : @"Please enter your card number";
            break;
        case AWXTextFieldTypeNameOnCard:
            self.errorText = textField.text.length > 0 ? nil : @"Please enter your name on card";
            break;
        case AWXTextFieldTypeExpires:
            [self validateExpires:textField.text];
            break;
        case AWXTextFieldTypeCVC:
            self.errorText = textField.text.length > 0 ? nil : @"Please enter your card CVC";
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

@interface AWXFloatLabeledView ()

@property (weak, nonatomic) IBOutlet UILabel *floatingLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *floatingTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation AWXFloatLabeledView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.imageView.image = [UIImage imageNamed:@"down" inBundle:[NSBundle resourceBundle]];
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
    if (self.floatingTopConstraint.constant == 9) {
        return;
    }

    self.floatingTopConstraint.constant = 20;
    self.textLabel.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.floatingLabel.font = [UIFont fontWithName:AWXFontNameCircularStdMedium size:12];
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
        self.floatingLabel.font = [UIFont fontWithName:AWXFontNameCircularStdMedium size:14];
        self.floatingTopConstraint.constant = 20;
        self.textLabel.alpha = 0;
        [self layoutIfNeeded];
    }];
}

@end

@interface AWXCardTextField ()

@property (weak, nonatomic) IBOutlet UIStackView *brandView;
@property (weak, nonatomic) IBOutlet UIImageView *visaView;
@property (weak, nonatomic) IBOutlet UIImageView *masterView;

@end

@implementation AWXCardTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.visaView.image = [UIImage imageNamed:@"visa" inBundle:[NSBundle resourceBundle]];
    self.masterView.image = [UIImage imageNamed:@"mastercard" inBundle:[NSBundle resourceBundle]];
}

- (NSAttributedString *)formatText:(NSString *)text
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont fontWithName:AWXFontNameCircularStdMedium size:16], NSForegroundColorAttributeName: [AWXTheme sharedTheme].textColor}];
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

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *flagImageView;
@property (weak, nonatomic) IBOutlet UILabel *currencyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelLeftConstraint;

@end

@implementation AWXCurrencyView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 6.0f;
    self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.contentView.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
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
    self.contentView.layer.borderWidth = isSelected ? 1.5 : (1.0 / [UIScreen mainScreen].scale);
    self.contentView.layer.borderColor = isSelected ? [AWXTheme sharedTheme].tintColor.CGColor : [AWXTheme sharedTheme].lineColor.CGColor;
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

@interface AWXPayExtensionView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
@implementation AWXPayExtensionView

-(void)awakeFromNib {
    [super awakeFromNib];
}
- (IBAction)textFiledEditChange:(UITextField *)sender {
    if (self.textFieldEdit) {
        self.textFieldEdit(sender.text);
    }
}


- (void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}
- (NSString *)title{
    return  self.titleLabel.text;
}
-(void)setInputText:(NSString *)inputText{
    self.textField.text = inputText;
}
-(NSString *)inputText{
    return  self.textField.text;
}

- (void)setType:(AWXPayMethodExtensionType)type{
    _type = type;
    if (type == AWXPayMethodExtensionTypeBank) {
        self.title = @"Bank";
    }else if (type == AWXPayMethodExtensionTypeName) {
        self.title = @"Name";
    }else if (type == AWXPayMethodExtensionTypeEmail) {
        self.title = @"Email";
    }else if (type == AWXPayMethodExtensionTypePhone) {
        self.title = @"Phone";
    }
}

@end

@interface AWXPayButtonView ()
@end
@implementation AWXPayButtonView

- (void)setTitle:(NSString *)title{
    [self.payButton setTitle:title forState:(UIControlStateNormal)];
}
- (NSString *)title{
    return  self.payButton.titleLabel.text;
}

@end
