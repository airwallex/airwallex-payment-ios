//
//  AWXLabeledFormTextFieldView.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWXLabeledFormTextFieldView : UIView

- (instancetype)initWithFormLabel:(NSString *)formLabelText textField:(UITextField *)textField;

@end

NS_ASSUME_NONNULL_END
