//
//  Widgets.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface View : UIView

@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic, strong) IBInspectable UIColor *borderColor;

@end

@interface NibView : View

@end

@interface Button : UIButton

@property (nonatomic) IBInspectable CGFloat cornerRadius;

@end

NS_ASSUME_NONNULL_END
