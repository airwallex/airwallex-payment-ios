//
//  Widgets.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface View : UIView

@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic, strong) IBInspectable UIColor *borderColor;

@end

@interface NibView : View

@end

IB_DESIGNABLE
@interface Button : UIButton

@property (nonatomic) IBInspectable CGFloat cornerRadius;

@end

IB_DESIGNABLE
@interface FloatLabeledTextField : NibView

@property (nonatomic, strong) IBInspectable NSString *text, *placeholder;
@property (nonatomic) IBInspectable NSInteger keyboardType;

@end

IB_DESIGNABLE
@interface FloatLabeledView : NibView

@property (nonatomic, strong) IBInspectable NSString *text, *placeholder;

@end

NS_ASSUME_NONNULL_END
