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

IB_DESIGNABLE
@interface AWXFloatLabeledView : AWXNibView

@property (nonatomic, strong) IBInspectable NSString *text, *placeholder;

@end

IB_DESIGNABLE
@interface AWXCardTextField : AWXFloatLabeledTextField

@end

@interface AWXCurrencyView : AWXNibView

@property (nonatomic, strong) NSString *currencyName;
@property (nonatomic, strong, nullable) UIImage *flag;
@property (nonatomic, strong) NSString *price;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, weak) AWXCurrencyView *exclusiveView;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@interface AWXPayButtonView : AWXNibView

@property (nonatomic, strong) NSString *title;

@property (weak, nonatomic) IBOutlet AWXButton *payButton;
@end

NS_ASSUME_NONNULL_END
