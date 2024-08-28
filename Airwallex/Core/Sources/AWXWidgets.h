//
//  Widgets.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXConstants.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Base view
 */
@interface AWXView : UIView

@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, copy) NSString *key;

- (instancetype)initWithKey:(NSString *)key;

@end

@class AWXFloatingLabelTextField;
@protocol AWXFloatingLabelTextFieldDelegate<NSObject>

@optional
- (void)floatingLabelTextField:(AWXFloatingLabelTextField *)textField textDidChange:(NSString *)text;
- (BOOL)floatingLabelTextField:(AWXFloatingLabelTextField *)floatingLabelTextField textFieldShouldBeginEditing:(UITextField *)textField;

@end

/**
 A customized text field for inputing
 */
@interface AWXFloatingLabelTextField : AWXView

@property (weak, nonatomic, nullable) id<AWXFloatingLabelTextFieldDelegate> delegate;
@property (strong, nonatomic) AWXView *borderView;
@property (strong, nonatomic) UILabel *floatingLabel;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) NSLayoutConstraint *floatingTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *textTopConstraint;

@property (nonatomic) BOOL isRequired;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong, nullable) NSString *errorText, *defaultErrorMessage;
@property (nonatomic, strong, nullable) NSString *prefixText;
@property (nonatomic) AWXTextFieldType fieldType;
@property (nonatomic, weak) AWXFloatingLabelTextField *nextTextField;

- (NSString *)text;
- (void)setText:(NSString *)text animated:(BOOL)animated;

- (void)setupLayouts;
- (void)activateAnimated:(BOOL)animated;
- (void)deactivateAnimated:(BOOL)animated;

@end

/**
 A customized view for options
 */
@interface AWXFloatingLabelView : AWXView

@property (nonatomic, strong) NSString *placeholder;

- (NSString *)text;
- (void)setText:(NSString *)text animated:(BOOL)animated;

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
 A customized view for option form
 */
@interface AWXOptionView : AWXView

- (instancetype)initWithKey:(NSString *)key formLabel:(NSString *)formLabelText logoURL:(NSURL *)logoURL;
- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end

/**
 A common button type used for submission
 */
@interface AWXActionButton : UIButton

@end

/**
 A common warning view with icon and text
 */
@interface AWXWarningView : UIStackView

- (instancetype)initWithMessage:(NSString *)message;

@end

typedef enum {
    UIImageViewAlignmentMaskCenter = 0,
    UIImageViewAlignmentMaskLeft = 1,
    UIImageViewAlignmentMaskRight = 2,
    UIImageViewAlignmentMaskTop = 4,
    UIImageViewAlignmentMaskBottom = 8,

    UIImageViewAlignmentMaskBottomLeft = UIImageViewAlignmentMaskBottom | UIImageViewAlignmentMaskLeft,
    UIImageViewAlignmentMaskBottomRight = UIImageViewAlignmentMaskBottom | UIImageViewAlignmentMaskRight,
    UIImageViewAlignmentMaskTopLeft = UIImageViewAlignmentMaskTop | UIImageViewAlignmentMaskLeft,
    UIImageViewAlignmentMaskTopRight = UIImageViewAlignmentMaskTop | UIImageViewAlignmentMaskRight,

} UIImageViewAlignmentMask;

@interface UIImageViewAligned : UIImageView

@property (nonatomic) UIImageViewAlignmentMask alignment;
@property (nonatomic) BOOL alignLeft;
@property (nonatomic) BOOL alignRight;
@property (nonatomic) BOOL alignTop;
@property (nonatomic) BOOL alignBottom;
@property (nonatomic) BOOL enableScaleUp;
@property (nonatomic) BOOL enableScaleDown;
@property (nonatomic, readonly) UIImageView *realImageView;

@end

NS_ASSUME_NONNULL_END

@interface UIButton (BackgroundColor)

- (void)awx_setBackgroundColor:(UIColor *_Nonnull)color forState:(UIControlState)state;

@end
