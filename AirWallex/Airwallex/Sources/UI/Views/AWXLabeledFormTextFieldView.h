//
//  AWXLabeledFormTextFieldView.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWXWidgets.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXLabeledFormTextFieldView : AWXView

@property (nonatomic, readonly) NSString *label;
@property (nonatomic, readonly) NSString *input;

- (instancetype)initWithKey:(NSString *)key formLabel:(NSString *)formLabelText textField:(UITextField *)textField;

@end

NS_ASSUME_NONNULL_END
