//
//  Widgets.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AWXTextFieldType) {
    AWXTextFieldTypeFirstName,
    AWXTextFieldTypeLastName,
    AWXTextFieldTypeEmail,
    AWXTextFieldTypePhoneNumber,
    AWXTextFieldTypeCountry,
    AWXTextFieldTypeState,
    AWXTextFieldTypeCity,
    AWXTextFieldTypeStreet,
    AWXTextFieldTypeZipcode,
    AWXTextFieldTypeCardNumber,
    AWXTextFieldTypeNameOnCard,
    AWXTextFieldTypeExpires,
    AWXTextFieldTypeCVC
};

NS_ASSUME_NONNULL_BEGIN

/**
 Base view
 */
@interface AWXView : UIView

@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, readonly) NSString *key;

- (instancetype)initWithKey:(NSString *)key;

@end

/**
 A customized button with corner radius
 */
@interface AWXButton : UIButton

@property (nonatomic) CGFloat cornerRadius;

@end

/**
 A customized text field for inputing
 */
@interface AWXFloatingLabelTextField : AWXView

@property (strong, nonatomic) AWXView *borderView;
@property (strong, nonatomic) UILabel *floatingLabel;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) NSLayoutConstraint *floatingTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *textTopConstraint;

@property (nonatomic, strong) NSString *text, *placeholder;
@property (nonatomic, strong, nullable) NSString *errorText;
@property (nonatomic) AWXTextFieldType fieldType;
@property (nonatomic, weak) AWXFloatingLabelTextField *nextTextField;

- (void)setupLayouts;

@end

/**
 A customized view for options
 */
@interface AWXFloatingLabelView : AWXView

@property (nonatomic, strong) NSString *text, *placeholder;

@end

/**
 A customized view for card no
 */
@interface AWXFloatingCardTextField : AWXFloatingLabelTextField

@end

/**
 A customized view for currency
 */
@interface AWXCurrencyView : AWXView

@property (nonatomic, strong) NSString *currencyName;
@property (nonatomic, strong, nullable) UIImage *flag;
@property (nonatomic, strong) NSString *price;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, weak) AWXCurrencyView *exclusiveView;
@property (strong, nonatomic) UIButton *button;

@end

/**
 A customized view for input form
 */
@interface AWXLabeledFormTextFieldView : AWXView

@property (nonatomic, readonly) NSString *label;
@property (nonatomic, readonly) NSString *input;

- (instancetype)initWithKey:(NSString *)key formLabel:(NSString *)formLabelText textField:(UITextField *)textField;

@end

/**
 A customized view for option form
 */
@interface AWXOptionView : AWXView

@property (nonatomic, readonly) NSString *placeholder;

- (instancetype)initWithKey:(NSString *)key formLabel:(NSString *)formLabelText placeholder:(NSString *)placeholder logo:(NSString *)logo;
- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end

NS_ASSUME_NONNULL_END
