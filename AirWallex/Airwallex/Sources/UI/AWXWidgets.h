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

IB_DESIGNABLE
@interface AWXView : UIView

@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic, strong) IBInspectable UIColor *borderColor;

@property (nonatomic, readonly) NSString *key;

- (instancetype)initWithKey:(NSString *)key;

@end

@interface AWXNibView : AWXView

- (void)setup;

@end

IB_DESIGNABLE
@interface AWXButton : UIButton

@property (nonatomic) IBInspectable CGFloat cornerRadius;

@end

IB_DESIGNABLE
@interface AWXFloatLabeledTextField : AWXNibView

@property (nonatomic, strong) IBInspectable NSString *text, *placeholder;
@property (nonatomic, strong, nullable) NSString *errorText;
@property (nonatomic) AWXTextFieldType fieldType;
@property (nonatomic, weak) AWXFloatLabeledTextField *nextTextField;

@end

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

IB_DESIGNABLE
@interface AWXFloatLabeledView : AWXNibView

@property (nonatomic, strong) IBInspectable NSString *text, *placeholder;

@end

@interface AWXFloatingLabelView : AWXView

@property (nonatomic, strong) NSString *text, *placeholder;

@end

IB_DESIGNABLE
@interface AWXCardTextField : AWXFloatLabeledTextField

@end

@interface AWXFloatingCardTextField : AWXFloatingLabelTextField

@end

@interface AWXCurrencyView : AWXNibView

@property (nonatomic, strong) NSString *currencyName;
@property (nonatomic, strong, nullable) UIImage *flag;
@property (nonatomic, strong) NSString *price;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, weak) AWXCurrencyView *exclusiveView;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

NS_ASSUME_NONNULL_END
