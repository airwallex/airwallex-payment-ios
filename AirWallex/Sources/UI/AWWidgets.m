//
//  Widgets.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWWidgets.h"
#import "AWCardValidator.h"
#import "AWTheme.h"
#import "AWUtils.h"

@interface AWView ()

@end

@implementation AWView

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

@interface AWNibView ()

@property (nonatomic, strong) UIView *view;

@end

@implementation AWNibView

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

@interface AWButton ()

@end

@implementation AWButton

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled = enabled;
    self.backgroundColor = enabled ? [AWTheme defaultTheme].purpleColor : [AWTheme defaultTheme].lineColor;
}

@end

@interface AWFloatLabeledTextField () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet AWView *borderView;
@property (weak, nonatomic) IBOutlet UILabel *floatingLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *floatingTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textTopConstraint;

@end

@implementation AWFloatLabeledTextField

- (NSString *)text
{
    return self.textField.text;
}

- (NSAttributedString *)formatText:(NSString *)text
{
    NSString *nonNilText = text ?: @"";
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:nonNilText attributes:@{NSFontAttributeName: [UIFont fontWithName:@"CircularStd-Medium" size:16], NSForegroundColorAttributeName: [UIColor colorWithRed:42.0f/255.0f green:42.0f/255.0f blue:42.0f/255.0f alpha:1]}];
    return attributedString;
}

- (void)setText:(NSString *)text
{
    self.textField.attributedText = [self formatText:text];
    text.length > 0 ? [self active] : [self inactive];
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

- (NSInteger)keyboardType
{
    return self.textField.keyboardType;
}

- (void)setKeyboardType:(NSInteger)keyboardType
{
    self.textField.keyboardType = keyboardType;
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
    self.errorText = nil;
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    text.length > 0 ? [self active] : [self inactive];
    [self setText:text];
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end

@interface AWFloatLabeledView ()

@property (weak, nonatomic) IBOutlet UILabel *floatingLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *floatingTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation AWFloatLabeledView

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
        self.floatingLabel.font = [UIFont fontWithName:@"CircularStd-Medium" size:12];
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
        self.floatingLabel.font = [UIFont fontWithName:@"CircularStd-Medium" size:14];
        self.floatingTopConstraint.constant = 20;
        self.textLabel.alpha = 0;
        [self layoutIfNeeded];
    }];
}

@end

@interface AWCardTextField ()

@property (weak, nonatomic) IBOutlet UIStackView *brandView;
@property (weak, nonatomic) IBOutlet UIImageView *visaView;
@property (weak, nonatomic) IBOutlet UIImageView *masterView;

@end

@implementation AWCardTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.visaView.image = [UIImage imageNamed:@"visa" inBundle:[NSBundle resourceBundle]];
    self.masterView.image = [UIImage imageNamed:@"mastercard" inBundle:[NSBundle resourceBundle]];
}

- (NSAttributedString *)formatText:(NSString *)text
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"CircularStd-Medium" size:16], NSForegroundColorAttributeName: [UIColor colorWithRed:42.0f/255.0f green:42.0f/255.0f blue:42.0f/255.0f alpha:1]}];
    AWBrandType type = [self typeOfNumber:text];
    NSArray<NSNumber *> *cardNumberFormat = [AWCardValidator cardNumberFormatForBrand:type];
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

- (AWBrandType)typeOfNumber:(NSString *)number
{
    AWBrandType type = AWBrandTypeUnknown;
    if (number.length != 0) {
        AWBrand *brand = [AWCardValidator.shared brandForCardNumber:number];
        if (brand) {
            type = brand.type;
        }
    }
    return type;
}

- (void)updateBrandWithNumber:(NSString *)number
{
    AWBrandType type = [self typeOfNumber:number];
    self.brandView.alpha = (type == AWBrandTypeVisa || type == AWBrandTypeMastercard) ? 1 : 0.5;
    if (self.brandView.alpha == 1) {
        self.visaView.hidden = type != AWBrandTypeVisa;
        self.masterView.hidden = type != AWBrandTypeMastercard;
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

    AWBrand *brand = [AWCardValidator.shared brandForCardNumber:text];
    if (brand && text.length > brand.length) {
        return NO;
    }

    [self setText:text];
    return NO;
}

@end

@interface AWHUD ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation AWHUD

- (void)addSubviewIfNeeded
{
    if (!self.superview && self.viewController) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = self.viewController.view.bounds;
        [self.viewController.view addSubview:self];
    }
    self.alpha = 1;
}

- (void)show
{
    [self addSubviewIfNeeded];
    [self.activityIndicator startAnimating];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
