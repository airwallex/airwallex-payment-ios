//
//  Widgets.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "Widgets.h"

@interface View ()

@end

@implementation View

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

@interface NibView ()

@property (nonatomic, strong) UIView *view;

@end

@implementation NibView

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

@interface Button ()

@end

@implementation Button

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled = enabled;
    self.backgroundColor = enabled ? [UIColor colorNamed:@"Purple Color"] : [UIColor colorNamed:@"Line Color"];
}

@end

@interface FloatLabeledTextField () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *floatingLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *floatingTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textTopConstraint;

@end

@implementation FloatLabeledTextField

- (NSString *)text
{
    return self.textField.text;
}

- (void)setText:(NSString *)text
{
    self.textField.text = text;
    text.length > 0 ? [self active] : [self inactive];
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
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    text.length > 0 ? [self active] : [self inactive];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end

@interface FloatLabeledView ()

@property (weak, nonatomic) IBOutlet UILabel *floatingLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *floatingTopConstraint;

@end

@implementation FloatLabeledView

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
        self.floatingLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
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
        self.floatingLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        self.floatingTopConstraint.constant = 20;
        self.textLabel.alpha = 0;
        [self layoutIfNeeded];
    }];
}

@end
