//
//  Widgets.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AWTextFieldType) {
    AWTextFieldTypeFirstName,
    AWTextFieldTypeLastName,
    AWTextFieldTypeEmail,
    AWTextFieldTypePhoneNumber,
    AWTextFieldTypeCountry,
    AWTextFieldTypeState,
    AWTextFieldTypeCity,
    AWTextFieldTypeStreet,
    AWTextFieldTypeZipcode,
    AWTextFieldTypeCardNumber,
    AWTextFieldTypeNameOnCard,
    AWTextFieldTypeExpires,
    AWTextFieldTypeCVC
};

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface AWView : UIView

@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic, strong) IBInspectable UIColor *borderColor;

@end

@interface AWNibView : AWView

@end

IB_DESIGNABLE
@interface AWButton : UIButton

@property (nonatomic) IBInspectable CGFloat cornerRadius;

@end

IB_DESIGNABLE
@interface AWFloatLabeledTextField : AWNibView

@property (nonatomic, strong) IBInspectable NSString *text, *placeholder;
@property (nonatomic, strong, nullable) NSString *errorText;
@property (nonatomic) AWTextFieldType fieldType;

@end

IB_DESIGNABLE
@interface AWFloatLabeledView : AWNibView

@property (nonatomic, strong) IBInspectable NSString *text, *placeholder;

@end

IB_DESIGNABLE
@interface AWCardTextField : AWFloatLabeledTextField

@end

@interface AWHUD : AWNibView

@property (weak, nonatomic) IBOutlet UIViewController *viewController;

- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
